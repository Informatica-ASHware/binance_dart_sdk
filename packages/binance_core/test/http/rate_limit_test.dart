import 'package:binance_core/src/http/rate_limit.dart';
import 'package:test/test.dart';

void main() {
  group('RateLimitTracker', () {
    late RateLimitTracker tracker;

    setUp(() {
      tracker = RateLimitTracker();
    });

    test('updates from headers correctly', () {
      tracker.updateFromHeaders({
        'X-MBX-USED-WEIGHT-1M': '500',
        'X-MBX-LIMIT-1M': '1000',
      });

      expect(
        tracker.shouldThrottle(100),
        isFalse,
      ); // (500+100)/1000 = 0.6 <= 0.8
      expect(
        tracker.shouldThrottle(301),
        isTrue,
      ); // (500+301)/1000 = 0.801 > 0.8
    });

    test('waitIfNecessary delays when throttling is needed', () async {
      tracker.updateFromHeaders({
        'X-MBX-USED-WEIGHT-1M': '801',
        'X-MBX-LIMIT-1M': '1000',
      });

      final stopwatch = Stopwatch()..start();
      await tracker.waitIfNecessary(0);
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
    });

    test('reset clears weights', () {
      tracker.updateFromHeaders({
        'X-MBX-USED-WEIGHT-1M': '900',
        'X-MBX-LIMIT-1M': '1000',
      });
      expect(tracker.shouldThrottle(0), isTrue);

      tracker.reset();
      expect(tracker.shouldThrottle(0), isFalse);
    });
  });
}
