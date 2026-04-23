import 'dart:async';
import 'dart:convert';

import 'package:binance_core/src/observability.dart';
import 'package:binance_core/src/ws/base.dart';

/// Client for Binance WebSocket Streams (unidirectional data feeds).
///
/// Supports single and combined streams with auto-reconnection and multiplexing.
class WebSocketStreamClient {
  /// Creates a [WebSocketStreamClient].
  WebSocketStreamClient({
    required Uri baseUrl,
    required BinanceWebSocketProvider provider,
    BinanceObservabilityHooks hooks = const BinanceObservabilityHooks(),
    ReconnectionStrategy reconnectionStrategy = const ReconnectionStrategy(),
    this.pingInterval = const Duration(minutes: 3),
    this.maxBufferSize = 1000,
  })  : _baseUrl = baseUrl,
        _provider = provider,
        _hooks = hooks,
        _reconnectionStrategy = reconnectionStrategy;

  final Uri _baseUrl;
  final BinanceWebSocketProvider _provider;
  final BinanceObservabilityHooks _hooks;
  final ReconnectionStrategy _reconnectionStrategy;

  BinanceLogger get _logger => _hooks.logger;

  /// Interval for checking heartbeat.
  final Duration pingInterval;

  /// Maximum number of messages to buffer before emitting a lag warning.
  final int maxBufferSize;

  BinanceWebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _heartbeatTimer;
  DateTime? _lastFrameTime;

  final Map<String, StreamController<dynamic>> _controllers = {};
  final Map<String, int> _bufferCounts = {};
  final Set<String> _activeStreams = {};
  int _reconnectAttempts = 0;
  bool _isClosing = false;

  /// Returns a stream for the given [streamName].
  ///
  /// The stream will automatically subscribe when the first listener is added
  /// and unsubscribe when the last listener is removed.
  Stream<dynamic> subscribe(String streamName) {
    final controller = _controllers.putIfAbsent(streamName, () {
      return StreamController<dynamic>.broadcast(
        onListen: () => unawaited(_handleSubscribe(streamName)),
        onCancel: () => unawaited(_handleUnsubscribe(streamName)),
      );
    });
    return controller.stream;
  }

  Future<void> _handleSubscribe(String streamName) async {
    if (_activeStreams.contains(streamName)) return;
    _activeStreams.add(streamName);

    if (_channel == null) {
      await _connect();
    } else {
      // Reconnect to update combined streams URL
      await _disconnect();
      await _connect();
    }
  }

  Future<void> _handleUnsubscribe(String streamName) async {
    if (!_activeStreams.contains(streamName)) return;
    _activeStreams.remove(streamName);

    if (_activeStreams.isEmpty) {
      await _disconnect();
    } else if (_channel != null) {
      await _disconnect();
      await _connect();
    }
  }

  Completer<void>? _connectionCompleter;

  Future<void> _connect() async {
    if (_isClosing || _channel != null) return;
    if (_connectionCompleter != null) return _connectionCompleter!.future;

    _connectionCompleter = Completer<void>();

    try {
      final url = _buildUrl();
      _logger.info('Connecting to WebSocket Stream: $url');
      final channel = await _provider.connect(url);

      if (_channel != null) {
        await channel.close();
        return;
      }

      _channel = channel;
      _reconnectAttempts = 0;
      _lastFrameTime = DateTime.now();
      _startHeartbeat();

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _connectionCompleter?.complete();
    } catch (e, st) {
      _logger.error(
        'Failed to connect to WebSocket Stream',
        error: e,
        stackTrace: st,
      );
      _connectionCompleter?.completeError(e, st);
      _scheduleReconnect();
    } finally {
      _connectionCompleter = null;
    }
  }

  Uri _buildUrl() {
    if (_activeStreams.isEmpty) return _baseUrl;

    // Binance combined streams format: /stream?streams=a/b/c
    final streams = _activeStreams.join('/');
    return _baseUrl.replace(
      path: '/stream',
      queryParameters: {'streams': streams},
    );
  }

  void _onMessage(dynamic message) {
    _lastFrameTime = DateTime.now();

    try {
      final data = message is String ? jsonDecode(message) : message;

      // Handle Ping from Binance
      if (data is Map && data['method'] == 'ping') {
        _channel?.sink.add(jsonEncode({'method': 'pong'}));
        return;
      }

      // Handle combined stream data: {"stream":"<streamName>","data":<data>}
      if (data is Map &&
          data.containsKey('stream') &&
          data.containsKey('data')) {
        final streamName = data['stream'] as String;
        final streamData = data['data'];
        _emitToController(streamName, streamData);
      } else if (data is Map &&
          data.containsKey('result') &&
          data['id'] != null) {
        // Subscription result, ignore
      } else {
        _logger.debug('Received unknown message format: $message');
      }
    } catch (e, st) {
      _logger.error(
        'Error parsing WebSocket message',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _emitToController(String streamName, dynamic data) {
    final controller = _controllers[streamName];
    if (controller != null && !controller.isClosed) {
      if (controller.hasListener) {
        final count = (_bufferCounts[streamName] ?? 0) + 1;
        _bufferCounts[streamName] = count;

        if (count > maxBufferSize) {
          _hooks.onStreamLag?.call(
            StreamLagWarning(
              streamName: streamName,
              bufferSize: count,
              maxBufferSize: maxBufferSize,
            ),
          );
        }

        controller.add(data);

        scheduleMicrotask(() {
          _bufferCounts[streamName] = (_bufferCounts[streamName] ?? 1) - 1;
        });
      }
    }
  }

  void _onError(Object error, StackTrace stackTrace) {
    _logger.error(
      'WebSocket Stream error',
      error: error,
      stackTrace: stackTrace,
    );
    _scheduleReconnect();
  }

  void _onDone() {
    _logger.info('WebSocket Stream connection closed');
    if (!_isClosing) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isClosing) return;
    _stopHeartbeat();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;

    if (_activeStreams.isEmpty) return;

    final delay = _reconnectionStrategy.getDelay(_reconnectAttempts++);
    _logger.info('Reconnecting in ${delay.inSeconds}s...');
    Timer(delay, _connect);
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(pingInterval, (timer) {
      final now = DateTime.now();
      if (_lastFrameTime != null &&
          now.difference(_lastFrameTime!) > pingInterval * 3) {
        _logger.warning('WebSocket heartbeat timeout, forcing reconnection');
        _channel?.close();
        _scheduleReconnect();
      } else {
        _channel?.sink.add(
          jsonEncode({
            'method': 'ping',
            'id': DateTime.now().millisecondsSinceEpoch,
          }),
        );
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _disconnect() async {
    _stopHeartbeat();
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.close();
    _channel = null;
  }

  /// Closes the client and all active streams.
  Future<void> close() async {
    _isClosing = true;
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
    _activeStreams.clear();
    await _disconnect();
  }
}
