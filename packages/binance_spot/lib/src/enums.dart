/// Spot API enums.
library;

/// Order side.
enum Side {
  /// Buy.
  buy('BUY'),

  /// Sell.
  sell('SELL');

  const Side(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Order type.
enum OrderType {
  /// Limit order.
  limit('LIMIT'),

  /// Market order.
  market('MARKET'),

  /// Stop loss order.
  stopLoss('STOP_LOSS'),

  /// Stop loss limit order.
  stopLossLimit('STOP_LOSS_LIMIT'),

  /// Take profit order.
  takeProfit('TAKE_PROFIT'),

  /// Take profit limit order.
  takeProfitLimit('TAKE_PROFIT_LIMIT'),

  /// Limit maker order.
  limitMaker('LIMIT_MAKER');

  const OrderType(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Time in force.
enum TimeInForce {
  /// Good 'Til Canceled.
  gtc('GTC'),

  /// Immediate Or Cancel.
  ioc('IOC'),

  /// Fill Or Kill.
  fok('FOK');

  const TimeInForce(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// New order response type.
enum NewOrderRespType {
  /// Ack.
  ack('ACK'),

  /// Result.
  result('RESULT'),

  /// Full.
  full('FULL');

  const NewOrderRespType(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Self-trade prevention mode.
enum SelfTradePreventionMode {
  /// Expire taker.
  expireTaker('EXPIRE_TAKER'),

  /// Expire maker.
  expireMaker('EXPIRE_MAKER'),

  /// Expire both.
  expireBoth('EXPIRE_BOTH'),

  /// None.
  none('NONE'),

  /// Transfer.
  transfer('TRANSFER');

  const SelfTradePreventionMode(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Order status.
enum OrderStatus {
  /// New order.
  newOrder('NEW'),

  /// Partially filled.
  partiallyFilled('PARTIALLY_FILLED'),

  /// Filled.
  filled('FILLED'),

  /// Canceled.
  canceled('CANCELED'),

  /// Pending cancel.
  pendingCancel('PENDING_CANCEL'),

  /// Rejected.
  rejected('REJECTED'),

  /// Expired.
  expired('EXPIRED'),

  /// Expired in match (STP).
  expiredInMatch('EXPIRED_IN_MATCH');

  const OrderStatus(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Order execution type.
enum OrderExecutionType {
  /// New order.
  newExecution('NEW'),

  /// Canceled.
  canceled('CANCELED'),

  /// Replaced.
  replaced('REPLACED'),

  /// Rejected.
  rejected('REJECTED'),

  /// Trade.
  trade('TRADE'),

  /// Expired.
  expired('EXPIRED'),

  /// Amendment.
  amendment('AMENDMENT');

  const OrderExecutionType(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Contingency type.
enum ContingencyType {
  /// OCO (One-Cancels-the-Other).
  oco('OCO');

  const ContingencyType(this.value);

  /// String value used by Binance API.
  final String value;

  @override
  String toString() => value;
}
