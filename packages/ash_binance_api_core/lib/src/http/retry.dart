import 'package:ash_binance_api_core/src/error.dart';
import 'package:http/http.dart' as http;

/// Strategy for retrying failed HTTP requests.
abstract interface class RetryPolicy {
  /// Whether the request should be retried.
  bool shouldRetry({
    required int attempt,
    http.BaseResponse? response,
    BinanceError? error,
  });

  /// The delay before the next retry attempt.
  Duration getDelay(int attempt);
}

/// Exponential backoff retry policy.
class ExponentialBackoffRetryPolicy implements RetryPolicy {
  /// Creates an [ExponentialBackoffRetryPolicy].
  const ExponentialBackoffRetryPolicy({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 1),
  });

  /// Maximum number of retry attempts.
  final int maxAttempts;

  /// Base delay for exponential backoff.
  final Duration baseDelay;

  @override
  bool shouldRetry({
    required int attempt,
    http.BaseResponse? response,
    BinanceError? error,
  }) {
    if (attempt >= maxAttempts) return false;

    if (response != null) {
      final statusCode = response.statusCode;
      // Retry on rate limits (429) and server errors (5xx)
      // Note: 418 (IP Banned) is handled separately in client.dart but we can
      // check here too
      if (statusCode == 429 || statusCode >= 500) {
        return true;
      }
    }

    if (error is BinanceNetworkError) {
      return true;
    }

    return false;
  }

  @override
  Duration getDelay(int attempt) {
    return baseDelay * (1 << attempt);
  }
}
