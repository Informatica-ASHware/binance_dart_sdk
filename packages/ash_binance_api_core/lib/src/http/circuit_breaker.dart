/// States of a circuit breaker.
enum CircuitState {
  /// The circuit is closed and requests are allowed.
  closed,

  /// The circuit is open and requests are blocked.
  open,

  /// The circuit is half-open and a limited number of requests are allowed
  /// to test if the service has recovered.
  halfOpen,
}

/// A circuit breaker that prevents requests to a failing endpoint.
class CircuitBreaker {
  /// Creates a [CircuitBreaker].
  CircuitBreaker({
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 30),
  });

  /// The number of consecutive failures before opening the circuit.
  final int failureThreshold;

  /// The duration to wait before transitioning from [CircuitState.open] to
  /// [CircuitState.halfOpen].
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  /// The current state of the circuit.
  CircuitState get state {
    if (_state == CircuitState.open && _lastFailureTime != null) {
      if (DateTime.now().difference(_lastFailureTime!) > resetTimeout) {
        return CircuitState.halfOpen;
      }
    }
    return _state;
  }

  /// Whether the circuit allows requests.
  bool get isOpen => state == CircuitState.open;

  /// Records a successful request.
  void recordSuccess() {
    _failureCount = 0;
    _state = CircuitState.closed;
    _lastFailureTime = null;
  }

  /// Records a failed request.
  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;
    }
  }
}

/// Manages circuit breakers for different endpoints.
class CircuitBreakerRegistry {
  /// Creates a [CircuitBreakerRegistry].
  CircuitBreakerRegistry();

  final Map<String, CircuitBreaker> _breakers = {};

  /// Gets the circuit breaker for a specific [endpoint].
  CircuitBreaker getBreaker(String endpoint) {
    return _breakers.putIfAbsent(endpoint, CircuitBreaker.new);
  }
}
