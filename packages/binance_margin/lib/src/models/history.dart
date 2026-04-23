import 'package:binance_core/binance_core.dart';
import 'package:meta/meta.dart';

/// Represents liability interest history.
@immutable
final class LiabilityInterest {
  /// Creates a [LiabilityInterest] instance.
  const LiabilityInterest({
    required this.asset,
    required this.interest,
    required this.interestRate,
    required this.principal,
    required this.type,
    required this.timestamp,
  });

  /// Creates a [LiabilityInterest] from a JSON map.
  factory LiabilityInterest.fromJson(Map<String, dynamic> json) {
    return LiabilityInterest(
      asset: Asset(json['asset'] as String),
      interest: Decimal.parse(json['interest'] as String),
      interestRate: Decimal.parse(json['interestRate'] as String),
      principal: Decimal.parse(json['principal'] as String),
      type: json['type'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
    );
  }

  /// Asset.
  final Asset asset;

  /// Interest amount.
  final Decimal interest;

  /// Interest rate.
  final Decimal interestRate;

  /// Principal amount.
  final Decimal principal;

  /// Type.
  final String type;

  /// Timestamp.
  final DateTime timestamp;
}

/// Represents capital flow.
@immutable
final class CapitalFlow {
  /// Creates a [CapitalFlow] instance.
  const CapitalFlow({
    required this.id,
    required this.asset,
    required this.amount,
    required this.type,
    required this.timestamp,
    this.tranId,
  });

  /// Creates a [CapitalFlow] from a JSON map.
  factory CapitalFlow.fromJson(Map<String, dynamic> json) {
    return CapitalFlow(
      id: json['id'] as int,
      asset: Asset(json['asset'] as String),
      amount: Decimal.parse(json['amount'] as String),
      type: json['type'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      tranId: json['tranId'] as int?,
    );
  }

  /// ID.
  final int id;

  /// Asset.
  final Asset asset;

  /// Amount.
  final Decimal amount;

  /// Type.
  final String type;

  /// Timestamp.
  final DateTime timestamp;

  /// Transaction ID.
  final int? tranId;
}

/// Represents dust log.
@immutable
final class DustLog {
  /// Creates a [DustLog] instance.
  const DustLog({
    required this.totalCount,
    required this.userAssetDribblets,
  });

  /// Creates a [DustLog] from a JSON map.
  factory DustLog.fromJson(Map<String, dynamic> json) {
    return DustLog(
      totalCount: json['total'] as int,
      userAssetDribblets: (json['userAssetDribblets'] as List<dynamic>)
          .map((d) => DustLogEntry.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Total count.
  final int totalCount;

  /// Dribblet entries.
  final List<DustLogEntry> userAssetDribblets;
}

/// Represents a single dust log entry.
@immutable
final class DustLogEntry {
  /// Creates a [DustLogEntry] instance.
  const DustLogEntry({
    required this.operateTime,
    required this.totalTransferedAmount,
    required this.totalServiceChargeAmount,
    required this.transId,
    required this.userAssetDribbletDetails,
  });

  /// Creates a [DustLogEntry] from a JSON map.
  factory DustLogEntry.fromJson(Map<String, dynamic> json) {
    return DustLogEntry(
      operateTime:
          DateTime.fromMillisecondsSinceEpoch(json['operateTime'] as int),
      totalTransferedAmount:
          Decimal.parse(json['totalTransferedAmount'] as String),
      totalServiceChargeAmount:
          Decimal.parse(json['totalServiceChargeAmount'] as String),
      transId: json['transId'] as int,
      userAssetDribbletDetails:
          (json['userAssetDribbletDetails'] as List<dynamic>)
              .map((d) => DustLogDetail.fromJson(d as Map<String, dynamic>))
              .toList(),
    );
  }

  /// Operation time.
  final DateTime operateTime;

  /// Total transferred amount.
  final Decimal totalTransferedAmount;

  /// Total service charge amount.
  final Decimal totalServiceChargeAmount;

  /// Transaction ID.
  final int transId;

  /// Detail entries.
  final List<DustLogDetail> userAssetDribbletDetails;
}

/// Represents a single dust log detail.
@immutable
final class DustLogDetail {
  /// Creates a [DustLogDetail] instance.
  const DustLogDetail({
    required this.transId,
    required this.serviceChargeAmount,
    required this.amount,
    required this.operateTime,
    required this.transferedAmount,
    required this.fromAsset,
  });

  /// Creates a [DustLogDetail] from a JSON map.
  factory DustLogDetail.fromJson(Map<String, dynamic> json) {
    return DustLogDetail(
      transId: json['transId'] as int,
      serviceChargeAmount: Decimal.parse(json['serviceChargeAmount'] as String),
      amount: Decimal.parse(json['amount'] as String),
      operateTime:
          DateTime.fromMillisecondsSinceEpoch(json['operateTime'] as int),
      transferedAmount: Decimal.parse(json['transferedAmount'] as String),
      fromAsset: Asset(json['fromAsset'] as String),
    );
  }

  /// Transaction ID.
  final int transId;

  /// Service charge amount.
  final Decimal serviceChargeAmount;

  /// Amount.
  final Decimal amount;

  /// Operation time.
  final DateTime operateTime;

  /// Transferred amount.
  final Decimal transferedAmount;

  /// From asset.
  final Asset fromAsset;
}
