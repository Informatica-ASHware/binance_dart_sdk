import 'package:binance_core/src/http/circuit_breaker.dart';
import 'package:test/test.dart';

void main() {
  group('CircuitBreaker', () {
    test('transitions to open after threshold failures', () {
      final breaker = CircuitBreaker(failureThreshold: 2);
      expect(breaker.state, CircuitState.closed);

      breaker.recordFailure();
      expect(breaker.state, CircuitState.closed);

      breaker.recordFailure();
      expect(breaker.state, CircuitState.open);
      expect(breaker.isOpen, isTrue);
    });

    test('transitions back to closed after success', () {
      final breaker = CircuitBreaker(failureThreshold: 1)..recordFailure();
      expect(breaker.state, CircuitState.open);

      breaker.recordSuccess();
      expect(breaker.state, CircuitState.closed);
    });

    test('transitions to half-open after timeout', () async {
      final breaker = CircuitBreaker(
        failureThreshold: 1,
        resetTimeout: const Duration(milliseconds: 10),
      )..recordFailure();
      expect(breaker.state, CircuitState.open);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(breaker.state, CircuitState.halfOpen);
    });
  });

  group('CircuitBreakerRegistry', () {
    test('returns same breaker for same endpoint', () {
      final registry = CircuitBreakerRegistry();
      final b1 = registry.getBreaker('/api/v3/ping');
      final b2 = registry.getBreaker('/api/v3/ping');
      expect(b1, same(b2));
    });

    test('returns different breaker for different endpoints', () {
      final registry = CircuitBreakerRegistry();
      final b1 = registry.getBreaker('/api/v3/ping');
      final b2 = registry.getBreaker('/api/v3/time');
      expect(b1, isNot(same(b2)));
    });
  });
}
