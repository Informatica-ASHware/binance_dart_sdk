import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:meta/meta.dart';

/// Base class for all Spot WebSocket events.
@immutable
sealed class SpotEvent {
  /// Creates a [SpotEvent] instance.
  const SpotEvent({required this.eventType, required this.eventTime});

  /// Event type.
  final String eventType;

  /// Event time.
  final DateTime eventTime;
}

/// Aggregated trade event.
final class AggTradeEvent extends SpotEvent {
  /// Creates an [AggTradeEvent] instance.
  const AggTradeEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.aggTradeId,
    required this.price,
    required this.quantity,
    required this.firstTradeId,
    required this.lastTradeId,
    required this.tradeTime,
    required this.isBuyerMaker,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// Aggregated trade ID.
  final int aggTradeId;

  /// Price.
  final Price price;

  /// Quantity.
  final Quantity quantity;

  /// First trade ID.
  final int firstTradeId;

  /// Last trade ID.
  final int lastTradeId;

  /// Trade time.
  final DateTime tradeTime;

  /// Whether the buyer is the maker.
  final bool isBuyerMaker;

  /// Creates an [AggTradeEvent] from a JSON map.
  factory AggTradeEvent.fromJson(Map<String, dynamic> json) {
    return AggTradeEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      aggTradeId: json['a'] as int,
      price: Price.fromString(json['p'] as String),
      quantity: Quantity.fromString(json['q'] as String),
      firstTradeId: json['f'] as int,
      lastTradeId: json['l'] as int,
      tradeTime: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      isBuyerMaker: json['m'] as bool,
    );
  }
}

/// Trade event.
final class TradeEvent extends SpotEvent {
  /// Creates a [TradeEvent] instance.
  const TradeEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.tradeId,
    required this.price,
    required this.quantity,
    required this.buyerOrderId,
    required this.sellerOrderId,
    required this.tradeTime,
    required this.isBuyerMaker,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// Trade ID.
  final int tradeId;

  /// Price.
  final Price price;

  /// Quantity.
  final Quantity quantity;

  /// Buyer order ID.
  final int buyerOrderId;

  /// Seller order ID.
  final int sellerOrderId;

  /// Trade time.
  final DateTime tradeTime;

  /// Whether the buyer is the maker.
  final bool isBuyerMaker;

  /// Creates a [TradeEvent] from a JSON map.
  factory TradeEvent.fromJson(Map<String, dynamic> json) {
    return TradeEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      tradeId: json['t'] as int,
      price: Price.fromString(json['p'] as String),
      quantity: Quantity.fromString(json['q'] as String),
      buyerOrderId: json['b'] as int,
      sellerOrderId: json['a'] as int,
      tradeTime: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      isBuyerMaker: json['m'] as bool,
    );
  }
}

/// Kline/Candlestick event.
final class KlineEvent extends SpotEvent {
  /// Creates a [KlineEvent] instance.
  const KlineEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.kline,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// Kline data.
  final KlineData kline;

  /// Creates a [KlineEvent] from a JSON map.
  factory KlineEvent.fromJson(Map<String, dynamic> json) {
    return KlineEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      kline: KlineData.fromJson(json['k'] as Map<String, dynamic>),
    );
  }
}

/// Kline data in an event.
@immutable
final class KlineData {
  /// Creates a [KlineData] instance.
  const KlineData({
    required this.startTime,
    required this.endTime,
    required this.symbol,
    required this.interval,
    required this.firstTradeId,
    required this.lastTradeId,
    required this.openPrice,
    required this.closePrice,
    required this.highPrice,
    required this.lowPrice,
    required this.baseAssetVolume,
    required this.numberOfTrades,
    required this.isClosed,
    required this.quoteAssetVolume,
    required this.takerBuyBaseAssetVolume,
    required this.takerBuyQuoteAssetVolume,
  });

  /// Start time.
  final DateTime startTime;

  /// End time.
  final DateTime endTime;

  /// Symbol.
  final Symbol symbol;

  /// Interval.
  final String interval;

  /// First trade ID.
  final int firstTradeId;

  /// Last trade ID.
  final int lastTradeId;

  /// Open price.
  final Price openPrice;

  /// Close price.
  final Price closePrice;

  /// High price.
  final Price highPrice;

  /// Low price.
  final Price lowPrice;

  /// Base asset volume.
  final Quantity baseAssetVolume;

  /// Number of trades.
  final int numberOfTrades;

  /// Whether the kline is closed.
  final bool isClosed;

  /// Quote asset volume.
  final Quantity quoteAssetVolume;

  /// Taker buy base asset volume.
  final Quantity takerBuyBaseAssetVolume;

  /// Taker buy quote asset volume.
  final Quantity takerBuyQuoteAssetVolume;

