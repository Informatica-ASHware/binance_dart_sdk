import 'package:binance_core/binance_core.dart';
import 'package:meta/meta.dart';

/// Represents the response from the /api/v3/exchangeInfo endpoint.
@immutable
final class ExchangeInfo {
  /// Creates an [ExchangeInfo] instance.
  const ExchangeInfo({
    required this.timezone,
    required this.serverTime,
    required this.rateLimits,
    required this.exchangeFilters,
    required this.symbols,
  });

  /// Creates an [ExchangeInfo] from a JSON map.
  factory ExchangeInfo.fromJson(Map<String, dynamic> json) {
    return ExchangeInfo(
      timezone: json['timezone'] as String,
      serverTime: DateTime.fromMillisecondsSinceEpoch(json['serverTime'] as int),
      rateLimits: json['rateLimits'] as List<dynamic>,
      exchangeFilters: json['exchangeFilters'] as List<dynamic>,
      symbols: (json['symbols'] as List<dynamic>)
          .map((s) => SymbolInfo.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The server's timezone.
  final String timezone;

  /// The server's current time.
  final DateTime serverTime;

  /// The rate limits for the API.
  final List<dynamic> rateLimits;

  /// The exchange-level filters.
  final List<dynamic> exchangeFilters;

  /// The list of available symbols.
  final List<SymbolInfo> symbols;
}

/// Represents information about a specific symbol.
@immutable
final class SymbolInfo {
  /// Creates a [SymbolInfo] instance.
  const SymbolInfo({
    required this.symbol,
    required this.status,
    required this.baseAsset,
    required this.baseAssetPrecision,
    required this.quoteAsset,
    required this.quotePrecision,
    required this.quoteAssetPrecision,
    required this.baseCommissionPrecision,
    required this.quoteCommissionPrecision,
    required this.orderTypes,
    required this.icebergAllowed,
    required this.ocoAllowed,
    required this.quoteOrderQtyMarketAllowed,
    required this.allowTrailingStop,
    required this.cancelReplaceAllowed,
    required this.isSpotTradingAllowed,
    required this.isMarginTradingAllowed,
    required this.filters,
    required this.permissions,
    required this.defaultSelfTradePreventionMode,
    required this.allowedSelfTradePreventionModes,
    this.otoAllowed = false,
    this.permissionSets,
  });

  /// Creates a [SymbolInfo] from a JSON map.
  factory SymbolInfo.fromJson(Map<String, dynamic> json) {
    return SymbolInfo(
      symbol: Symbol(json['symbol'] as String),
      status: json['status'] as String,
      baseAsset: Asset(json['baseAsset'] as String),
      baseAssetPrecision: json['baseAssetPrecision'] as int,
      quoteAsset: Asset(json['quoteAsset'] as String),
      quotePrecision: json['quotePrecision'] as int,
      quoteAssetPrecision: json['quoteAssetPrecision'] as int,
      baseCommissionPrecision: json['baseCommissionPrecision'] as int,
      quoteCommissionPrecision: json['quoteCommissionPrecision'] as int,
      orderTypes: (json['orderTypes'] as List<dynamic>).cast<String>(),
      icebergAllowed: json['icebergAllowed'] as bool,
      ocoAllowed: json['ocoAllowed'] as bool,
      otoAllowed: (json['otoAllowed'] as bool?) ?? false,
      quoteOrderQtyMarketAllowed: json['quoteOrderQtyMarketAllowed'] as bool,
      allowTrailingStop: json['allowTrailingStop'] as bool,
      cancelReplaceAllowed: json['cancelReplaceAllowed'] as bool,
      isSpotTradingAllowed: json['isSpotTradingAllowed'] as bool,
      isMarginTradingAllowed: json['isMarginTradingAllowed'] as bool,
      filters: json['filters'] as List<dynamic>,
      permissions: (json['permissions'] as List<dynamic>).cast<String>(),
      permissionSets: (json['permissionSets'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).cast<String>())
          .toList(),
      defaultSelfTradePreventionMode:
          json['defaultSelfTradePreventionMode'] as String,
      allowedSelfTradePreventionModes:
          (json['allowedSelfTradePreventionModes'] as List<dynamic>)
              .cast<String>(),
    );
  }

  /// The symbol (e.g., BTCUSDT).
  final Symbol symbol;

  /// The status of the symbol (e.g., TRADING).
  final String status;

  /// The base asset.
  final Asset baseAsset;

  /// The precision for the base asset.
  final int baseAssetPrecision;

  /// The quote asset.
  final Asset quoteAsset;

  /// The precision for the quote asset.
  final int quotePrecision;

  /// The asset precision for the quote asset.
  final int quoteAssetPrecision;

  /// The commission precision for the base asset.
  final int baseCommissionPrecision;

  /// The commission precision for the quote asset.
  final int quoteCommissionPrecision;

  /// Supported order types.
  final List<String> orderTypes;

  /// Whether iceberg orders are allowed.
  final bool icebergAllowed;

  /// Whether OCO orders are allowed.
  final bool ocoAllowed;

  /// Whether OTO orders are allowed.
  final bool otoAllowed;

  /// Whether market orders with quote order quantity are allowed.
  final bool quoteOrderQtyMarketAllowed;

  /// Whether trailing stops are allowed.
  final bool allowTrailingStop;

  /// Whether cancel/replace is allowed.
  final bool cancelReplaceAllowed;

  /// Whether spot trading is allowed.
  final bool isSpotTradingAllowed;

  /// Whether margin trading is allowed.
  final bool isMarginTradingAllowed;

  /// Filters for this symbol.
  final List<dynamic> filters;

  /// Permissions for this symbol.
  final List<String> permissions;

  /// Permission sets for this symbol (Schema 2.0).
  final List<List<String>>? permissionSets;

  /// Default self-trade prevention mode.
  final String defaultSelfTradePreventionMode;

  /// Allowed self-trade prevention modes.
  final List<String> allowedSelfTradePreventionModes;
}

/// Represents the order book depth.
@immutable
final class OrderBook {
  /// Creates an [OrderBook] instance.
  const OrderBook({
    required this.lastUpdateId,
    required this.bids,
    required this.asks,
  });

  /// Creates an [OrderBook] from a JSON map.
  factory OrderBook.fromJson(Map<String, dynamic> json) {
    (Price, Quantity) parseEntry(dynamic e) {
      final list = e as List<dynamic>;
      return (
        Price.fromString(list[0] as String),
        Quantity.fromString(list[1] as String)
      );
    }

    return OrderBook(
      lastUpdateId: json['lastUpdateId'] as int,
      bids: (json['bids'] as List<dynamic>).map(parseEntry).toList(),
      asks: (json['asks'] as List<dynamic>).map(parseEntry).toList(),
    );
  }

  /// The ID of the last update.
  final int lastUpdateId;

  /// List of bids [price, quantity].
  final List<(Price, Quantity)> bids;

  /// List of asks [price, quantity].
  final List<(Price, Quantity)> asks;
}

/// Represents a trade.
@immutable
final class Trade {
  /// Creates a [Trade] instance.
  const Trade({
    required this.id,
    required this.price,
    required this.quantity,
    required this.time,
    required this.isBuyerMaker,
    required this.isBestMatch,
    this.quoteQuantity,
  });

  /// Creates a [Trade] from a JSON map.
  factory Trade.fromJson(Map<String, dynamic> json) {
    return Trade(
      id: json['id'] as int,
      price: Price.fromString(json['price'] as String),
      quantity: Quantity.fromString(json['qty'] as String),
      quoteQuantity: json.containsKey('quoteQty')
          ? Quantity.fromString(json['quoteQty'] as String)
          : null,
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
      isBuyerMaker: json['isBuyerMaker'] as bool,
      isBestMatch: json['isBestMatch'] as bool,
    );
  }

  /// Trade ID.
  final int id;

  /// Price.
  final Price price;

  /// Quantity.
  final Quantity quantity;

  /// Quote quantity.
  final Quantity? quoteQuantity;

  /// Trade time.
  final DateTime time;

  /// Whether the buyer is the maker.
  final bool isBuyerMaker;

  /// Whether it's the best match.
  final bool isBestMatch;
}

/// Represents an aggregated trade.
@immutable
final class AggTrade {
  /// Creates an [AggTrade] instance.
  const AggTrade({
    required this.id,
    required this.price,
    required this.quantity,
    required this.firstTradeId,
    required this.lastTradeId,
    required this.time,
    required this.isBuyerMaker,
    required this.isBestMatch,
  });

  /// Creates an [AggTrade] from a JSON map.
  factory AggTrade.fromJson(Map<String, dynamic> json) {
    return AggTrade(
      id: json['a'] as int,
      price: Price.fromString(json['p'] as String),
      quantity: Quantity.fromString(json['q'] as String),
      firstTradeId: json['f'] as int,
      lastTradeId: json['l'] as int,
      time: DateTime.fromMillisecondsSinceEpoch(json['T'] as int),
      isBuyerMaker: json['m'] as bool,
      isBestMatch: json['M'] as bool,
    );
  }

  /// Aggregated trade ID.
  final int id;

  /// Price.
  final Price price;

  /// Quantity.
  final Quantity quantity;

  /// First trade ID.
  final int firstTradeId;

  /// Last trade ID.
  final int lastTradeId;

  /// Trade time.
  final DateTime time;

  /// Whether the buyer is the maker.
  final bool isBuyerMaker;

  /// Whether it's the best match.
  final bool isBestMatch;
}

/// Represents a kline (candlestick).
@immutable
final class Kline {
  /// Creates a [Kline] instance.
  const Kline({
    required this.openTime,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.closeTime,
    required this.quoteAssetVolume,
    required this.numberOfTrades,
    required this.takerBuyBaseAssetVolume,
    required this.takerBuyQuoteAssetVolume,
  });

  /// Creates a [Kline] from a JSON list.
  factory Kline.fromJson(List<dynamic> json) {
    return Kline(
      openTime: DateTime.fromMillisecondsSinceEpoch(json[0] as int),
      open: Price.fromString(json[1] as String),
      high: Price.fromString(json[2] as String),
      low: Price.fromString(json[3] as String),
      close: Price.fromString(json[4] as String),
      volume: Quantity.fromString(json[5] as String),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json[6] as int),
      quoteAssetVolume: Quantity.fromString(json[7] as String),
      numberOfTrades: json[8] as int,
      takerBuyBaseAssetVolume: Quantity.fromString(json[9] as String),
      takerBuyQuoteAssetVolume: Quantity.fromString(json[10] as String),
    );
  }

  /// Open time.
  final DateTime openTime;

  /// Open price.
  final Price open;

  /// High price.
  final Price high;

  /// Low price.
  final Price low;

  /// Close price.
  final Price close;

  /// Volume.
  final Quantity volume;

  /// Close time.
  final DateTime closeTime;

  /// Quote asset volume.
  final Quantity quoteAssetVolume;

  /// Number of trades.
  final int numberOfTrades;

  /// Taker buy base asset volume.
  final Quantity takerBuyBaseAssetVolume;

  /// Taker buy quote asset volume.
  final Quantity takerBuyQuoteAssetVolume;
}

/// Represents a ticker 24hr statistics.
@immutable
final class TickerStatistics {
  /// Creates a [TickerStatistics] instance.
  const TickerStatistics({
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
  });

  /// Creates a [TickerStatistics] from a JSON map.
  factory TickerStatistics.fromJson(Map<String, dynamic> json) {
    return TickerStatistics(
      symbol: Symbol(json['symbol'] as String),
      priceChange: Price.fromString(json['priceChange'] as String),
      priceChangePercent:
          Percentage.fromString(json['priceChangePercent'] as String),
      weightedAvgPrice: Price.fromString(json['weightedAvgPrice'] as String),
      prevClosePrice: Price.fromString(json['prevClosePrice'] as String),
      lastPrice: Price.fromString(json['lastPrice'] as String),
      lastQty: Quantity.fromString(json['lastQty'] as String),
      bidPrice: Price.fromString(json['bidPrice'] as String),
      bidQty: Quantity.fromString(json['bidQty'] as String),
      askPrice: Price.fromString(json['askPrice'] as String),
      askQty: Quantity.fromString(json['askQty'] as String),
      openPrice: Price.fromString(json['openPrice'] as String),
      highPrice: Price.fromString(json['highPrice'] as String),
      lowPrice: Price.fromString(json['lowPrice'] as String),
      volume: Quantity.fromString(json['volume'] as String),
      quoteVolume: Quantity.fromString(json['quoteVolume'] as String),
      openTime: DateTime.fromMillisecondsSinceEpoch(json['openTime'] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json['closeTime'] as int),
      firstId: json['firstId'] as int,
      lastId: json['lastId'] as int,
      count: json['count'] as int,
    );
  }

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

  /// Count of trades.
  final int count;
}

/// Represents a simple price ticker.
@immutable
final class PriceTicker {
  /// Creates a [PriceTicker] instance.
  const PriceTicker({
    required this.symbol,
    required this.price,
  });

  /// Creates a [PriceTicker] from a JSON map.
  factory PriceTicker.fromJson(Map<String, dynamic> json) {
    return PriceTicker(
      symbol: Symbol(json['symbol'] as String),
      price: Price.fromString(json['price'] as String),
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Price.
  final Price price;
}

/// Represents a book ticker (best bid/ask).
@immutable
final class BookTicker {
  /// Creates a [BookTicker] instance.
  const BookTicker({
    required this.symbol,
    required this.bidPrice,
    required this.bidQty,
    required this.askPrice,
    required this.askQty,
  });

  /// Creates a [BookTicker] from a JSON map.
  factory BookTicker.fromJson(Map<String, dynamic> json) {
    return BookTicker(
      symbol: Symbol(json['symbol'] as String),
      bidPrice: Price.fromString(json['bidPrice'] as String),
      bidQty: Quantity.fromString(json['bidQty'] as String),
      askPrice: Price.fromString(json['askPrice'] as String),
      askQty: Quantity.fromString(json['askQty'] as String),
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Bid price.
  final Price bidPrice;

  /// Bid quantity.
  final Quantity bidQty;

  /// Ask price.
  final Price askPrice;

  /// Ask quantity.
  final Quantity askQty;
}

/// Represents a rolling window ticker.
@immutable
final class RollingWindowTicker {
  /// Creates a [RollingWindowTicker] instance.
  const RollingWindowTicker({
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.weightedAvgPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.lastPrice,
    required this.volume,
    required this.quoteVolume,
    required this.openTime,
    required this.closeTime,
    required this.firstId,
    required this.lastId,
    required this.count,
  });

  /// Creates a [RollingWindowTicker] from a JSON map.
  factory RollingWindowTicker.fromJson(Map<String, dynamic> json) {
    return RollingWindowTicker(
      symbol: Symbol(json['symbol'] as String),
      priceChange: Price.fromString(json['priceChange'] as String),
      priceChangePercent:
          Percentage.fromString(json['priceChangePercent'] as String),
      weightedAvgPrice: Price.fromString(json['weightedAvgPrice'] as String),
      openPrice: Price.fromString(json['openPrice'] as String),
      highPrice: Price.fromString(json['highPrice'] as String),
      lowPrice: Price.fromString(json['lowPrice'] as String),
      lastPrice: Price.fromString(json['lastPrice'] as String),
      volume: Quantity.fromString(json['volume'] as String),
      quoteVolume: Quantity.fromString(json['quoteVolume'] as String),
      openTime: DateTime.fromMillisecondsSinceEpoch(json['openTime'] as int),
      closeTime: DateTime.fromMillisecondsSinceEpoch(json['closeTime'] as int),
      firstId: json['firstId'] as int,
      lastId: json['lastId'] as int,
      count: json['count'] as int,
    );
  }

  /// Symbol.
  final Symbol symbol;

  /// Price change.
  final Price priceChange;

  /// Price change percent.
  final Percentage priceChangePercent;

  /// Weighted average price.
  final Price weightedAvgPrice;

  /// Open price.
  final Price openPrice;

  /// High price.
  final Price highPrice;

  /// Low price.
  final Price lowPrice;

  /// Last price.
  final Price lastPrice;

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

  /// Count of trades.
  final int count;
}
