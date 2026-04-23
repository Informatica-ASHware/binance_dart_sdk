import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:binance_core/binance_core.dart';
import 'package:test/test.dart';

class MockWebSocketChannel implements BinanceWebSocketChannel {
  final _streamController = StreamController<dynamic>.broadcast();
  final _sinkController = StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get stream => _streamController.stream;

  @override
  Sink<dynamic> get sink => _sinkController.sink;

  Stream<dynamic> get sentMessages => _sinkController.stream;

  void addFromServer(dynamic message) {
    if (!_streamController.isClosed) {
      _streamController.add(message);
    }
  }

  void closeFromServer() {
    _streamController.close();
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    await _streamController.close();
    await _sinkController.close();
  }
}

class PrintLogger implements BinanceLogger {
  @override
  void log(BinanceLogLevel level, String message,
          {Object? error, StackTrace? stackTrace}) =>
      print('$level: $message');

  @override
  void info(String message) => print('INFO: $message');
  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      print('ERROR: $message $error');
  @override
  void warning(String message) => print('WARNING: $message');
  @override
  void debug(String message) => print('DEBUG: $message');
}

class MockWebSocketProvider implements BinanceWebSocketProvider {
  MockWebSocketChannel? lastChannel;
  Uri? lastUrl;
  int connectCount = 0;
  Future<BinanceWebSocketChannel> Function(Uri)? onConnect;

  @override
  Future<BinanceWebSocketChannel> connect(Uri url) async {
    print('Connecting to $url');
    connectCount++;
    lastUrl = url;
    if (onConnect != null) {
      final channel = await onConnect!(url);
      if (channel is MockWebSocketChannel) lastChannel = channel;
      return channel;
    }
    final channel = MockWebSocketChannel();
    lastChannel = channel;
    return channel;
  }
}