  /// Creates a [KlineData] from a JSON map.
  factory KlineData.fromJson(Map<String, dynamic> json) {
    return KlineData(
      startTime: DateTime.fromMillisecondsSinceEpoch(json['t'] as int),
      endTime: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      symbol: Symbol(json['s'] as String),
      interval: json['i'] as String,
      firstTradeId: json['f'] as int,
      lastTradeId: json['L'] as int,
      openPrice: Price.fromString(json['o'] as String),
      closePrice: Price.fromString(json['c'] as String),
      highPrice: Price.fromString(json['h'] as String),
      lowPrice: Price.fromString(json['l'] as String),
      baseAssetVolume: Quantity.fromString(json['v'] as String),
      numberOfTrades: json['n'] as int,
      isClosed: json['x'] as bool,
      quoteAssetVolume: Quantity.fromString(json['q'] as String),
      takerBuyBaseAssetVolume: Quantity.fromString(json['V'] as String),
      takerBuyQuoteAssetVolume: Quantity.fromString(json['Q'] as String),
    );
  }
}

/// Individual symbol mini-ticker event.
final class MiniTickerEvent extends SpotEvent {
  /// Creates a [MiniTickerEvent] instance.
  const MiniTickerEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.closePrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.baseAssetVolume,
    required this.quoteAssetVolume,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// Close price.
  final Price closePrice;

  /// Open price.
  final Price openPrice;

  /// High price.
  final Price highPrice;

  /// Low price.
  final Price lowPrice;

  /// Base asset volume.
  final Quantity baseAssetVolume;

  /// Quote asset volume.
  final Quantity quoteAssetVolume;

  /// Creates a [MiniTickerEvent] from a JSON map.
  factory MiniTickerEvent.fromJson(Map<String, dynamic> json) {
    return MiniTickerEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      closePrice: Price.fromString(json['c'] as String),
      openPrice: Price.fromString(json['o'] as String),
      highPrice: Price.fromString(json['h'] as String),
      lowPrice: Price.fromString(json['l'] as String),
      baseAssetVolume: Quantity.fromString(json['v'] as String),
      quoteAssetVolume: Quantity.fromString(json['q'] as String),
    );
  }
}

/// Individual symbol ticker event.
final class TickerEvent extends SpotEvent {
  /// Creates a [TickerEvent] instance.
  const TickerEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.weightedAvgPrice,
    required this.prevClosePrice,
    required this.lastPrice,
    required this.lastQty,
    required this.bidPrice,
    required this.bidQty,
    required this.askPrice,
    required this.askQty,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
    required this.openTime,
    required this.closeTime,
    required this.firstId,
    required this.lastId,
    required this.count,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// Price change.
  final Price priceChange;

  /// Price change percent.
  final Percentage priceChangePercent;

  /// Weighted average price.
  final Price weightedAvgPrice;

  /// Previous close price.
  final Price prevClosePrice;

  /// Last price.
  final Price lastPrice;

  /// Last quantity.
  final Quantity lastQty;

  /// Bid price.
  final Price bidPrice;

  /// Bid quantity.
  final Quantity bidQty;

  /// Ask price.
  final Price askPrice;

  /// Ask quantity.
  final Quantity askQty;

  /// Open price.
  final Price openPrice;

  /// High price.
  final Price highPrice;

  /// Low price.
  final Price lowPrice;

  /// Volume.
  final Quantity volume;

  /// Quote volume.
  final Quantity quoteVolume;

  /// Open time.
  final DateTime openTime;

  /// Close time.
  final DateTime closeTime;

  /// First trade ID.
  final int firstId;

  /// Last trade ID.
  final int lastId;

  /// Count.
  final int count;

  /// Creates a [TickerEvent] from a JSON map.
  factory TickerEvent.fromJson(Map<String, dynamic> json) {
    return TickerEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      priceChange: Price.fromString(json['p'] as String),
      priceChangePercent: Percentage.fromString(json['P'] as String),
      weightedAvgPrice: Price.fromString(json['w'] as String),
      prevClosePrice: Price.fromString(json['x'] as String),
      lastPrice: Price.fromString(json['c'] as String),
      lastQty: Quantity.fromString(json['Q'] as String),
      bidPrice: Price.fromString(json['b'] as String),
      bidQty: Quantity.fromString(json['B'] as String),
      askPrice: Price.fromString(json['a'] as String),
      askQty: Quantity.fromString(json['A'] as String),
      openPrice: Price.fromString(json['o'] as String),
      highPrice: Price.fromString(json['h'] as String),
      lowPrice: Price.fromString(json['l'] as String),
      volume: Quantity.fromString(json['v'] as String),
      quoteVolume: Quantity.fromString(json['q'] as String),
      openTime: DateTime.fromMillisecondsSinceEpoch(json['O'] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json['C'] as int),
      firstId: json['F'] as int,
      lastId: json['L'] as int,
      count: json['n'] as int,
    );
  }
}

