import 'package:meta/meta.dart';

/// Sealed class representing errors that can occur when interacting
/// with Binance.
@immutable
sealed class BinanceError {
  /// Creates a [BinanceError].
  const BinanceError(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => message;
}

/// Represents an error returned by the Binance API.
final class BinanceApiError extends BinanceError {
  /// Creates a [BinanceApiError].
  const BinanceApiError({required this.code, required String message})
      : super(message);

  /// The error code returned by Binance.
  final int code;

  @override
  String toString() => 'BinanceApiError(code: $code, message: $message)';
}

/// Represents a network-related error.
final class BinanceNetworkError extends BinanceError {
  /// Creates a [BinanceNetworkError].
  const BinanceNetworkError({required String message, this.cause})
      : super(message);

  /// The underlying cause of the network error.
  final Object? cause;

  @override
  String toString() => 'BinanceNetworkError(message: $message, cause: $cause)';
}

/// Represents an error during data parsing or validation.
final class BinanceParseError extends BinanceError {
  /// Creates a [BinanceParseError].
  const BinanceParseError(super.message);
}

/// Represents an authentication or authorization error.
final class BinanceAuthError extends BinanceError {
  /// Creates a [BinanceAuthError].
  const BinanceAuthError(super.message);
}
