import 'package:binance_core/binance_core.dart';
import 'package:binance_core/src/http/client.dart';
import 'package:binance_core/src/http/security.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('JSON Parser Fuzzing', () {
    late DefaultBinanceHttpClient client;

    BinanceRequest createRequest() {
      return const BinanceRequest(
        path: '/api/v3/ping',
        method: HttpMethod.get,
        securityType: BinanceSecurityType.public,
      );
    }

    test('Handles malformed JSON without crashing', () async {
      final mockClient = MockClient((request) async {
        return http.Response('invalid json {', 200);
      });

      client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      try {
        final result = await client.send(createRequest());
        expect(result.isFailure, isTrue);
        result.fold(
          onSuccess: (_) => fail('Should have failed'),
          onFailure: (error) {
            expect(error, isA<BinanceNetworkError>());
            expect(error.message, contains('Network error'));
          },
        );
      } catch (e) {
        fail('Client threw an unhandled exception: $e');
      }
    });

    test('Handles missing expected fields in error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"something": "else"}', 400);
      });

      client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final result = await client.send(createRequest());
      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should have failed'),
        onFailure: (error) {
          expect(error, isA<BinanceHttpError>());
        },
      );
    });

    test('Handles incorrect types in error response', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"code": "not_an_int", "msg": 123}', 400);
      });

      client = DefaultBinanceHttpClient(
        environment: BinanceEnvironment.mainnet,
        httpClient: mockClient,
      );

      final result = await client.send(createRequest());
      expect(result.isFailure, isTrue);
      result.fold(
        onSuccess: (_) => fail('Should have failed'),
        onFailure: (error) {
          expect(error, isA<BinanceHttpError>());
        },
      );
    });
  });
}
