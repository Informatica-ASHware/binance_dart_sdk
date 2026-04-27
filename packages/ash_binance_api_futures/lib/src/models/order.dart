import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_futures/src/enums.dart';
import 'package:meta/meta.dart';

/// Represents a futures order.
@immutable
final class FuturesOrder {
  /// Creates a [FuturesOrder].
  const FuturesOrder({
    required this.symbol,
    required this.orderId,
    required this.clientOrderId,
    required this.price,
    required this.origQty,
    required this.executedQty,
    required this.cumQuote,
    required this.status,
    required this.timeInForce,
    required this.type,
    required this.side,
    required this.stopPrice,
    required this.workingType,
    required this.time,
    required this.updateTime,
    this.avgPrice,
    this.positionSide,
    this.reduceOnly,
    this.closePosition,
    this.activatePrice,
    this.priceRate,
  });

  /// Creates a [FuturesOrder] from a JSON map.
  factory FuturesOrder.fromJson(Map<String, dynamic> json) {
    return FuturesOrder(
      symbol: Symbol(json['symbol'] as String),
      orderId: json['orderId'] as int,
      clientOrderId: json['clientOrderId'] as String,
      price: Decimal.parse(json['price'] as String),
      origQty: Decimal.parse(json['origQty'] as String),
      executedQty: Decimal.parse(json['executedQty'] as String),
      cumQuote: Decimal.parse(json['cumQuote'] as String),
      status: json['status'] as String,
      timeInForce: json['timeInForce'] as String,
      type: json['type'] as String,
      side: json['side'] as String,
      stopPrice: Decimal.parse(json['stopPrice'] as String),
      workingType: WorkingType.values.firstWhere(
        (e) => e.value == json['workingType'],
        orElse: () => WorkingType.contractPrice,
      ),
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      updateTime:
          DateTime.fromMillisecondsSinceEpoch(json['updateTime'] as int),
      avgPrice: json['avgPrice'] != null
          ? Decimal.parse(json['avgPrice'] as String)
          : null,
      positionSide: json['positionSide'] != null
          ? PositionSide.values
              .firstWhere((e) => e.value == json['positionSide'])
          : null,
      reduceOnly: json['reduceOnly'] as bool?,
      closePosition: json['closePosition'] as bool?,
      activatePrice: json['activatePrice'] != null
          ? Decimal.parse(json['activatePrice'] as String)
          : null,
      priceRate: json['priceRate'] != null
          ? Decimal.parse(json['priceRate'] as String)
          : null,
    );
  }

  /// The symbol.
  final Symbol symbol;

  /// Order ID.
  final int orderId;

  /// Client order ID.
  final String clientOrderId;

  /// Price.
  final Decimal price;

  /// Original quantity.
  final Decimal origQty;

  /// Executed quantity.
  final Decimal executedQty;

  /// Cumulative quote asset quantity.
  final Decimal cumQuote;

  /// Order status.
  final String status;

  /// Time in force.
  final String timeInForce;

  /// Order type.
  final String type;

  /// Order side.
  final String side;

  /// Stop price.
  final Decimal stopPrice;

  /// Working type.
  final WorkingType workingType;

  /// Time the order was created.
  final DateTime time;

  /// Time the order was last updated.
  final DateTime updateTime;

  /// Average filled price.
  final Decimal? avgPrice;

  /// Position side.
  final PositionSide? positionSide;

  /// Whether it is reduce only.
  final bool? reduceOnly;

  /// Whether it is close position.
  final bool? closePosition;

  /// Activation price for trailing stop orders.
  final Decimal? activatePrice;

  /// Callback rate for trailing stop orders.
  final Decimal? priceRate;
}