/// Book ticker event.
@immutable
final class BookTickerEvent {
  /// Creates a [BookTickerEvent] instance.
  const BookTickerEvent({
    required this.updateId,
    required this.symbol,
    required this.bestBidPrice,
    required this.bestBidQty,
    required this.bestAskPrice,
    required this.bestAskQty,
  });

  /// Update ID.
  final int updateId;

  /// Symbol.
  final Symbol symbol;

  /// Best bid price.
  final Price bestBidPrice;

  /// Best bid quantity.
  final Quantity bestBidQty;

  /// Best ask price.
  final Price bestAskPrice;

  /// Best ask quantity.
  final Quantity bestAskQty;

  /// Creates a [BookTickerEvent] from a JSON map.
  factory BookTickerEvent.fromJson(Map<String, dynamic> json) {
    return BookTickerEvent(
      updateId: json['u'] as int,
      symbol: Symbol(json['s'] as String),
      bestBidPrice: Price.fromString(json['b'] as String),
      bestBidQty: Quantity.fromString(json['B'] as String),
      bestAskPrice: Price.fromString(json['a'] as String),
      bestAskQty: Quantity.fromString(json['A'] as String),
    );
  }
}

/// Diff. depth stream event.
final class DepthUpdateEvent extends SpotEvent {
  /// Creates a [DepthUpdateEvent] instance.
  const DepthUpdateEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.firstUpdateId,
    required this.finalUpdateId,
    required this.bids,
    required this.asks,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// First update ID.
  final int firstUpdateId;

  /// Final update ID.
  final int finalUpdateId;

  /// Bids [price, quantity].
  final List<(Price, Quantity)> bids;

  /// Asks [price, quantity].
  final List<(Price, Quantity)> asks;

  /// Creates a [DepthUpdateEvent] from a JSON map.
  factory DepthUpdateEvent.fromJson(Map<String, dynamic> json) {
    (Price, Quantity) parseEntry(dynamic e) {
      final list = e as List<dynamic>;
      return (
        Price.fromString(list[0] as String),
        Quantity.fromString(list[1] as String),
      );
    }

    return DepthUpdateEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      firstUpdateId: json['U'] as int,
      finalUpdateId: json['u'] as int,
      bids: (json['b'] as List<dynamic>).map(parseEntry).toList(),
      asks: (json['a'] as List<dynamic>).map(parseEntry).toList(),
    );
  }
}

/// Execution report event (user data stream).
final class ExecutionReportEvent extends SpotEvent {
  /// Creates an [ExecutionReportEvent] instance.
  const ExecutionReportEvent({
    required super.eventType,
    required super.eventTime,
    required this.symbol,
    required this.clientOrderId,
    required this.side,
    required this.orderType,
    required this.timeInForce,
    required this.orderQuantity,
    required this.orderPrice,
    required this.stopPrice,
    required this.icebergQuantity,
    required this.orderListId,
    required this.originalClientOrderId,
    required this.executionType,
    required this.orderStatus,
    required this.orderRejectReason,
    required this.orderId,
    required this.lastExecutedQuantity,
    required this.cumulativeFilledQuantity,
    required this.lastExecutedPrice,
    required this.commissionAmount,
    required this.commissionAsset,
    required this.transactionTime,
    required this.tradeId,
    required this.isOrderOnBook,
    required this.isMakerSide,
    required this.orderCreationTime,
    required this.cumulativeQuoteAssetTransactedQuantity,
    required this.lastQuoteAssetTransactedQuantity,
    required this.quoteOrderQuantity,
    required this.selfTradePreventionMode,
  }) : super();

  /// Symbol.
  final Symbol symbol;

  /// Client order ID.
  final String clientOrderId;

  /// Side.
  final Side side;

  /// Order type.
  final OrderType orderType;

  /// Time in force.
  final TimeInForce timeInForce;

  /// Order quantity.
  final Quantity orderQuantity;

  /// Order price.
  final Price orderPrice;

  /// Stop price.
  final Price stopPrice;

  /// Iceberg quantity.
  final Quantity icebergQuantity;

  /// Order list ID.
  final int orderListId;

  /// Original client order ID.
  final String originalClientOrderId;

  /// Execution type.
  final OrderExecutionType executionType;

  /// Order status.
  final OrderStatus orderStatus;

  /// Order reject reason.
  final String orderRejectReason;

  /// Order ID.
  final int orderId;

  /// Last executed quantity.
  final Quantity lastExecutedQuantity;

  /// Cumulative filled quantity.
  final Quantity cumulativeFilledQuantity;

  /// Last executed price.
  final Price lastExecutedPrice;

