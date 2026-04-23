import 'dart:math' as math;
import 'package:binance_core/src/http/retry.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('ExponentialBackoffRetryPolicy', () {
    test('shouldRetry returns true for 5xx errors', () {
      final policy = ExponentialBackoffRetryPolicy();
      final response = http.Response('', 500);
      expect(policy.shouldRetry(response, 0), isTrue);
    });

    test('shouldRetry returns false for 4xx errors', () {
      final policy = ExponentialBackoffRetryPolicy();
      final response = http.Response('', 400);
      expect(policy.shouldRetry(response, 0), isFalse);
    });

    test('shouldRetry returns false after max attempts', () {
      final policy = ExponentialBackoffRetryPolicy(maxAttempts: 2);
      final response = http.Response('', 500);
      expect(policy.shouldRetry(response, 0), isTrue);
      expect(policy.shouldRetry(response, 1), isTrue);
      expect(policy.shouldRetry(response, 2), isFalse);
    });

    test('getDelay increases exponentially', () {
      final policy = ExponentialBackoffRetryPolicy(
        initialDelay: const Duration(milliseconds: 100),
        random: () => _FixedRandom(1), // No jitter adjustment
      );

      // (2^0 * 100 * 1.1) = 110
      expect(policy.getDelay(0).inMilliseconds, 110);
      // (2^1 * 100 * 1.1) = 220
      expect(policy.getDelay(1).inMilliseconds, 220);
      // (2^2 * 100 * 1.1) = 440
      expect(policy.getDelay(2).inMilliseconds, 440);
    });
  });
}

class _FixedRandom implements math.Random {
  _FixedRandom(this.value);
  final double value;

  @override
  bool nextBool() => true;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => 0;
}
