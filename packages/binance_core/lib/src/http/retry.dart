import 'dart:math' as math;

import 'package:binance_core/src/error.dart';
import 'package:http/http.dart' as http;

/// Defines a policy for retrying failed requests.
abstract interface class RetryPolicy {
  /// Whether a request should be retried based on the [response], [error]
  /// and [attempt].
  bool shouldRetry({
    required int attempt,
    http.BaseResponse? response,
    BinanceError? error,
  });

  /// Returns the delay before the next retry attempt.
  Duration getDelay(int attempt);
}

/// A retry policy with exponential backoff and jitter.
class ExponentialBackoffRetryPolicy implements RetryPolicy {
  /// Creates an [ExponentialBackoffRetryPolicy].
  ExponentialBackoffRetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.random = math.Random.secure,
  });

  /// The maximum number of retry attempts.
  final int maxAttempts;

  /// The initial delay before the first retry.
  final Duration initialDelay;

  /// The maximum delay between retries.
  final Duration maxDelay;

  /// The random number generator for jitter.
  final math.Random Function() random;

  @override
  bool shouldRetry({
    required int attempt,
    http.BaseResponse? response,
    BinanceError? error,
  }) {
    if (attempt >= maxAttempts) return false;

    if (error != null) {
      if (error is BinanceNetworkError) return true;
      if (error is BinanceApiError && error.code == -1003) return true;
    }

    if (response != null) {
      final statusCode = response.statusCode;
      // Retry on 5xx errors (server errors)
      if (statusCode >= 500 && statusCode < 600) return true;
      // 429 is also a transient error that should be retried after backoff
      if (statusCode == 429) return true;
    }

    return false;
  }

  @override
  Duration getDelay(int attempt) {
    final exp = math.min(attempt, 31); // Prevent overflow
    final delayMs = initialDelay.inMilliseconds * math.pow(2, exp);
    final jitter = random().nextDouble() * 0.2 + 0.9; // 0.9 to 1.1
    final finalDelay = (delayMs * jitter).toInt();

    return Duration(
      milliseconds: math.min(finalDelay, maxDelay.inMilliseconds),
    );
  }
}