  /// Commission amount.
  final Quantity commissionAmount;

  /// Commission asset.
  final String? commissionAsset;

  /// Transaction time.
  final DateTime transactionTime;

  /// Trade ID.
  final int tradeId;

  /// Whether the order is on the book.
  final bool isOrderOnBook;

  /// Whether the user is the maker.
  final bool isMakerSide;

  /// Order creation time.
  final DateTime orderCreationTime;

  /// Cumulative quote asset transacted quantity.
  final Quantity cumulativeQuoteAssetTransactedQuantity;

  /// Last quote asset transacted quantity.
  final Quantity lastQuoteAssetTransactedQuantity;

  /// Quote order quantity.
  final Quantity quoteOrderQuantity;

  /// STP mode.
  final SelfTradePreventionMode selfTradePreventionMode;

  /// Creates an [ExecutionReportEvent] from a JSON map.
  factory ExecutionReportEvent.fromJson(Map<String, dynamic> json) {
    return ExecutionReportEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      symbol: Symbol(json['s'] as String),
      clientOrderId: json['c'] as String,
      side: Side.values.firstWhere((e) => e.value == json['S']),
      orderType: OrderType.values.firstWhere((e) => e.value == json['o']),
      timeInForce: TimeInForce.values.firstWhere((e) => e.value == json['f']),
      orderQuantity: Quantity.fromString(json['q'] as String),
      orderPrice: Price.fromString(json['p'] as String),
      stopPrice: Price.fromString(json['P'] as String),
      icebergQuantity: Quantity.fromString(json['F'] as String),
      orderListId: json['g'] as int,
      originalClientOrderId: json['C'] as String,
      executionType: OrderExecutionType.values.firstWhere(
        (e) => e.value == json['x'],
      ),
      orderStatus: OrderStatus.values.firstWhere((e) => e.value == json['X']),
      orderRejectReason: json['r'] as String,
      orderId: json['i'] as int,
      lastExecutedQuantity: Quantity.fromString(json['l'] as String),
      cumulativeFilledQuantity: Quantity.fromString(json['z'] as String),
      lastExecutedPrice: Price.fromString(json['L'] as String),
      commissionAmount: Quantity.fromString(json['n'] as String),
      commissionAsset: json['N'] as String?,
      transactionTime: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      tradeId: json['t'] as int,
      isOrderOnBook: json['w'] as bool,
      isMakerSide: json['m'] as bool,
      orderCreationTime: DateTime.fromMillisecondsSinceEpoch(json['O'] as int),
      cumulativeQuoteAssetTransactedQuantity: Quantity.fromString(
        json['Z'] as String,
      ),
      lastQuoteAssetTransactedQuantity: Quantity.fromString(
        json['Y'] as String,
      ),
      quoteOrderQuantity: Quantity.fromString(json['Q'] as String),
      selfTradePreventionMode: SelfTradePreventionMode.values.firstWhere(
        (e) => e.value == json['V'],
      ),
    );
  }
}

/// Outbound account position event (user data stream).
final class OutboundAccountPositionEvent extends SpotEvent {
  /// Creates an [OutboundAccountPositionEvent] instance.
  const OutboundAccountPositionEvent({
    required super.eventType,
    required super.eventTime,
    required this.lastUpdateTime,
    required this.balances,
  }) : super();

  /// Last update time.
  final DateTime lastUpdateTime;

  /// Balances.
  final List<AssetBalanceUpdate> balances;

  /// Creates an [OutboundAccountPositionEvent] from a JSON map.
  factory OutboundAccountPositionEvent.fromJson(Map<String, dynamic> json) {
    return OutboundAccountPositionEvent(
      eventType: json['e'] as String,
      eventTime: DateTime.fromMillisecondsSinceEpoch(json['E'] as int),
      lastUpdateTime: DateTime.fromMillisecondsSinceEpoch(json['u'] as int),
      balances: (json['B'] as List<dynamic>)
          .map((b) => AssetBalanceUpdate.fromJson(b as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Asset balance update in an event.
@immutable
final class AssetBalanceUpdate {
  /// Creates an [AssetBalanceUpdate] instance.
  const AssetBalanceUpdate({
    required this.asset,
    required this.free,
    required this.locked,
  });

  /// Asset.
  final Asset asset;

  /// Free balance.
  final Quantity free;

  /// Locked balance.
  final Quantity locked;

  /// Creates an [AssetBalanceUpdate] from a JSON map.
  factory AssetBalanceUpdate.fromJson(Map<String, dynamic> json) {
    return AssetBalanceUpdate(
      asset: Asset(json['a'] as String),
      free: Quantity.fromString(json['f'] as String),
      locked: Quantity.fromString(json['l'] as String),
    );
  }
}
