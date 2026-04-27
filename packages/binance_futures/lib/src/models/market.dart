import 'package:ash_binance_api_core/binance_core.dart';
import 'package:meta/meta.dart';

/// Represents a funding rate.
@immutable
final class FundingRate {
  /// Creates a [FundingRate].
  const FundingRate({
    required this.symbol,
    required this.fundingRate,
    required this.fundingTime,
    this.markPrice,
  });

  /// Creates a [FundingRate] from a JSON map.
  factory FundingRate.fromJson(Map<String, dynamic> json) {
    return FundingRate(
      symbol: Symbol(json['symbol'] as String),
      fundingRate: Decimal.parse(json['fundingRate'] as String),
      fundingTime:
          DateTime.fromMillisecondsSinceEpoch(json['fundingTime'] as int),
      markPrice: json['markPrice'] != null
          ? Decimal.parse(json['markPrice'] as String)
          : null,
    );
  }

  /// The symbol.
  final Symbol symbol;

  /// The funding rate.
  final Decimal fundingRate;

  /// The funding time.
  final DateTime fundingTime;

  /// The mark price at funding time.
  final Decimal? markPrice;
}

/// Represents a mark price.
@immutable
final class MarkPrice {
  /// Creates a [MarkPrice].
  const MarkPrice({
    required this.symbol,
    required this.markPrice,
    required this.indexPrice,
    required this.estimatedSettlePrice,
    required this.lastFundingRate,
    required this.nextFundingTime,
    required this.time,
  });

  /// Creates a [MarkPrice] from a JSON map.
  factory MarkPrice.fromJson(Map<String, dynamic> json) {
    return MarkPrice(
      symbol: Symbol(json['symbol'] as String),
      markPrice: Decimal.parse(json['markPrice'] as String),
      indexPrice: Decimal.parse(json['indexPrice'] as String),
      estimatedSettlePrice:
          Decimal.parse(json['estimatedSettlePrice'] as String),
      lastFundingRate: Decimal.parse(json['lastFundingRate'] as String),
      nextFundingTime:
          DateTime.fromMillisecondsSinceEpoch(json['nextFundingTime'] as int),
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
    );
  }

  /// The symbol.
  final Symbol symbol;

  /// The mark price.
  final Decimal markPrice;

  /// The index price.
  final Decimal indexPrice;

  /// The estimated settle price.
  final Decimal estimatedSettlePrice;

  /// The last funding rate.
  final Decimal lastFundingRate;

  /// The next funding time.
  final DateTime nextFundingTime;

  /// The time of the mark price.
  final DateTime time;
}

/// Represents an income record.
@immutable
final class Income {
  /// Creates an [Income].
  const Income({
    required this.symbol,
    required this.incomeType,
    required this.income,
    required this.asset,
    required this.info,
    required this.time,
    required this.tranId,
    required this.tradeId,
  });

  /// Creates an [Income] from a JSON map.
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      symbol: Symbol(json['symbol'] as String),
      incomeType: json['incomeType'] as String,
      income: Decimal.parse(json['income'] as String),
      asset: Asset(json['asset'] as String),
      info: json['info'] as String,
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      tranId: json['tranId'].toString(),
      tradeId: json['tradeId']?.toString(),
    );
  }

  /// The symbol.
  final Symbol symbol;

  /// The income type.
  final String incomeType;

  /// The income amount.
  final Decimal income;

  /// The asset of the income.
  final Asset asset;

  /// Additional info.
  final String info;

  /// The time of the income.
  final DateTime time;

  /// Transaction ID.
  final String tranId;

  /// Trade ID.
  final String? tradeId;
}
