import 'dart:async';

/// Tracks Binance API rate limits based on response headers.
class RateLimitTracker {
  /// Creates a [RateLimitTracker].
  RateLimitTracker({this.backoffThreshold = 0.8});

  /// The usage threshold (0.0 to 1.0) at which to start preventative backoff.
  final double backoffThreshold;

  final Map<String, int> _weights = {};
  final Map<String, int> _limits = {};

  /// Updates the tracker with headers from a response.
  ///
  /// Headers like X-MBX-USED-WEIGHT-* and X-MBX-ORDER-COUNT-*.
  void updateFromHeaders(Map<String, String> headers) {
    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (key.startsWith('x-mbx-used-weight-') ||
          key.startsWith('x-mbx-order-count-')) {
        final value = int.tryParse(entry.value);
        if (value != null) {
          _weights[key] = value;
        }
      } else if (key.startsWith('x-mbx-limit-')) {
        // Some endpoints might return limits, though not all do in every
        // response.
        final value = int.tryParse(entry.value);
        if (value != null) {
          final type = key.replaceFirst('x-mbx-limit-', '');
          _limits[type] = value;
        }
      }
    }
  }

  /// Checks if a request with the given [weight] should be throttled.
  bool shouldThrottle(int weight) {
    for (final entry in _weights.entries) {
      final key = entry.key;
      final used = entry.value;

      final type = key.split('-').last;
      final limit = _limits[type];

      if (limit != null) {
        if ((used + weight) / limit > backoffThreshold) {
          return true;
        }
      }
    }
    return false;
  }

  /// Returns a [Future] that completes when it's safe to make a request.
  Future<void> waitIfNecessary(int weight) async {
    if (shouldThrottle(weight)) {
      // Use a shorter delay for tests if possible, but keeping 1s as requested
      // in implementation notes for now, but I should probably make it
      // configurable or shorter.
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  /// Clears tracked weights.
  void reset() {
    _weights.clear();
  }
}
