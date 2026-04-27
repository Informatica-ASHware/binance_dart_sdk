import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_margin/src/enums.dart';
import 'package:meta/meta.dart';

/// Represents cross margin account information.
@immutable
final class MarginAccount {
  /// Creates a [MarginAccount] instance.
  const MarginAccount({
    required this.borrowEnabled,
    required this.marginLevel,
    required this.totalAssetOfBtc,
    required this.totalLiabilityOfBtc,
    required this.totalNetAssetOfBtc,
    required this.tradeEnabled,
    required this.transferEnabled,
    required this.userAssets,
  });

  /// Creates a [MarginAccount] from a JSON map.
  factory MarginAccount.fromJson(Map<String, dynamic> json) {
    return MarginAccount(
      borrowEnabled: json['borrowEnabled'] as bool,
      marginLevel: Decimal.parse(json['marginLevel'] as String),
      totalAssetOfBtc: Decimal.parse(json['totalAssetOfBtc'] as String),
      totalLiabilityOfBtc: Decimal.parse(json['totalLiabilityOfBtc'] as String),
      totalNetAssetOfBtc: Decimal.parse(json['totalNetAssetOfBtc'] as String),
      tradeEnabled: json['tradeEnabled'] as bool,
      transferEnabled: json['transferEnabled'] as bool,
      userAssets: (json['userAssets'] as List<dynamic>)
          .map((a) => MarginAsset.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Borrow enabled.
  final bool borrowEnabled;

  /// Margin level.
  final Decimal marginLevel;

  /// Total asset in BTC.
  final Decimal totalAssetOfBtc;

  /// Total liability in BTC.
  final Decimal totalLiabilityOfBtc;

  /// Total net asset in BTC.
  final Decimal totalNetAssetOfBtc;

  /// Trade enabled.
  final bool tradeEnabled;

  /// Transfer enabled.
  final bool transferEnabled;

  /// User assets.
  final List<MarginAsset> userAssets;
}

/// Represents a margin asset.
@immutable
final class MarginAsset {
  /// Creates a [MarginAsset] instance.
  const MarginAsset({
    required this.asset,
    required this.borrowed,
    required this.free,
    required this.interest,
    required this.locked,
    required this.netAsset,
  });

  /// Creates a [MarginAsset] from a JSON map.
  factory MarginAsset.fromJson(Map<String, dynamic> json) {
    return MarginAsset(
      asset: Asset(json['asset'] as String),
      borrowed: Decimal.parse(json['borrowed'] as String),
      free: Decimal.parse(json['free'] as String),
      interest: Decimal.parse(json['interest'] as String),
      locked: Decimal.parse(json['locked'] as String),
      netAsset: Decimal.parse(json['netAsset'] as String),
    );
  }

  /// Asset.
  final Asset asset;

  /// Borrowed amount.
  final Decimal borrowed;

  /// Free amount.
  final Decimal free;

  /// Interest amount.
  final Decimal interest;

  /// Locked amount.
  final Decimal locked;

  /// Net asset amount.
  final Decimal netAsset;
}

/// Represents isolated margin account information.
@immutable
final class IsolatedMarginAccount {
  /// Creates an [IsolatedMarginAccount] instance.
  const IsolatedMarginAccount({
    required this.assets,
    required this.totalAssetOfBtc,
    required this.totalLiabilityOfBtc,
    required this.totalNetAssetOfBtc,
  });

  /// Creates an [IsolatedMarginAccount] from a JSON map.
  factory IsolatedMarginAccount.fromJson(Map<String, dynamic> json) {
    return IsolatedMarginAccount(
      assets: (json['assets'] as List<dynamic>)
          .map((a) => IsolatedMarginAsset.fromJson(a as Map<String, dynamic>))
          .toList(),
      totalAssetOfBtc: json['totalAssetOfBtc'] != null
          ? Decimal.parse(json['totalAssetOfBtc'] as String)
          : null,
      totalLiabilityOfBtc: json['totalLiabilityOfBtc'] != null
          ? Decimal.parse(json['totalLiabilityOfBtc'] as String)
          : null,
      totalNetAssetOfBtc: json['totalNetAssetOfBtc'] != null
          ? Decimal.parse(json['totalNetAssetOfBtc'] as String)
          : null,
    );
  }

  /// Assets in isolated margin account.
  final List<IsolatedMarginAsset> assets;

  /// Total asset in BTC.
  final Decimal? totalAssetOfBtc;

  /// Total liability in BTC.
  final Decimal? totalLiabilityOfBtc;

  /// Total net asset in BTC.
  final Decimal? totalNetAssetOfBtc;
}

/// Represents an isolated margin asset pair.
@immutable
final class IsolatedMarginAsset {
  /// Creates an [IsolatedMarginAsset] instance.
  const IsolatedMarginAsset({
    required this.symbol,
    required this.quoteAsset,
    required this.baseAsset,
    required this.isolatedCreated,
    required this.marginLevel,
    required this.marginLevelStatus,
    required this.marginRatio,
    required this.indexPrice,
    required this.liquidatePrice,
    required this.liquidateRate,
    required this.tradeEnabled,
    required this.enabled,
  });

  /// Creates an [IsolatedMarginAsset] from a JSON map.
  factory IsolatedMarginAsset.fromJson(Map<String, dynamic> json) {
    return IsolatedMarginAsset(
      symbol: Symbol(json['symbol'] as String),
      quoteAsset: IsolatedAssetDetails.fromJson(
        json['quoteAsset'] as Map<String, dynamic>,
      ),
      baseAsset: IsolatedAssetDetails.fromJson(
        json['baseAsset'] as Map<String, dynamic>,
      ),
      isolatedCreated: json['isolatedCreated'] as bool,
      marginLevel: Decimal.parse(json['marginLevel'] as String),
      marginLevelStatus: json['marginLevelStatus'] as String,
      marginRatio: Decimal.parse(json['marginRatio'] as String),
      indexPrice: Decimal.parse(json['indexPrice'] as String),
      liquidatePrice: Decimal.parse(json['liquidatePrice'] as String),
      liquidateRate: Decimal.parse(json['liquidateRate'] as String),
      tradeEnabled: json['tradeEnabled'] as bool,
      enabled: json['enabled'] as bool,
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Quote asset details.
  final IsolatedAssetDetails quoteAsset;

  /// Base asset details.
  final IsolatedAssetDetails baseAsset;

  /// Isolated created.
  final bool isolatedCreated;

  /// Margin level.
  final Decimal marginLevel;

  /// Margin level status.
  final String marginLevelStatus;

  /// Margin ratio.
  final Decimal marginRatio;

  /// Index price.
  final Decimal indexPrice;

  /// Liquidate price.
  final Decimal liquidatePrice;

  /// Liquidate rate.
  final Decimal liquidateRate;

  /// Trade enabled.
  final bool tradeEnabled;

  /// Enabled.
  final bool enabled;
}

/// Represents isolated asset details.
@immutable
final class IsolatedAssetDetails {
  /// Creates an [IsolatedAssetDetails] instance.
  const IsolatedAssetDetails({
    required this.asset,
    required this.borrowEnabled,
    required this.borrowed,
    required this.free,
    required this.interest,
    required this.locked,
    required this.netAsset,
    required this.netAssetOfBtc,
    required this.repayEnabled,
    required this.totalAsset,
  });

  /// Creates an [IsolatedAssetDetails] from a JSON map.
  factory IsolatedAssetDetails.fromJson(Map<String, dynamic> json) {
    return IsolatedAssetDetails(
      asset: Asset(json['asset'] as String),
      borrowEnabled: json['borrowEnabled'] as bool,
      borrowed: Decimal.parse(json['borrowed'] as String),
      free: Decimal.parse(json['free'] as String),
      interest: Decimal.parse(json['interest'] as String),
      locked: Decimal.parse(json['locked'] as String),
      netAsset: Decimal.parse(json['netAsset'] as String),
      netAssetOfBtc: Decimal.parse(json['netAssetOfBtc'] as String),
      repayEnabled: json['repayEnabled'] as bool,
      totalAsset: Decimal.parse(json['totalAsset'] as String),
    );
  }

  /// Asset.
  final Asset asset;

  /// Borrow enabled.
  final bool borrowEnabled;

  /// Borrowed amount.
  final Decimal borrowed;

  /// Free amount.
  final Decimal free;

  /// Interest amount.
  final Decimal interest;

  /// Locked amount.
  final Decimal locked;

  /// Net asset amount.
  final Decimal netAsset;

  /// Net asset in BTC.
  final Decimal netAssetOfBtc;

  /// Repay enabled.
  final bool repayEnabled;

  /// Total asset amount.
  final Decimal totalAsset;
}

/// Represents a margin loan.
@immutable
final class MarginLoan {
  /// Creates a [MarginLoan] instance.
  const MarginLoan({
    required this.asset,
    required this.principal,
    required this.timestamp,
    required this.status,
    this.txId,
  });

  /// Creates a [MarginLoan] from a JSON map.
  factory MarginLoan.fromJson(Map<String, dynamic> json) {
    return MarginLoan(
      asset: Asset(json['asset'] as String),
      principal: Decimal.parse(json['principal'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      status: MarginLoanStatus.values.firstWhere(
        (e) => e.value == json['status'],
      ),
      txId: json['txId'] as int?,
    );
  }

  /// Asset.
  final Asset asset;

  /// Principal amount.
  final Decimal principal;

  /// Timestamp.
  final DateTime timestamp;

  /// Status.
  final MarginLoanStatus status;

  /// Transaction ID.
  final int? txId;
}

/// Represents a margin repayment.
@immutable
final class MarginRepayment {
  /// Creates a [MarginRepayment] instance.
  const MarginRepayment({
    required this.asset,
    required this.amount,
    required this.principal,
    required this.interest,
    required this.timestamp,
    required this.status,
    this.txId,
  });

  /// Creates a [MarginRepayment] from a JSON map.
  factory MarginRepayment.fromJson(Map<String, dynamic> json) {
    return MarginRepayment(
      asset: Asset(json['asset'] as String),
      amount: Decimal.parse(json['amount'] as String),
      principal: Decimal.parse(json['principal'] as String),
      interest: Decimal.parse(json['interest'] as String),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      status: MarginLoanStatus.values.firstWhere(
        (e) => e.value == json['status'],
      ),
      txId: json['txId'] as int?,
    );
  }

  /// Asset.
  final Asset asset;

  /// Amount.
  final Decimal amount;

  /// Principal amount.
  final Decimal principal;

  /// Interest amount.
  final Decimal interest;

  /// Timestamp.
  final DateTime timestamp;

  /// Status.
  final MarginLoanStatus status;

  /// Transaction ID.
  final int? txId;
}

/// Represents margin risk level.
@immutable
final class MarginRiskLevel {
  /// Creates a [MarginRiskLevel] instance.
  const MarginRiskLevel({
    required this.level,
    required this.text,
  });

  /// Creates a [MarginRiskLevel] from a JSON map.
  factory MarginRiskLevel.fromJson(Map<String, dynamic> json) {
    return MarginRiskLevel(
      level: Decimal.parse(json['level'] as String),
      text: json['text'] as String,
    );
  }

  /// Level.
  final Decimal level;

  /// Text representation.
  final String text;
}
