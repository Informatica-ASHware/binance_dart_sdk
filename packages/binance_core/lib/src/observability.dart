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

/// Hooks for observability in the Binance SDK.
@immutable
final class BinanceObservabilityHooks {
  /// Creates [BinanceObservabilityHooks].
  const BinanceObservabilityHooks({
    this.logger = const NoOpBinanceLogger(),
    this.onTimeSyncWarning,
  });

  /// The logger to use.
  final BinanceLogger logger;

  /// Callback when a time synchronization warning occurs.
  /// The [offset] is the detected time offset in milliseconds.
  /// The [jitter] is the estimated network jitter in milliseconds.
  final void Function(int offset, double jitter)? onTimeSyncWarning;
}