void main() {
  group('ReconnectionStrategy', () {
    test('calculates delay with exponential backoff', () {
      const strategy = ReconnectionStrategy(
        initialDelay: Duration(seconds: 1),
        multiplier: 2.0,
        jitter: 0.0,
      );

      expect(strategy.getDelay(0).inSeconds, 1);
      expect(strategy.getDelay(1).inSeconds, 2);
      expect(strategy.getDelay(2).inSeconds, 4);
    });

    test('respects maxDelay', () {
      const strategy = ReconnectionStrategy(
        initialDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 10),
        multiplier: 2.0,
        jitter: 0.0,
      );

      expect(strategy.getDelay(0).inSeconds, 1);
      expect(strategy.getDelay(10).inSeconds, 10);
    });
  });

  group('WebSocketStreamClient', () {
    late MockWebSocketProvider provider;
    late WebSocketStreamClient client;

    setUp(() {
      provider = MockWebSocketProvider();
      client = WebSocketStreamClient(
        baseUrl: Uri.parse('wss://stream.binance.com:9443'),
        provider: provider,
        hooks: BinanceObservabilityHooks(
          logger: PrintLogger(),
        ),
        reconnectionStrategy: const ReconnectionStrategy(
          initialDelay: Duration(milliseconds: 10),
          jitter: 0,
        ),
      );
    });

    tearDown(() async {
      await client.close();
    });

    test('subscribes and receives data', () async {
      final stream = client.subscribe('btcusdt@aggTrade');
      final future = stream.first; // Listen

      // Wait for connection
      for (var i = 0; i < 20; i++) {
        if (provider.lastChannel != null) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      final channel = provider.lastChannel;
      expect(channel, isNotNull, reason: 'Channel should be connected');
      channel!.addFromServer(jsonEncode({
        'stream': 'btcusdt@aggTrade',
        'data': {'p': '50000', 'q': '1.0'}
      }));

      final event = await future;
      expect((event as Map<String, dynamic>)['p'], '50000');
    });

    test('multiplexes multiple streams', () async {
      final s1 = client.subscribe('btcusdt@aggTrade').listen((_) {});
      final s2 = client.subscribe('ethusdt@aggTrade').listen((_) {});

      for (var i = 0; i < 20; i++) {
        if (provider.lastUrl != null &&
            provider.lastUrl!.queryParameters.containsKey('streams')) {
          final streams = provider.lastUrl!.queryParameters['streams']!;
          if (streams.contains('btcusdt@aggTrade') &&
              streams.contains('ethusdt@aggTrade')) break;
        }
        await Future.delayed(Duration(milliseconds: 50));
      }

      final url = provider.lastUrl.toString();
      expect(url, contains('btcusdt%40aggTrade'));
      expect(url, contains('ethusdt%40aggTrade'));

      await s1.cancel();
      await s2.cancel();
    });

    test('reconnects on connection loss', () async {
      final sub = client.subscribe('btcusdt@aggTrade').listen((_) {});

      for (var i = 0; i < 20; i++) {
        if (provider.lastChannel != null) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      final firstChannel = provider.lastChannel!;
      expect(provider.connectCount, 1);

      firstChannel.closeFromServer();

      for (var i = 0; i < 20; i++) {
        if (provider.connectCount > 1) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      expect(provider.connectCount, greaterThanOrEqualTo(2));
      await sub.cancel();
    });

    test('emits StreamLagWarning when lagging', () async {
      StreamLagWarning? receivedWarning;
      client = WebSocketStreamClient(
        baseUrl: Uri.parse('wss://stream.binance.com:9443'),
        provider: provider,
        maxBufferSize: 2,
        hooks: BinanceObservabilityHooks(
          logger: PrintLogger(),
          onStreamLag: (w) => receivedWarning = w,
        ),
      );

      final sub = client.subscribe('btcusdt@aggTrade').listen((_) {
        // Slow consumer
      });

      for (var i = 0; i < 20; i++) {
        if (provider.lastChannel != null) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      final channel = provider.lastChannel!;

      for (var i = 0; i < 100; i++) {
        channel.addFromServer(jsonEncode({
          'stream': 'btcusdt@aggTrade',
          'data': {'i': i}
        }));
      }

      for (var i = 0; i < 20; i++) {
        if (receivedWarning != null) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      expect(receivedWarning, isNotNull);
      expect(receivedWarning!.streamName, 'btcusdt@aggTrade');
      await sub.cancel();
    });
  });

  group('WebSocketApiClient', () {
    late MockWebSocketProvider provider;
    late WebSocketApiClient client;

    setUp(() {
      provider = MockWebSocketProvider();
      client = WebSocketApiClient(
        baseUrl: Uri.parse('wss://ws-api.binance.com/ws-api/v3'),
        provider: provider,
        hooks: BinanceObservabilityHooks(
          logger: PrintLogger(),
        ),
      );
    });

    tearDown(() async {
      await client.close();
    });

    test('sends request and correlates response', () async {
      final requestFuture = client.sendRequest('ping');

      for (var i = 0; i < 20; i++) {
        if (provider.lastChannel != null) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      final channel = provider.lastChannel!;

      final sentMessage = await channel.sentMessages.first;
      final requestData = jsonDecode(sentMessage);
      final id = requestData['id'];

      channel
          .addFromServer(jsonEncode({'id': id, 'status': 200, 'result': {}}));

      final response = await requestFuture;
      expect((response as Map<String, dynamic>)['status'], 200);
    });

    test('performs logon and resumes after reconnect', () async {
      final credentials = HmacCredentials(
        apiKey: 'key',
        apiSecret: SecureByteBuffer(Uint8List.fromList([1, 2, 3])),
      );

      provider.onConnect = (uri) async {
        final channel = MockWebSocketChannel();
        channel.sentMessages.listen((msg) {
          final data = jsonDecode(msg);
          if (data['method'] == 'session.logon') {
            channel.addFromServer(jsonEncode({
              'id': data['id'],
              'status': 200,
              'result': {'apiKey': 'key'}
            }));
          }
        });
        return channel;
      };

      await client.logon(credentials);
      expect(client.IsLoggedIn, isTrue);
      expect(provider.connectCount, 1);

      // Simulate connection loss
      final firstChannel = provider.lastChannel!;
      firstChannel.closeFromServer();

      // Client should auto-reconnect and re-logon
      for (var i = 0; i < 20; i++) {
        if (provider.connectCount > 1 && client.IsLoggedIn) break;
        await Future.delayed(Duration(milliseconds: 50));
      }

      expect(provider.connectCount, greaterThanOrEqualTo(2));
      expect(client.IsLoggedIn, isTrue);
    });
  });
}
