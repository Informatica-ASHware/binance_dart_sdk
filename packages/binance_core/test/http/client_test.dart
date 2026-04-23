import 'dart:convert';
import 'dart:typed_data';
import 'package:binance_core/src/auth.dart';
import 'package:binance_core/src/enums.dart';
import 'package:binance_core/src/error.dart';
import 'package:binance_core/src/http/client.dart';
import 'package:binance_core/src/http/interceptor.dart';
import 'package:binance_core/src/http/request.dart';
import 'package:binance_core/src/http/retry.dart';
import 'package:binance_core/src/http/security.dart';
import 'package:binance_core/src/security.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('DefaultBinanceHttpClient', () {
    test('successful request returns data', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'key': 'value'}), 200);
      });

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final result = await client.send(
        const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
      );

      expect(result.isSuccess, isTrue);
      result.fold(
        onSuccess: (data) => expect(data['key'], 'value'),
        onFailure: (error) => fail('Should not fail'),
      );
    });

    test('handles 429 Too Many Requests', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          'Rate limit exceeded',
          429,
          headers: {
            'retry-after': '1',
          },
        );
      });

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final result = await client.send(
        const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) {
          expect(error.message, contains('Too many requests'));
        },
      );
    });

    test('handles 418 IP Banned and blocks subsequent requests', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response(
          'Banned',
          418,
          headers: {
            'retry-after': '1',
          },
        );
      });

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      // First call triggers the ban
      await client.send(
        const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
      );
      expect(callCount, 1);

      // Second call should fail immediately without hitting the network
      final result = await client.send(
        const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
      );
      expect(callCount, 1);
      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) {
          expect(error.message, contains('IP is currently banned'));
        },
      );
    });

    test(
      'circuit breaker blocks requests after failures',
      () async {
        final mockClient400 = MockClient((request) async {
          return http.Response('Error', 400);
        });

        final client = DefaultBinanceHttpClient(
          environment: BinanceEnvironment.mainnet,
          httpClient: mockClient400,
          retryPolicy: const ExponentialBackoffRetryPolicy(maxAttempts: 0),
        );

        for (var i = 0; i < 5; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          await client.send(
            const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
          );
        }

        final result = await client.send(
          const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
        );

        expect(result.isFailure, isTrue);
        result.fold(
          onSuccess: (_) => fail('Should fail'),
          onFailure: (error) {
            expect(error.message, contains('Circuit breaker open'));
          },
        );
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test('interceptors are called in order', () async {
      final mockClient = MockClient((request) async {
        return http.Response(json.encode({'key': 'value'}), 200);
      });

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final log = <String>[];
      client.addInterceptor(_TestInterceptor('A', log));
      client.addInterceptor(_TestInterceptor('B', log));

      await client.send(
        const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
      );

      expect(
        log,
        ['onRequest A', 'onRequest B', 'onResponse B', 'onResponse A'],
      );
    });

    test('signed request includes timestamp and signature', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.queryParameters, contains('timestamp'));
        expect(request.url.queryParameters, contains('signature'));
        expect(request.headers['X-MBX-APIKEY'], 'test-api-key');
        return http.Response(json.encode({'result': 'ok'}), 200);
      });

      final credentials = HmacCredentials(
        apiKey: 'test-api-key',
        apiSecret:
            SecureByteBuffer(Uint8List.fromList(utf8.encode('test-secret'))),
      );

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
        credentials: credentials,
        signer: HmacRequestSigner(credentials),
      );

      final result = await client.send(
        const BinanceRequest(
          method: HttpMethod.get,
          path: '/api/v3/account',
          securityType: BinanceSecurityType.signed,
        ),
      );

      expect(result.isSuccess, isTrue);
    });

    test('handles API error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({'code': -2010, 'msg': 'New order rejected'}),
          400,
        );
      });

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final result = await client.send(
        const BinanceRequest(method: HttpMethod.post, path: '/api/v3/order'),
      );

      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should fail'),
        onFailure: (error) {
          expect(error, isA<BinanceApiError>());
          expect((error as BinanceApiError).code, -2010);
        },
      );
    });

    test('handles network error', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Network unreachable');
      });

      final client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final result = await client.send(
        const BinanceRequest(method: HttpMethod.get, path: '/api/v3/ping'),
      );

      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (_) => null, onFailure: (e) => e),
        isA<BinanceNetworkError>(),
      );
    });

    test('BinanceRequestBuilder builds request correctly', () {
      final request = BinanceRequest.builder()
          .method(HttpMethod.post)
          .path('/api/v3/order')
          .queryParam('symbol', 'BTCUSDT')
          .queryParams({'quantity': '1.0', 'price': '50000'})
          .body({'extra': 'data'})
          .securityType(BinanceSecurityType.signed)
          .weight(10)
          .build();

      expect(request.method, HttpMethod.post);
      expect(request.path, '/api/v3/order');
      expect(request.queryParams['symbol'], 'BTCUSDT');
      expect(request.queryParams['quantity'], '1.0');
      expect(request.queryParams['price'], '50000');
      expect(request.body, {'extra': 'data'});
      expect(request.securityType, isA<SignedSecurityType>());
      expect(request.weight, 10);
    });
  });
}

class _TestInterceptor implements BinanceInterceptor {
  _TestInterceptor(this.name, this.log);
  final String name;
  final List<String> log;

  @override
  Future<BinanceRequest> onRequest(BinanceRequest request) async {
    log.add('onRequest $name');
    return request;
  }

  @override
  Future<http.Response> onResponse(http.Response response) async {
    log.add('onResponse $name');
    return response;
  }

  @override
  Future<void> onError(Object error, StackTrace stackTrace) async {
    log.add('onError $name');
  }
}
