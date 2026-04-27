/// Enums for Binance Futures.
library;

/// Margin type.
enum MarginType {
  /// Isolated margin.
  isolated('ISOLATED'),

  /// Cross margin.
  cross('CROSSED');

  const MarginType(this.value);

  /// The string value of the margin type.
  final String value;

  @override
  String toString() => value;
}

/// Position side.
enum PositionSide {
  /// Both sides (one-way mode).
  both('BOTH'),

  /// Long side (hedge mode).
  long('LONG'),

  /// Short side (hedge mode).
  short('SHORT');

  const PositionSide(this.value);

  /// The string value of the position side.
  final String value;

  @override
  String toString() => value;
}

/// Working type for conditional orders.
enum WorkingType {
  /// Mark price.
  markPrice('MARK_PRICE'),

  /// Contract price.
  contractPrice('CONTRACT_PRICE');

  const WorkingType(this.value);

  /// The string value of the working type.
  final String value;

  @override
  String toString() => value;
}

/// Contract type.
enum ContractType {
  /// Perpetual.
  perpetual('PERPETUAL'),

  /// Current quarter.
  currentQuarter('CURRENT_QUARTER'),

  /// Next quarter.
  nextQuarter('NEXT_QUARTER'),

  /// Current month.
  currentMonth('CURRENT_MONTH'),

  /// Next month.
  nextMonth('NEXT_MONTH');

  const ContractType(this.value);

  /// The string value of the contract type.
  final String value;

  @override
  String toString() => value;
}

/// Contract status.
enum ContractStatus {
  /// Pending trading.
  pendingTrading('PENDING_TRADING'),

  /// Trading.
  trading('TRADING'),

  /// Pre-delivering.
  preDelivering('PRE_DELIVERING'),

  /// Delivering.
  delivering('DELIVERING'),

  /// Delivered.
  delivered('DELIVERED'),

  /// Cancelled.
  cancelled('CANCELLED'),

  /// Pre-settle.
  preSettle('PRE_SETTLE'),

  /// Settling.
  settling('SETTLING'),

  /// Settled.
  settled('SETTLED');

  const ContractStatus(this.value);

  /// The string value of the contract status.
  final String value;

  @override
  String toString() => value;
}
