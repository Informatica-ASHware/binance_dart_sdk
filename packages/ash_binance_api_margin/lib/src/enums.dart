/// Margin API enums.
library;

/// Margin side effect type.
enum MarginSideEffect {
  /// No side effect.
  noSideEffect('NO_SIDE_EFFECT'),

  /// Margin buy.
  marginBuy('MARGIN_BUY'),

  /// Auto repay.
  autoRepay('AUTO_REPAY'),

  /// Auto borrow and repay.
  autoBorrowRepay('AUTO_BORROW_REPAY');

  const MarginSideEffect(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Margin transfer type.
enum MarginTransferType {
  /// Roll in (Spot to Margin).
  rollIn(1),

  /// Roll out (Margin to Spot).
  rollOut(2);

  const MarginTransferType(this.value);

  /// Integer value used by Binance API.
  final int value;
}

/// Margin loan status.
enum MarginLoanStatus {
  /// Pending.
  pending('PENDING'),

  /// Completed.
  completed('COMPLETED'),

  /// Failed.
  failed('FAILED');

  const MarginLoanStatus(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Interest rate state.
enum InterestRateState {
  /// Valid.
  valid('VALID'),

  /// Invalid.
  invalid('INVALID');

  const InterestRateState(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Isolated margin account status.
enum IsolatedMarginAccountStatus {
  /// Enabled.
  enabled('ENABLED'),

  /// Disabled.
  disabled('DISABLED');

  const IsolatedMarginAccountStatus(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}
