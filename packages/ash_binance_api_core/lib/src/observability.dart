import 'package:ash_binance_api_core/src/ws/base.dart';
import 'package:meta/meta.dart';

/// Level of logging.
enum BinanceLogLevel {
  /// Information level.
  info,

  /// Warning level.
  warning,

  /// Error level.
  error,

  /// Debug level.
  debug,
}

/// Interface for logging in the Binance SDK.
abstract interface class BinanceLogger {
  /// Logs a message with the given level.
  void log(
    BinanceLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  });

  /// Logs an info message.
  void info(String message);

  /// Logs a warning message.
  void warning(String message);

  /// Logs an error message.
  void error(String message, {Object? error, StackTrace? stackTrace});

  /// Logs a debug message.
  void debug(String message);
}

/// Simple logger that does nothing.
final class NoOpBinanceLogger implements BinanceLogger {
  /// Creates a [NoOpBinanceLogger].
  const NoOpBinanceLogger();

  @override
  void log(
    BinanceLogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {}

  @override
  void debug(String message) {}

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}
}

/// Base class for telemetry events.
@immutable
sealed class BinanceTelemetryEvent {
  /// Creates a [BinanceTelemetryEvent].
  const BinanceTelemetryEvent(this.timestamp);

  /// The timestamp of the event.
  final DateTime timestamp;
}

/// Telemetry event when an HTTP request is sent.
final class RequestSent extends BinanceTelemetryEvent {
  /// Creates a [RequestSent] event.
  const RequestSent({
    required DateTime timestamp,
    required this.method,
    required this.url,
    this.weight,
  }) : super(timestamp);

  /// The HTTP method.
  final String method;

  /// The request URL.
  final Uri url;

  /// The weight of the request.
  final int? weight;

  @override
  String toString() =>
      'RequestSent(method: $method, url: $url, weight: $weight)';
}

/// Telemetry event when an HTTP response is received.
final class ResponseReceived extends BinanceTelemetryEvent {
  /// Creates a [ResponseReceived] event.
  const ResponseReceived({
    required DateTime timestamp,
    required this.statusCode,
    required this.url,
    required this.duration,
  }) : super(timestamp);

  /// The HTTP status code.
  final int statusCode;

  /// The request URL.
  final Uri url;

  /// The duration of the request.
  final Duration duration;

  @override
  String toString() => 'ResponseReceived(statusCode: $statusCode, '
      'url: $url, duration: $duration)';
}

/// Telemetry event when a retry attempt is made.
final class RetryAttempt extends BinanceTelemetryEvent {
  /// Creates a [RetryAttempt] event.
  const RetryAttempt({
    required DateTime timestamp,
    required this.attempt,
    required this.url,
    this.reason,
  }) : super(timestamp);

  /// The attempt number (1-based).
  final int attempt;

  /// The request URL.
  final Uri url;

  /// The reason for the retry.
  final String? reason;

  @override
  String toString() =>
      'RetryAttempt(attempt: $attempt, url: $url, reason: $reason)';
}

/// Telemetry event when a rate limit is hit.
final class RateLimitHit extends BinanceTelemetryEvent {
  /// Creates a [RateLimitHit] event.
  const RateLimitHit({
    required DateTime timestamp,
    required this.limitType,
    this.retryAfter,
  }) : super(timestamp);

  /// The type of rate limit hit.
  final String limitType;

  /// Optional duration to wait before retrying.
  final Duration? retryAfter;

  @override
  String toString() =>
      'RateLimitHit(limitType: $limitType, retryAfter: $retryAfter)';
}

/// Telemetry event when a WebSocket is reconnecting.
final class WebSocketReconnecting extends BinanceTelemetryEvent {
  /// Creates a [WebSocketReconnecting] event.
  const WebSocketReconnecting({
    required DateTime timestamp,
    required this.url,
    required this.attempt,
  }) : super(timestamp);

  /// The WebSocket URL.
  final Uri url;

  /// The reconnection attempt number.
  final int attempt;

  @override
  String toString() => 'WebSocketReconnecting(url: $url, attempt: $attempt)';
}

/// Telemetry event when a signature is computed.
final class SignatureComputed extends BinanceTelemetryEvent {
  /// Creates a [SignatureComputed] event.
  const SignatureComputed({
    required DateTime timestamp,
    required this.payload,
  }) : super(timestamp);

  /// The payload that was signed (sensitive data should be redacted in
  /// implementation).
  final String payload;

  @override
  String toString() => 'SignatureComputed(payload: $payload)';
}

/// Interface for receiving telemetry events.
// ignore: one_member_abstracts
abstract interface class BinanceTelemetrySink {
  /// Reports a telemetry event.
  void report(BinanceTelemetryEvent event);
}

/// Simple telemetry sink that does nothing.
final class NoOpBinanceTelemetrySink implements BinanceTelemetrySink {
  /// Creates a [NoOpBinanceTelemetrySink].
  const NoOpBinanceTelemetrySink();

  @override
  void report(BinanceTelemetryEvent event) {}
}

/// Hooks for observability in the Binance SDK.
@immutable
final class BinanceObservabilityHooks {
  /// Creates [BinanceObservabilityHooks].
  const BinanceObservabilityHooks({
    this.logger = const NoOpBinanceLogger(),
    this.telemetry = const NoOpBinanceTelemetrySink(),
    this.onStreamLag,
    this.onTimeSyncWarning,
  });

  /// The logger to use.
  final BinanceLogger logger;

  /// The telemetry sink to use.
  final BinanceTelemetrySink telemetry;

  /// Callback when a stream is lagging.
  final void Function(StreamLagWarning warning)? onStreamLag;

  /// Callback when a time synchronization warning occurs.
  ///
  /// The offset is the detected time offset in milliseconds.
  /// The jitter is the estimated network jitter in milliseconds.
  final void Function(int offset, double jitter)? onTimeSyncWarning;
}
