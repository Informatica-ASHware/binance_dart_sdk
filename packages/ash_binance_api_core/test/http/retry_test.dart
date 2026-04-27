import 'package:ash_binance_api_core/src/error.dart';
import 'package:ash_binance_api_core/src/http/retry.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('ExponentialBackoffRetryPolicy', () {
    test('should retry on 429', () {
      const policy = ExponentialBackoffRetryPolicy();
      final response = http.Response('', 429);

      expect(policy.shouldRetry(response: response, attempt: 0), isTrue);
    });

    test('should retry on 500', () {
      const policy = ExponentialBackoffRetryPolicy();
      final response = http.Response('', 500);

      expect(policy.shouldRetry(response: response, attempt: 0), isTrue);
    });

    test('should NOT retry after max attempts', () {
      const policy = ExponentialBackoffRetryPolicy();
      final response = http.Response('', 500);

      expect(policy.shouldRetry(response: response, attempt: 3), isFalse);
    });

    test('should retry on network error', () {
      const policy = ExponentialBackoffRetryPolicy();

      expect(
        policy.shouldRetry(
          attempt: 0,
          error: const BinanceNetworkError(message: 'Network issue'),
        ),
        isTrue,
      );
    });

    test('calculates exponential delay', () {
      const policy = ExponentialBackoffRetryPolicy();

      expect(policy.getDelay(0), const Duration(seconds: 1));
      expect(policy.getDelay(1), const Duration(seconds: 2));
      expect(policy.getDelay(2), const Duration(seconds: 4));
    });
  });
}
