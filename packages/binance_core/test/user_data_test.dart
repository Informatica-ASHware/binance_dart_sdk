import 'dart:async';
import 'dart:typed_data';

import 'package:binance_core/binance_core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockWebSocketApiClient extends Mock implements WebSocketApiClient {}

class MockBinanceHttpClient extends Mock implements BinanceHttpClient {}

class MockWebSocketStreamClient extends Mock implements WebSocketStreamClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      HmacCredentials(
        apiKey: 'test-api-key',
        apiSecret: SecureByteBuffer(Uint8List.fromList([])),
      ),
    );
    registerFallbackValue(
      const BinanceRequest(method: HttpMethod.post, path: ''),
    );
    registerFallbackValue(WebSocketApiClientStatus.connected);
  });

  group('SpotUserDataFeed', () {
    late MockWebSocketApiClient apiClient;
    late BinanceCredentials hmacCredentials;
    late SpotUserDataFeed feed;
    late StreamController<WebSocketApiClientStatus> statusController;

    setUp(() {
      hmacCredentials = HmacCredentials(
        apiKey: 'test-api-key',
        apiSecret: SecureByteBuffer(Uint8List.fromList([])),
      );
      apiClient = MockWebSocketApiClient();
      statusController = StreamController<WebSocketApiClientStatus>.broadcast();
      feed = SpotUserDataFeed(
        apiClient: apiClient,
        credentials: hmacCredentials,
      );

      when(() => apiClient.connect()).thenAnswer((_) async {});
      when(() => apiClient.logon(any())).thenAnswer((_) async {});
      when(() => apiClient.events).thenAnswer((_) => const Stream.empty());
      when(() => apiClient.status).thenAnswer((_) => statusController.stream);
      when(() => apiClient.logout()).thenAnswer((_) async {});
    });

    test('start() performs logon and subscribes', () async {
      when(
        () => apiClient.sendRequest('userDataStream.subscribe'),
      ).thenAnswer((_) async => {'status': 200});

      final statusFuture = feed.status.first;
      await feed.start();

      statusController.add(WebSocketApiClientStatus.authenticated);
      final status = await statusFuture;

      verify(() => apiClient.connect()).called(1);
      verify(() => apiClient.logon(hmacCredentials)).called(1);

      expect(status, isA<UserDataFeedConnected>());
    });

    test('re-subscribes on reconnection', () async {
      when(
        () => apiClient.sendRequest('userDataStream.subscribe'),
      ).thenAnswer((_) async => {'status': 200});

      await feed.start();

      // Simulate disconnect
      statusController.add(WebSocketApiClientStatus.disconnected);

      // Expected statuses: reconnecting, then connected (from re-subscribe),
      // then reconnectedAfterGap
      final statusFuture = feed.status.take(3).toList();

      // Simulate reconnect and authenticate
      statusController.add(WebSocketApiClientStatus.authenticated);

      final statuses = await statusFuture.timeout(const Duration(seconds: 1));

      // Should have called subscribe twice (once at start, once after reconnect)
      verify(() => apiClient.sendRequest('userDataStream.subscribe')).called(2);

      expect(statuses.any((s) => s is UserDataFeedReconnectedAfterGap), isTrue);
    });

    test('parses Spot events correctly', () async {
      final controller = StreamController<dynamic>.broadcast();
      when(() => apiClient.events).thenAnswer((_) => controller.stream);
      when(
        () => apiClient.sendRequest('userDataStream.subscribe'),
      ).thenAnswer((_) async => {'status': 200});

      await feed.start();
      statusController.add(WebSocketApiClientStatus.authenticated);

      final eventPromise = feed.events.first;

      controller.add({
        'e': 'outboundAccountPosition',
        'u': 123456789,
        'B': [
          {'a': 'BTC', 'f': '1.0', 'l': '0.1'},
        ],
      });

      final event = await eventPromise;
      expect(event, isA<AccountUpdate>());
    });
  });

  group('FuturesUserDataFeed', () {
    late MockBinanceHttpClient httpClient;
    late MockWebSocketStreamClient streamClient;
    late FuturesUserDataFeed feed;

    setUp(() {
      httpClient = MockBinanceHttpClient();
      streamClient = MockWebSocketStreamClient();
      feed = FuturesUserDataFeed(
        httpClient: httpClient,
        streamClient: streamClient,
        keepAliveInterval: const Duration(milliseconds: 100),
      );
    });

    test('start() obtains listenKey and subscribes', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success({'listenKey': 'test-listen-key'}),
      );
      when(
        () => streamClient.subscribe('test-listen-key'),
      ).thenAnswer((_) => const Stream.empty());

      await feed.start();

      verify(
        () => httpClient.send(
          any(
            that: isA<BinanceRequest>().having(
              (r) => r.method,
              'method',
              HttpMethod.post,
            ),
          ),
        ),
      ).called(1);
      verify(() => streamClient.subscribe('test-listen-key')).called(1);
    });

    test('parses Futures ACCOUNT_UPDATE correctly', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success({'listenKey': 'test-key'}),
      );
      final controller = StreamController<dynamic>.broadcast();
      when(
        () => streamClient.subscribe('test-key'),
      ).thenAnswer((_) => controller.stream);

      await feed.start();

      final eventPromise = feed.events.first;

      controller.add({
        'e': 'ACCOUNT_UPDATE',
        'E': 123456789,
        'a': {
          'm': 'ORDER',
          'B': [
            {'a': 'USDT', 'wb': '100.0'},
          ],
        },
      });

      final event = await eventPromise;
      expect(event, isA<AccountUpdate>());
      final accountUpdate = event as AccountUpdate;
      expect(accountUpdate.updateTime.millisecondsSinceEpoch, 123456789);
    });
  });
}
