import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_spot/src/enums.dart';
import 'package:meta/meta.dart';

/// Represents an account's information.
@immutable
final class AccountInfo {
  /// Creates an [AccountInfo] instance.
  const AccountInfo({
    required this.makerCommission,
    required this.takerCommission,
    required this.buyerCommission,
    required this.sellerCommission,
    required this.commissionRates,
    required this.canTrade,
    required this.canWithdraw,
    required this.canDeposit,
    required this.brokered,
    required this.requireSelfTradePrevention,
    required this.preventSor,
    required this.updateTime,
    required this.accountType,
    required this.balances,
    required this.permissions,
    required this.uid,
  });

  /// Creates an [AccountInfo] from a JSON map.
  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      makerCommission: json['makerCommission'] as int,
      takerCommission: json['takerCommission'] as int,
      buyerCommission: json['buyerCommission'] as int,
      sellerCommission: json['sellerCommission'] as int,
      commissionRates: json['commissionRates'] as Map<String, dynamic>,
      canTrade: json['canTrade'] as bool,
      canWithdraw: json['canWithdraw'] as bool,
      canDeposit: json['canDeposit'] as bool,
      brokered: json['brokered'] as bool,
      requireSelfTradePrevention: json['requireSelfTradePrevention'] as bool,
      preventSor: json['preventSor'] as bool,
      updateTime:
          DateTime.fromMillisecondsSinceEpoch(json['updateTime'] as int),
      accountType: json['accountType'] as String,
      balances: (json['balances'] as List<dynamic>)
          .map((b) => AssetBalance.fromJson(b as Map<String, dynamic>))
          .toList(),
      permissions: (json['permissions'] as List<dynamic>).cast<String>(),
      uid: json['uid'] as int,
    );
  }

  /// Maker commission.
  final int makerCommission;

  /// Taker commission.
  final int takerCommission;

  /// Buyer commission.
  final int buyerCommission;

  /// Seller commission.
  final int sellerCommission;

  /// Detailed commission rates.
  final Map<String, dynamic> commissionRates;

  /// Whether the account can trade.
  final bool canTrade;

  /// Whether the account can withdraw.
  final bool canWithdraw;

  /// Whether the account can deposit.
  final bool canDeposit;

  /// Whether the account is brokered.
  final bool brokered;

  /// Whether self-trade prevention is required.
  final bool requireSelfTradePrevention;

  /// Whether SOR is prevented.
  final bool preventSor;

  /// Last update time.
  final DateTime updateTime;

  /// Account type.
  final String accountType;

  /// Asset balances.
  final List<AssetBalance> balances;

  /// Permissions.
  final List<String> permissions;

  /// Unique user ID.
  final int uid;
}

/// Represents an asset balance.
@immutable
final class AssetBalance {
  /// Creates an [AssetBalance] instance.
  const AssetBalance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  /// Creates an [AssetBalance] from a JSON map.
  factory AssetBalance.fromJson(Map<String, dynamic> json) {
    return AssetBalance(
      asset: Asset(json['asset'] as String),
      free: Quantity.fromString(json['free'] as String),
      locked: Quantity.fromString(json['locked'] as String),
    );
  }

  /// Asset.
  final Asset asset;

  /// Free balance.
  final Quantity free;

  /// Locked balance.
  final Quantity locked;
}

/// Represents a newly created order.
@immutable
final class NewOrderResponse {
  /// Creates a [NewOrderResponse] instance.
  const NewOrderResponse({
    required this.symbol,
    required this.orderId,
    required this.orderListId,
    required this.clientOrderId,
    required this.transactTime,
    this.price,
    this.origQty,
    this.executedQty,
    this.cummulativeQuoteQty,
    this.status,
    this.timeInForce,
    this.type,
    this.side,
    this.workingTime,
    this.selfTradePreventionMode,
    this.fills,
  });

