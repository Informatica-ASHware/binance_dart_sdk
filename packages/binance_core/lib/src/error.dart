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
sealed class BinanceApiError extends BinanceError {
  /// Creates a [BinanceApiError].
  const BinanceApiError({required this.code, required String message})
      : super(message);

  /// Creates a specific [BinanceApiError] based on the [code].
  factory BinanceApiError.fromCode({
    required int code,
    required String message,
  }) {
    return switch (code) {
      -1003 => BinanceRateLimitError(message: message),
      -1021 => BinanceTimestampError(message: message),
      -1022 => BinanceSignatureError(message: message),
      -1121 => BinanceInvalidSymbol(message: message),
      -2010 => BinanceOrderRejected(message: message),
      -2011 => BinanceCancelRejected(message: message),
      -2013 => BinanceOrderNotFound(message: message),
      -2014 || -2015 => BinanceInvalidApiKey(code: code, message: message),
      -21015 => BinanceEndpointGone(message: message),
      -4109 => BinanceAccountInactive(message: message),
      _ => GenericBinanceApiError(code: code, message: message),
    };
  }

  /// The error code returned by Binance.
  final int code;

  @override
  String toString() => 'BinanceApiError(code: $code, message: $message)';
}

/// Generic Binance API error for codes not explicitly handled.
final class GenericBinanceApiError extends BinanceApiError {
  /// Creates a [GenericBinanceApiError].
  const GenericBinanceApiError({required super.code, required super.message});
}

/// Error code -1022: Signature for this request is not valid.
final class BinanceSignatureError extends BinanceApiError {
  /// Creates a [BinanceSignatureError].
  const BinanceSignatureError({required super.message}) : super(code: -1022);
}

/// Error code -1021: Timestamp for this request is outside of the recvWindow.
final class BinanceTimestampError extends BinanceApiError {
  /// Creates a [BinanceTimestampError].
  const BinanceTimestampError({required super.message}) : super(code: -1021);
}

/// Error code -1003: Too many requests; IP banned; Rate limit reached.
final class BinanceRateLimitError extends BinanceApiError {
  /// Creates a [BinanceRateLimitError].
  const BinanceRateLimitError({required super.message}) : super(code: -1003);
}

/// Error code -1121: Invalid symbol.
final class BinanceInvalidSymbol extends BinanceApiError {
  /// Creates a [BinanceInvalidSymbol].
  const BinanceInvalidSymbol({required super.message}) : super(code: -1121);
}

/// Error code -2010: New order rejected.
final class BinanceOrderRejected extends BinanceApiError {
  /// Creates a [BinanceOrderRejected].
  const BinanceOrderRejected({required super.message}) : super(code: -2010);
}

/// Error code -2011: Cancel rejected.
final class BinanceCancelRejected extends BinanceApiError {
  /// Creates a [BinanceCancelRejected].
  const BinanceCancelRejected({required super.message}) : super(code: -2011);
}

/// Error code -2013: Order does not exist.
final class BinanceOrderNotFound extends BinanceApiError {
  /// Creates a [BinanceOrderNotFound].
  const BinanceOrderNotFound({required super.message}) : super(code: -2013);
}

/// Error code -2014, -2015: API-key format invalid or cannot be found.
final class BinanceInvalidApiKey extends BinanceApiError {
  /// Creates a [BinanceInvalidApiKey].
  const BinanceInvalidApiKey({required super.code, required super.message});
}

/// Error code -21015: Service is offline.
final class BinanceEndpointGone extends BinanceApiError {
  /// Creates a [BinanceEndpointGone].
  const BinanceEndpointGone({required super.message}) : super(code: -21015);
}

/// Error code -4109: Account is inactive.
final class BinanceAccountInactive extends BinanceApiError {
  /// Creates a [BinanceAccountInactive].
  const BinanceAccountInactive({required super.message}) : super(code: -4109);
}

/// Represents an HTTP error with a status code.
final class BinanceHttpError extends BinanceError {
  /// Creates a [BinanceHttpError].
  const BinanceHttpError({required this.statusCode, required String message})
      : super(message);

  /// The HTTP status code.
  final int statusCode;

  @override
  String toString() =>
      'BinanceHttpError(statusCode: $statusCode, message: $message)';
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

/// Represents a client-side validation error.
final class BinanceValidationError extends BinanceError {
  /// Creates a [BinanceValidationError].
  const BinanceValidationError(super.message);
}

/// Represents an authentication or authorization error.
final class BinanceAuthError extends BinanceError {
  /// Creates a [BinanceAuthError].
  const BinanceAuthError(super.message);
}
