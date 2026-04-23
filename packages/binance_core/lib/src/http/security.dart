import 'package:meta/meta.dart';

/// Defines the security type of a Binance API endpoint.
///
/// Each security type determines what credentials and signing
/// logic are required for the request.
@immutable
sealed class BinanceSecurityType {
  const BinanceSecurityType();

  /// Endpoint is public and does not require an API key or signature.
  static const public = PublicSecurityType();

  /// Endpoint requires an API key and a signature.
  static const signed = SignedSecurityType();

  /// Endpoint requires an API key but no signature (e.g., USER_DATA).
  static const userData = UserDataSecurityType();

  /// Endpoint requires an API key but no signature (e.g., MARKET_DATA).
  static const marketData = MarketDataSecurityType();

  /// Endpoint requires an API key but no signature (e.g., USER_STREAM).
  static const userStream = UserStreamSecurityType();
}

/// Public security type.
final class PublicSecurityType extends BinanceSecurityType {
  /// Creates a [PublicSecurityType].
  const PublicSecurityType();
}

/// Signed security type (TRADE or USER_DATA requiring signature).
final class SignedSecurityType extends BinanceSecurityType {
  /// Creates a [SignedSecurityType].
  const SignedSecurityType();
}

/// User Data security type.
final class UserDataSecurityType extends BinanceSecurityType {
  /// Creates a [UserDataSecurityType].
  const UserDataSecurityType();
}

/// Market Data security type.
final class MarketDataSecurityType extends BinanceSecurityType {
  /// Creates a [MarketDataSecurityType].
  const MarketDataSecurityType();
}

/// User Stream security type.
final class UserStreamSecurityType extends BinanceSecurityType {
  /// Creates a [UserStreamSecurityType].
  const UserStreamSecurityType();
}
