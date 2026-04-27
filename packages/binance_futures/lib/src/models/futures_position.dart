import 'package:ash_binance_api_core/binance_core.dart';
import 'package:ash_binance_api_futures/src/enums.dart';
import 'package:meta/meta.dart';

/// Represents a position in Binance Futures.
@immutable
final class FuturesPosition {
  /// Creates a [FuturesPosition].
  const FuturesPosition({
    required this.symbol,
    required this.initialMargin,
    required this.maintMargin,
    required this.unrealizedProfit,
    required this.positionInitialMargin,
    required this.openOrderInitialMargin,
    required this.leverage,
    required this.isolated,
    required this.entryPrice,
    required this.markPrice,
    required this.liquidationPrice,
    required this.maxNotional,
    required this.positionSide,
    required this.positionAmt,
    required this.notional,
    required this.isolatedWallet,
    required this.updateTime,
    required this.marginType,
    required this.isolatedMargin,
    this.bidNotional,
    this.askNotional,
    this.adlQuantile,
  });

  /// Creates a [FuturesPosition] from a JSON map.
  factory FuturesPosition.fromJson(Map<String, dynamic> json) {
    return FuturesPosition(
      symbol: Symbol(json['symbol'] as String),
      initialMargin: Decimal.parse(json['initialMargin'] as String),
      maintMargin: Decimal.parse(json['maintMargin'] as String),
      unrealizedProfit: Decimal.parse(json['unrealizedProfit'] as String),
      positionInitialMargin:
          Decimal.parse(json['positionInitialMargin'] as String),
      openOrderInitialMargin:
          Decimal.parse(json['openOrderInitialMargin'] as String),
      leverage: int.parse(json['leverage'] as String),
      isolated: json['isolated'] as bool,
      entryPrice: Decimal.parse(json['entryPrice'] as String),
      markPrice: Decimal.parse(json['markPrice'] as String),
      liquidationPrice: Decimal.parse(json['liquidationPrice'] as String),
      maxNotional: Decimal.parse(
        (json['maxNotionalValue'] ?? json['maxNotional'] ?? '0') as String,
      ),
      positionSide: PositionSide.values.firstWhere(
        (e) => e.value == json['positionSide'],
        orElse: () => PositionSide.both,
      ),
      positionAmt: Decimal.parse(json['positionAmt'] as String),
      notional: Decimal.parse(json['notional'] as String),
      isolatedWallet: Decimal.parse(json['isolatedWallet'] as String),
      updateTime:
          DateTime.fromMillisecondsSinceEpoch(json['updateTime'] as int),
      marginType: MarginType.values.firstWhere(
        (e) => e.value == (json['marginType'] as String? ?? '').toUpperCase(),
        orElse: () => MarginType.cross,
      ),
      isolatedMargin: Decimal.parse(json['isolatedMargin'] as String),
      bidNotional: json['bidNotional'] != null
          ? Decimal.parse(json['bidNotional'] as String)
          : null,
      askNotional: json['askNotional'] != null
          ? Decimal.parse(json['askNotional'] as String)
          : null,
      adlQuantile: json['adlQuantile'] as int?,
    );
  }

  /// The symbol of the position.
  final Symbol symbol;

  /// Initial margin required.
  final Decimal initialMargin;

  /// Maintenance margin required.
  final Decimal maintMargin;

  /// Unrealized profit.
  final Decimal unrealizedProfit;

  /// Initial margin of the position.
  final Decimal positionInitialMargin;

  /// Initial margin of open orders.
  final Decimal openOrderInitialMargin;

  /// Current leverage.
  final int leverage;

  /// Whether the position is isolated.
  final bool isolated;

  /// Average entry price.
  final Decimal entryPrice;

  /// Current mark price.
  final Decimal markPrice;

  /// Liquidation price.
  final Decimal liquidationPrice;

  /// Maximum notional value at current leverage.
  final Decimal maxNotional;

  /// Position side.
  final PositionSide positionSide;

  /// Position amount.
  final Decimal positionAmt;

  /// Notional value.
  final Decimal notional;

  /// Isolated wallet balance.
  final Decimal isolatedWallet;

  /// Last update time.
  final DateTime updateTime;

  /// Margin type.
  final MarginType marginType;

  /// Isolated margin.
  final Decimal isolatedMargin;

  /// Bid notional.
  final Decimal? bidNotional;

  /// Ask notional.
  final Decimal? askNotional;

  /// ADL quantile.
  final int? adlQuantile;
}