  /// Creates a [NewOrderResponse] from a JSON map.
  factory NewOrderResponse.fromJson(Map<String, dynamic> json) {
    return NewOrderResponse(
      symbol: Symbol(json['symbol'] as String),
      orderId: json['orderId'] as int,
      orderListId: json['orderListId'] as int,
      clientOrderId: json['clientOrderId'] as String,
      transactTime:
          DateTime.fromMillisecondsSinceEpoch(json['transactTime'] as int),
      price: json.containsKey('price')
          ? Price.fromString(json['price'] as String)
          : null,
      origQty: json.containsKey('origQty')
          ? Quantity.fromString(json['origQty'] as String)
          : null,
      executedQty: json.containsKey('executedQty')
          ? Quantity.fromString(json['executedQty'] as String)
          : null,
      cummulativeQuoteQty: json.containsKey('cummulativeQuoteQty')
          ? Quantity.fromString(json['cummulativeQuoteQty'] as String)
          : null,
      status: json.containsKey('status')
          ? OrderStatus.values
              .firstWhere((OrderStatus e) => e.value == json['status'])
          : null,
      timeInForce: json.containsKey('timeInForce')
          ? TimeInForce.values
              .firstWhere((TimeInForce e) => e.value == json['timeInForce'])
          : null,
      type: json.containsKey('type')
          ? OrderType.values
              .firstWhere((OrderType e) => e.value == json['type'])
          : null,
      side: json.containsKey('side')
          ? Side.values.firstWhere((Side e) => e.value == json['side'])
          : null,
      workingTime: json.containsKey('workingTime')
          ? DateTime.fromMillisecondsSinceEpoch(json['workingTime'] as int)
          : null,
      selfTradePreventionMode: json.containsKey('selfTradePreventionMode')
          ? SelfTradePreventionMode.values.firstWhere(
              (SelfTradePreventionMode e) =>
                  e.value == json['selfTradePreventionMode'],
            )
          : null,
      fills: json.containsKey('fills')
          ? (json['fills'] as List<dynamic>)
              .map(
                (f) => OrderFill.fromJson(f as Map<String, dynamic>),
              )
              .toList()
          : null,
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Order ID.
  final int orderId;

  /// Order list ID.
  final int orderListId;

  /// Client order ID.
  final String clientOrderId;

  /// Transaction time.
  final DateTime transactTime;

  /// Price.
  final Price? price;

  /// Original quantity.
  final Quantity? origQty;

  /// Executed quantity.
  final Quantity? executedQty;

  /// Cumulative quote quantity.
  final Quantity? cummulativeQuoteQty;

  /// Order status.
  final OrderStatus? status;

  /// Time in force.
  final TimeInForce? timeInForce;

  /// Order type.
  final OrderType? type;

  /// Order side.
  final Side? side;

  /// Working time.
  final DateTime? workingTime;

  /// STP mode.
  final SelfTradePreventionMode? selfTradePreventionMode;

  /// Fills.
  final List<OrderFill>? fills;
}

/// Represents an order fill.
@immutable
final class OrderFill {
  /// Creates an [OrderFill] instance.
  const OrderFill({
    required this.price,
    required this.qty,
    required this.commission,
    required this.commissionAsset,
    this.tradeId,
  });

  /// Creates an [OrderFill] from a JSON map.
  factory OrderFill.fromJson(Map<String, dynamic> json) {
    return OrderFill(
      price: Price.fromString(json['price'] as String),
      qty: Quantity.fromString(json['qty'] as String),
      commission: Quantity.fromString(json['commission'] as String),
      commissionAsset: Asset(json['commissionAsset'] as String),
      tradeId: json['tradeId'] as int?,
    );
  }

  /// Price.
  final Price price;

  /// Quantity.
  final Quantity qty;

  /// Commission.
  final Quantity commission;

  /// Commission asset.
  final Asset commissionAsset;

  /// Trade ID.
  final int? tradeId;
}

/// Represents an order.
@immutable
final class Order {
  /// Creates an [Order] instance.
  const Order({
    required this.symbol,
    required this.orderId,
    required this.orderListId,
    required this.clientOrderId,
    required this.price,
    required this.origQty,
    required this.executedQty,
    required this.cummulativeQuoteQty,
    required this.status,
    required this.timeInForce,
    required this.type,
    required this.side,
    required this.stopPrice,
    required this.icebergQty,
    required this.time,
    required this.updateTime,
    required this.isWorking,
    required this.workingTime,
    required this.origQuoteOrderQty,
    required this.selfTradePreventionMode,
  });

  /// Creates an [Order] from a JSON map.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      symbol: Symbol(json['symbol'] as String),
      orderId: json['orderId'] as int,
      orderListId: json['orderListId'] as int,
      clientOrderId: json['clientOrderId'] as String,
      price: Price.fromString(json['price'] as String),
      origQty: Quantity.fromString(json['origQty'] as String),
      executedQty: Quantity.fromString(json['executedQty'] as String),
      cummulativeQuoteQty:
          Quantity.fromString(json['cummulativeQuoteQty'] as String),
      status: OrderStatus.values
          .firstWhere((OrderStatus e) => e.value == json['status']),
      timeInForce: TimeInForce.values
          .firstWhere((TimeInForce e) => e.value == json['timeInForce']),
      type:
          OrderType.values.firstWhere((OrderType e) => e.value == json['type']),
      side: Side.values.firstWhere((Side e) => e.value == json['side']),
      stopPrice: Price.fromString(json['stopPrice'] as String),
      icebergQty: Quantity.fromString(json['icebergQty'] as String),
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      updateTime:
          DateTime.fromMillisecondsSinceEpoch(json['updateTime'] as int),
      isWorking: json['isWorking'] as bool,
      workingTime:
          DateTime.fromMillisecondsSinceEpoch(json['workingTime'] as int),
      origQuoteOrderQty:
          Quantity.fromString(json['origQuoteOrderQty'] as String),
      selfTradePreventionMode: SelfTradePreventionMode.values.firstWhere(
        (SelfTradePreventionMode e) =>
            e.value == json['selfTradePreventionMode'],
      ),
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Order ID.
  final int orderId;

  /// Order list ID.
  final int orderListId;

  /// Client order ID.
  final String clientOrderId;

  /// Price.
  final Price price;

  /// Original quantity.
  final Quantity origQty;

  /// Executed quantity.
  final Quantity executedQty;

  /// Cumulative quote quantity.
  final Quantity cummulativeQuoteQty;

  /// Status.
  final OrderStatus status;

  /// Time in force.
  final TimeInForce timeInForce;

  /// Type.
  final OrderType type;

  /// Side.
  final Side side;

  /// Stop price.
  final Price stopPrice;

  /// Iceberg quantity.
  final Quantity icebergQty;

  /// Time.
  final DateTime time;

  /// Update time.
  final DateTime updateTime;

  /// Whether the order is working.
  final bool isWorking;

  /// Working time.
  final DateTime workingTime;

  /// Original quote order quantity.
  final Quantity origQuoteOrderQty;

  /// STP mode.
  final SelfTradePreventionMode selfTradePreventionMode;
}

/// Represents a trade by the current user.
@immutable
final class MyTrade {
  /// Creates a [MyTrade] instance.
  const MyTrade({
    required this.symbol,
    required this.id,
    required this.orderId,
    required this.orderListId,
    required this.price,
    required this.qty,
    required this.quoteQty,
    required this.commission,
    required this.commissionAsset,
    required this.time,
    required this.isBuyer,
    required this.isMaker,
    required this.isBestMatch,
  });

  /// Creates a [MyTrade] from a JSON map.
  factory MyTrade.fromJson(Map<String, dynamic> json) {
    return MyTrade(
      symbol: Symbol(json['symbol'] as String),
      id: json['id'] as int,
      orderId: json['orderId'] as int,
      orderListId: json['orderListId'] as int,
      price: Price.fromString(json['price'] as String),
      qty: Quantity.fromString(json['qty'] as String),
      quoteQty: Quantity.fromString(json['quoteQty'] as String),
      commission: Quantity.fromString(json['commission'] as String),
      commissionAsset: Asset(json['commissionAsset'] as String),
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      isBuyer: json['isBuyer'] as bool,
      isMaker: json['isMaker'] as bool,
      isBestMatch: json['isBestMatch'] as bool,
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Trade ID.
  final int id;

  /// Order ID.
  final int orderId;

  /// Order list ID.
  final int orderListId;

  /// Price.
  final Price price;

  /// Quantity.
  final Quantity qty;

  /// Quote quantity.
  final Quantity quoteQty;

  /// Commission.
  final Quantity commission;

  /// Commission asset.
  final Asset commissionAsset;

  /// Time.
  final DateTime time;

  /// Whether the user is the buyer.
  final bool isBuyer;

  /// Whether the user is the maker.
  final bool isMaker;

  /// Whether it's the best match.
  final bool isBestMatch;
}
