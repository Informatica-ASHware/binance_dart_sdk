import 'package:meta/meta.dart';

/// Represents a trading pair symbol (e.g., BTCUSDT).
@immutable
final class Symbol {
  /// Creates a [Symbol] from the given string [value].
  const Symbol(this.value);

  /// The symbol's string representation.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Symbol &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a currency or asset (e.g., BTC, USDT).
@immutable
final class Asset {
  /// Creates an [Asset] from the given string [value].
  const Asset(this.value);

  /// The asset's string representation.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Asset &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a price value in the Binance ecosystem.
@immutable
final class Price {
  /// Creates a [Price] from a [Decimal] value.
  const Price(this.value);

  /// Creates a [Price] from a [String].
  factory Price.fromString(String value) => Price(Decimal.parse(value));

  /// The numeric value of the price.
  final Decimal value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Price &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Represents a quantity value in the Binance ecosystem.
@immutable
final class Quantity {
  /// Creates a [Quantity] from a [Decimal] value.
  const Quantity(this.value);

  /// Creates a [Quantity] from a [String].
  factory Quantity.fromString(String value) => Quantity(Decimal.parse(value));

  /// The numeric value of the quantity.
  final Decimal value;

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

/// Represents a percentage value.
@immutable
final class Percentage {
  /// Creates a [Percentage] from a [Decimal] value.
  const Percentage(this.value);

  /// Creates a [Percentage] from a [String].
  factory Percentage.fromString(String value) =>
      Percentage(Decimal.parse(value));

  /// The numeric value of the percentage.
  final Decimal value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Percentage &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value%';
}

/// Represents a monetary value, combining an amount and an asset.
@immutable
final class Money {
  /// Creates a [Money] instance.
  const Money(this.amount, this.asset);

  /// The numeric amount.
  final Decimal amount;

  /// The asset associated with the amount.
  final Asset asset;

  /// Adds [other] to this [Money].
  ///
  /// Throws an [ArgumentError] if assets do not match.
  Money operator +(Money other) {
    _checkAssetMatch(other);
    return Money(amount + other.amount, asset);
  }

  /// Subtracts [other] from this [Money].
  ///
  /// Throws an [ArgumentError] if assets do not match.
  Money operator -(Money other) {
    _checkAssetMatch(other);
    return Money(amount - other.amount, asset);
  }

  void _checkAssetMatch(Money other) {
    if (asset != other.asset) {
      throw ArgumentError(
        'Cannot operate on different assets: $asset and ${other.asset}',
      );
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Money &&
          runtimeType == other.runtimeType &&
          amount == other.amount &&
          asset == other.asset;

  @override
  int get hashCode => amount.hashCode ^ asset.hashCode;

  @override
  String toString() => '$amount $asset';
}

/// Represents a Binance order ID.
@immutable
final class OrderId {
  /// Creates an [OrderId].
  const OrderId(this.value);

  /// The numeric order ID.
  final int value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

/// Represents a client-defined order ID.
@immutable
final class ClientOrderId {
  /// Creates a [ClientOrderId].
  const ClientOrderId(this.value);

  /// The string client order ID.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClientOrderId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Represents a Unix timestamp in milliseconds.
@immutable
final class Timestamp {
  /// Creates a [Timestamp].
  const Timestamp(this.milliseconds);

  /// Creates a [Timestamp] from the current time.
  factory Timestamp.now() => Timestamp(DateTime.now().millisecondsSinceEpoch);

  /// The milliseconds since Unix epoch.
  final int milliseconds;

  /// Converts this [Timestamp] to a [DateTime].
  DateTime toDateTime() => DateTime.fromMillisecondsSinceEpoch(milliseconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Timestamp &&
          runtimeType == other.runtimeType &&
          milliseconds == other.milliseconds;

  @override
  int get hashCode => milliseconds.hashCode;

  @override
  String toString() => milliseconds.toString();
}

/// Simple Decimal implementation to avoid external dependencies for basic
/// parsing and to maintain immutability.
@immutable
final class Decimal implements Comparable<Decimal> {
  /// Internal constructor for [Decimal].
  const Decimal._(this.units, this.precision);

  /// Parses a string into a [Decimal].
  factory Decimal.parse(String value) {
    final parts = value.split('.');
    if (parts.length > 2) throw FormatException('Invalid decimal: $value');

    final whole = parts[0];
    final fraction = parts.length == 2 ? parts[1] : '';
    var precision = fraction.length;

    var units = BigInt.parse(whole + fraction);

    // Normalize: remove trailing zeros
    while (precision > 0 &&
        units != BigInt.zero &&
        units % BigInt.from(10) == BigInt.zero) {
      units ~/= BigInt.from(10);
      precision--;
    }
    if (units == BigInt.zero) precision = 0;

    return Decimal._(units, precision);
  }

  /// Decimal representing zero.
  static final Decimal zero = Decimal.parse('0');

  /// The raw units of the decimal.
  final BigInt units;

  /// The number of decimal places.
  final int precision;

  /// Adds [other] to this [Decimal].
  Decimal operator +(Decimal other) {
    final maxPrecision =
        precision > other.precision ? precision : other.precision;
    final thisUnits = units * BigInt.from(10).pow(maxPrecision - precision);
    final otherUnits =
        other.units * BigInt.from(10).pow(maxPrecision - other.precision);
    return Decimal.parse(
      _formatRaw(thisUnits + otherUnits, maxPrecision),
    );
  }

  /// Subtracts [other] from this [Decimal].
  Decimal operator -(Decimal other) {
    final maxPrecision =
        precision > other.precision ? precision : other.precision;
    final thisUnits = units * BigInt.from(10).pow(maxPrecision - precision);
    final otherUnits =
        other.units * BigInt.from(10).pow(maxPrecision - other.precision);
    return Decimal.parse(
      _formatRaw(thisUnits - otherUnits, maxPrecision),
    );
  }

  /// Multiplies this [Decimal] by [other].
  Decimal operator *(Decimal other) {
    return Decimal.parse(
      _formatRaw(units * other.units, precision + other.precision),
    );
  }

  static String _formatRaw(BigInt units, int precision) {
    if (precision == 0) return units.toString();
    final isNegative = units < BigInt.zero;
    final absoluteUnits = units.abs();
    final s = absoluteUnits.toString().padLeft(precision + 1, '0');
    final splitIndex = s.length - precision;
    final result = '${s.substring(0, splitIndex)}.${s.substring(splitIndex)}';
    return isNegative ? '-$result' : result;
  }

  @override
  int compareTo(Decimal other) {
    final maxPrecision =
        precision > other.precision ? precision : other.precision;
    final thisUnits = units * BigInt.from(10).pow(maxPrecision - precision);
    final otherUnits =
        other.units * BigInt.from(10).pow(maxPrecision - other.precision);
    return thisUnits.compareTo(otherUnits);
  }

  /// Returns true if this is less than [other].
  bool operator <(Decimal other) => compareTo(other) < 0;

  /// Returns true if this is less than or equal to [other].
  bool operator <=(Decimal other) => compareTo(other) <= 0;

  /// Returns true if this is greater than [other].
  bool operator >(Decimal other) => compareTo(other) > 0;

  /// Returns true if this is greater than or equal to [other].
  bool operator >=(Decimal other) => compareTo(other) >= 0;

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
  String toString() => _formatRaw(units, precision);
}
