import 'dart:async';
import 'dart:convert';

import 'package:binance_core/src/auth.dart';
import 'package:binance_core/src/observability.dart';
import 'package:binance_core/src/utils.dart';
import 'package:binance_core/src/ws/base.dart';

/// Client for Binance WebSocket API (bidirectional request/response).
///
/// Equivalent to REST API but over WebSockets. Supports persistent sessions.
class WebSocketApiClient {
  /// Creates a [WebSocketApiClient].
  WebSocketApiClient({
    required Uri baseUrl,
    required BinanceWebSocketProvider provider,
    BinanceObservabilityHooks hooks = const BinanceObservabilityHooks(),
    ReconnectionStrategy reconnectionStrategy = const ReconnectionStrategy(),
    this.pingInterval = const Duration(minutes: 3),
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

  BinanceWebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;
  Timer? _heartbeatTimer;
  DateTime? _lastFrameTime;

  final Map<String, Completer<dynamic>> _pendingRequests = {};
  final StreamController<dynamic> _eventsController =
      StreamController<dynamic>.broadcast();
  final StreamController<WebSocketApiClientStatus> _statusController =
      StreamController<WebSocketApiClientStatus>.broadcast();

  /// Stream of unsolicited events from the server.
  Stream<dynamic> get events => _eventsController.stream;

  /// Stream of status changes for the client.
  Stream<WebSocketApiClientStatus> get status => _statusController.stream;

  int _requestIdCounter = 0;
  int _reconnectAttempts = 0;
  bool _isClosing = false;

  BinanceCredentials? _credentials;
  bool _isLoggedIn = false;

  /// Whether the client is currently connected.
  bool get isConnected => _channel != null;

  /// Whether the session is currently authenticated.
  bool get isLoggedIn => _isLoggedIn;

  /// Connects to the WebSocket API.
  Future<void> connect() async {
    if (_channel != null || _isClosing) return;

    try {
      _logger.info('Connecting to WebSocket API: $_baseUrl');
      _statusController.add(WebSocketApiClientStatus.connecting);
      _channel = await _provider.connect(_baseUrl);
      _reconnectAttempts = 0;
      _lastFrameTime = DateTime.now();
      _startHeartbeat();

      _channelSubscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _statusController.add(WebSocketApiClientStatus.connected);

      if (_credentials != null) {
        // Resume session if it was active or if we have credentials
        await _performLogon(_credentials!);
      }
    } catch (e, st) {
      _logger.error(
        'Failed to connect to WebSocket API',
        error: e,
        stackTrace: st,
      );
      _scheduleReconnect();
      rethrow;
    }
  }

  /// Logs in to the session using the given [credentials].
  ///
  /// Post-logon, subsequent requests omit apiKey and signature.
  Future<void> logon(BinanceCredentials credentials) async {
    _credentials = credentials;
    if (_channel == null) {
      await connect();
    } else {
      await _performLogon(credentials);
    }
  }

  Future<void> _performLogon(BinanceCredentials credentials) async {
    final params = <String, dynamic>{
      'apiKey': credentials.apiKey,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    final signer = _createSigner(credentials);
    final canonicalPayload = _buildCanonicalPayload(params);
    final signature = await signer.sign(canonicalPayload);
    params['signature'] = signature.value;

    final response = await sendRequest('session.logon', params);
    if (response is Map && response['status'] == 200) {
      _isLoggedIn = true;
      _logger.info('WebSocket session logon successful');
      _statusController.add(WebSocketApiClientStatus.authenticated);
    } else {
      _isLoggedIn = false;
      final error = response is Map ? response['error'] : 'Unknown error';
      _logger.error('WebSocket session logon failed: $error');
      throw Exception('Logon failed: $error');
    }
  }

  /// Logs out of the current session.
  Future<void> logout() async {
    if (!_isLoggedIn) return;
    await sendRequest('session.logout');
    _isLoggedIn = false;
    _credentials = null;
  }

  /// Checks the status of the current session.
  Future<dynamic> getSessionStatus() async {
    return sendRequest('session.status');
  }

  /// Sends a request to the WebSocket API and waits for a response.
  Future<dynamic> sendRequest(
    String method, [
    Map<String, dynamic>? params,
  ]) async {
    if (_channel == null) {
      await connect();
    }

    final id = (_requestIdCounter++).toString();
    final completer = Completer<dynamic>();
    _pendingRequests[id] = completer;

    final request = <String, dynamic>{'id': id, 'method': method};
    if (params != null) {
      request['params'] = params;
    }

    _channel!.sink.add(jsonEncode(request));

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _pendingRequests.remove(id);
        throw TimeoutException('Request $method timed out');
      },
    );
  }

  void _onMessage(dynamic message) {
    _lastFrameTime = DateTime.now();

    try {
      final data = message is String ? jsonDecode(message) : message;

      if (data is Map && data.containsKey('id')) {
        final id = data['id'].toString();
        final completer = _pendingRequests.remove(id);
        if (completer != null) {
          completer.complete(data);
          return;
        }
      }

      if (data is Map && data['method'] == 'ping') {
        _channel?.sink.add(jsonEncode({'method': 'pong'}));
      } else {
        // Handle unsolicited events
        _eventsController.add(data);
      }
    } catch (e, st) {
      _logger.error(
        'Error parsing WebSocket API message',
        error: e,
        stackTrace: st,
      );
    }
  }

  void _onError(Object error, StackTrace stackTrace) {
    _logger.error('WebSocket API error', error: error, stackTrace: stackTrace);
    _scheduleReconnect();
  }

  void _onDone() {
    _logger.info('WebSocket API connection closed');
    _statusController.add(WebSocketApiClientStatus.disconnected);
    if (!_isClosing) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _stopHeartbeat();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _channel = null;
    _isLoggedIn = false; // Reset session status on disconnect

    if (_isClosing) return;

    final delay = _reconnectionStrategy.getDelay(_reconnectAttempts++);
    _logger.info('Reconnecting to WebSocket API in ${delay.inSeconds}s...');
    _statusController.add(WebSocketApiClientStatus.reconnecting);
    Timer(delay, () => unawaited(connect()));
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(pingInterval, (timer) {
      final now = DateTime.now();
      final lastFrame = _lastFrameTime;
      if (lastFrame != null && now.difference(lastFrame) > pingInterval * 3) {
        _logger.warning(
          'WebSocket API heartbeat timeout, forcing reconnection',
        );
        _channel?.close();
        _scheduleReconnect();
      } else {
        // session.status can act as a heartbeat and keep session alive
        if (_isLoggedIn) {
          getSessionStatus().catchError((_) => null);
        } else {
          _channel?.sink.add(
            jsonEncode({
              'id': 'hb_${DateTime.now().millisecondsSinceEpoch}',
              'method': 'ping',
            }),
          );
        }
      }
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  RequestSigner _createSigner(BinanceCredentials credentials) {
    return switch (credentials) {
      HmacCredentials() => HmacRequestSigner(credentials),
      RsaCredentials() => RsaRequestSigner(credentials),
      Ed25519Credentials() => Ed25519RequestSigner(credentials),
    };
  }

  String _buildCanonicalPayload(Map<String, dynamic> params) {
    return BinanceUtils.buildCanonicalPayload(params);
  }

  /// Closes the client.
  Future<void> close() async {
    _isClosing = true;
    await _eventsController.close();
    await _statusController.close();
    _stopHeartbeat();
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.close();
    _channel = null;

    for (final completer in _pendingRequests.values) {
      completer.completeError(Exception('Client closed'));
    }
    _pendingRequests.clear();
    _isClosing = false;
  }
}

/// Status of the [WebSocketApiClient].
enum WebSocketApiClientStatus {
  /// Connecting to the server.
  connecting,

  /// Connected to the server.
  connected,

  /// Disconnected from the server.
  disconnected,

  /// Reconnecting after a loss of connection.
  reconnecting,

  /// Authenticated session.
  authenticated,
}
