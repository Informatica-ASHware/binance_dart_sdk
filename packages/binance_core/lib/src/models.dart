import 'package:meta/meta.dart';

/// Represents a trading pair symbol (e.g., BTCUSDT).
@immutable
final class Symbol {
  /// The symbol's string representation.
  final String value;

  /// Creates a [Symbol] from the given string [value].
  const Symbol(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Symbol && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a price value in the Binance ecosystem.
@immutable
final class Price {
  /// The numeric value of the price.
  final Decimal value;

  /// Creates a [Price] from a [Decimal] value.
  const Price(this.value);

  /// Creates a [Price] from a [String].
  factory Price.fromString(String value) => Price(Decimal.parse(value));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Price && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Represents a quantity value in the Binance ecosystem.
@immutable
final class Quantity {
  /// The numeric value of the quantity.
  final Decimal value;

  /// Creates a [Quantity] from a [Decimal] value.
  const Quantity(this.value);

  /// Creates a [Quantity] from a [String].
  factory Quantity.fromString(String value) => Quantity(Decimal.parse(value));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quantity &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Simple Decimal implementation to avoid external dependencies for basic parsing
/// and to maintain immutability.
/// Note: In a real scenario, we might use a package like 'decimal', but the DoD
/// mentions 0% Flutter dependencies and Dart Puro.
@immutable
final class Decimal {
  final BigInt units;
  final int precision;

  const Decimal._(this.units, this.precision);

  /// Parses a string into a [Decimal].
  static Decimal parse(String value) {
    final parts = value.split('.');
    if (parts.length > 2) throw FormatException('Invalid decimal: $value');

    final whole = parts[0];
    final fraction = parts.length == 2 ? parts[1] : '';
    final precision = fraction.length;

    final units = BigInt.parse(whole + fraction);
    return Decimal._(units, precision);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Decimal &&
          runtimeType == other.runtimeType &&
          units == other.units &&
          precision == other.precision;

  @override
  int get hashCode => units.hashCode ^ precision.hashCode;

  @override
  String toString() {
    if (precision == 0) return units.toString();

    final isNegative = units < BigInt.zero;
    final absoluteUnits = units.abs();
    final s = absoluteUnits.toString().padLeft(precision + 1, '0');
    final splitIndex = s.length - precision;
    final result =
        '${s.substring(0, splitIndex)}.${s.substring(splitIndex)}';
    return isNegative ? '-$result' : result;
  }
}
