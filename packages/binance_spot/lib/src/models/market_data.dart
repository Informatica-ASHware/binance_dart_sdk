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
      serverTime:
          DateTime.fromMillisecondsSinceEpoch(json['serverTime'] as int),
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
      filters: (json['filters'] as List<dynamic>)
          .map((f) => SymbolFilter.fromJson(f as Map<String, dynamic>))
          .toList(),
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
  final List<SymbolFilter> filters;

  /// Permissions for this symbol.
  final List<String> permissions;

  /// Permission sets for this symbol (Schema 2.0).
  final List<List<String>>? permissionSets;

  /// Default self-trade prevention mode.
  final String defaultSelfTradePreventionMode;

  /// Allowed self-trade prevention modes.
  final List<String> allowedSelfTradePreventionModes;

  /// Returns the filter of type [T].
  T? getFilter<T extends SymbolFilter>() {
    for (final filter in filters) {
      if (filter is T) return filter;
    }
    return null;
  }
}

/// Base class for symbol filters.
@immutable
sealed class SymbolFilter {
  /// Creates a [SymbolFilter].
  const SymbolFilter();

  /// Creates a [SymbolFilter] from a JSON map.
  factory SymbolFilter.fromJson(Map<String, dynamic> json) {
    final type = json['filterType'] as String;
    return switch (type) {
      'PRICE_FILTER' => PriceFilter.fromJson(json),
      'PERCENT_PRICE' => PercentPriceFilter.fromJson(json),
      'PERCENT_PRICE_BY_SIDE' => PercentPriceBySideFilter.fromJson(json),
      'LOT_SIZE' => LotSizeFilter.fromJson(json),
      'MIN_NOTIONAL' => MinNotionalFilter.fromJson(json),
      'NOTIONAL' => NotionalFilter.fromJson(json),
      'ICEBERG_PARTS' => IcebergPartsFilter.fromJson(json),
      'MARKET_LOT_SIZE' => MarketLotSizeFilter.fromJson(json),
      'MAX_NUM_ORDERS' => MaxNumOrdersFilter.fromJson(json),
      'MAX_NUM_ALGO_ORDERS' => MaxNumAlgoOrdersFilter.fromJson(json),
      'MAX_NUM_ICEBERG_ORDERS' => MaxNumIcebergOrdersFilter.fromJson(json),
      'MAX_POSITION' => MaxPositionFilter.fromJson(json),
      'TRAILING_DELTA' => TrailingDeltaFilter.fromJson(json),
      _ => UnknownFilter(type, json),
    };
  }
}

/// Filter for price constraints.
final class PriceFilter extends SymbolFilter {
  /// Creates a [PriceFilter].
  const PriceFilter({
    required this.minPrice,
    required this.maxPrice,
    required this.tickSize,
  });

  /// Creates a [PriceFilter] from a JSON map.
  factory PriceFilter.fromJson(Map<String, dynamic> json) {
    return PriceFilter(
      minPrice: Price.fromString(json['minPrice'] as String),
      maxPrice: Price.fromString(json['maxPrice'] as String),
      tickSize: Price.fromString(json['tickSize'] as String),
    );
  }

  /// Minimum price.
  final Price minPrice;

  /// Maximum price.
  final Price maxPrice;

  /// Tick size.
  final Price tickSize;
}

/// Filter for percent price constraints.
final class PercentPriceFilter extends SymbolFilter {
  /// Creates a [PercentPriceFilter].
  const PercentPriceFilter({
    required this.multiplierUp,
    required this.multiplierDown,
    required this.avgPriceMins,
  });

  /// Creates a [PercentPriceFilter] from a JSON map.
  factory PercentPriceFilter.fromJson(Map<String, dynamic> json) {
    return PercentPriceFilter(
      multiplierUp: Decimal.parse(json['multiplierUp'] as String),
      multiplierDown: Decimal.parse(json['multiplierDown'] as String),
      avgPriceMins: json['avgPriceMins'] as int,
    );
  }

  /// Multiplier up.
  final Decimal multiplierUp;

  /// Multiplier down.
  final Decimal multiplierDown;

  /// Average price minutes.
  final int avgPriceMins;
}

/// Filter for percent price by side constraints.
final class PercentPriceBySideFilter extends SymbolFilter {
  /// Creates a [PercentPriceBySideFilter].
  const PercentPriceBySideFilter({
    required this.bidMultiplierUp,
    required this.bidMultiplierDown,
    required this.askMultiplierUp,
    required this.askMultiplierDown,
    required this.avgPriceMins,
  });

  /// Creates a [PercentPriceBySideFilter] from a JSON map.
  factory PercentPriceBySideFilter.fromJson(Map<String, dynamic> json) {
    return PercentPriceBySideFilter(
      bidMultiplierUp: Decimal.parse(json['bidMultiplierUp'] as String),
      bidMultiplierDown: Decimal.parse(json['bidMultiplierDown'] as String),
      askMultiplierUp: Decimal.parse(json['askMultiplierUp'] as String),
      askMultiplierDown: Decimal.parse(json['askMultiplierDown'] as String),
      avgPriceMins: json['avgPriceMins'] as int,
    );
  }

  /// Bid multiplier up.
  final Decimal bidMultiplierUp;

  /// Bid multiplier down.
  final Decimal bidMultiplierDown;

  /// Ask multiplier up.
  final Decimal askMultiplierUp;

  /// Ask multiplier down.
  final Decimal askMultiplierDown;

  /// Average price minutes.
  final int avgPriceMins;
}

/// Filter for quantity constraints.
final class LotSizeFilter extends SymbolFilter {
  /// Creates a [LotSizeFilter].
  const LotSizeFilter({
    required this.minQty,
    required this.maxQty,
    required this.stepSize,
  });

  /// Creates a [LotSizeFilter] from a JSON map.
  factory LotSizeFilter.fromJson(Map<String, dynamic> json) {
    return LotSizeFilter(
      minQty: Quantity.fromString(json['minQty'] as String),
      maxQty: Quantity.fromString(json['maxQty'] as String),
      stepSize: Quantity.fromString(json['stepSize'] as String),
    );
  }

  /// Minimum quantity.
  final Quantity minQty;

  /// Maximum quantity.
  final Quantity maxQty;

  /// Step size.
  final Quantity stepSize;
}

/// Filter for minimum notional value (legacy).
final class MinNotionalFilter extends SymbolFilter {
  /// Creates a [MinNotionalFilter].
  const MinNotionalFilter({
    required this.minNotional,
    required this.applyToMarket,
    required this.avgPriceMins,
  });

  /// Creates a [MinNotionalFilter] from a JSON map.
  factory MinNotionalFilter.fromJson(Map<String, dynamic> json) {
    return MinNotionalFilter(
      minNotional: Price.fromString(json['minNotional'] as String),
      applyToMarket: json['applyToMarket'] as bool,
      avgPriceMins: json['avgPriceMins'] as int,
    );
  }

  /// Minimum notional value.
  final Price minNotional;

  /// Whether to apply to market orders.
  final bool applyToMarket;

  /// Average price minutes.
  final int avgPriceMins;
}

/// Filter for notional value.
final class NotionalFilter extends SymbolFilter {
  /// Creates a [NotionalFilter].
  const NotionalFilter({
    required this.minNotional,
    required this.applyMinToMarket,
    required this.maxNotional,
    required this.applyMaxToMarket,
    required this.avgPriceMins,
  });

  /// Creates a [NotionalFilter] from a JSON map.
  factory NotionalFilter.fromJson(Map<String, dynamic> json) {
    return NotionalFilter(
      minNotional: Price.fromString(json['minNotional'] as String),
      applyMinToMarket: json['applyMinToMarket'] as bool,
      maxNotional: Price.fromString(json['maxNotional'] as String),
      applyMaxToMarket: json['applyMaxToMarket'] as bool,
      avgPriceMins: json['avgPriceMins'] as int,
    );
  }

  /// Minimum notional value.
  final Price minNotional;

  /// Whether to apply min notional to market orders.
  final bool applyMinToMarket;

  /// Maximum notional value.
  final Price maxNotional;

  /// Whether to apply max notional to market orders.
  final bool applyMaxToMarket;

  /// Average price minutes.
  final int avgPriceMins;
}

/// Filter for iceberg order parts.
final class IcebergPartsFilter extends SymbolFilter {
  /// Creates an [IcebergPartsFilter].
  const IcebergPartsFilter({required this.limit});

  /// Creates an [IcebergPartsFilter] from a JSON map.
  factory IcebergPartsFilter.fromJson(Map<String, dynamic> json) {
    return IcebergPartsFilter(limit: json['limit'] as int);
  }

  /// Limit of iceberg parts.
  final int limit;
}

/// Filter for market order quantity constraints.
final class MarketLotSizeFilter extends SymbolFilter {
  /// Creates a [MarketLotSizeFilter].
  const MarketLotSizeFilter({
    required this.minQty,
    required this.maxQty,
    required this.stepSize,
  });

  /// Creates a [MarketLotSizeFilter] from a JSON map.
  factory MarketLotSizeFilter.fromJson(Map<String, dynamic> json) {
    return MarketLotSizeFilter(
      minQty: Quantity.fromString(json['minQty'] as String),
      maxQty: Quantity.fromString(json['maxQty'] as String),
      stepSize: Quantity.fromString(json['stepSize'] as String),
    );
  }

  /// Minimum quantity.
  final Quantity minQty;

  /// Maximum quantity.
  final Quantity maxQty;

  /// Step size.
  final Quantity stepSize;
}

/// Filter for maximum number of orders.
final class MaxNumOrdersFilter extends SymbolFilter {
  /// Creates a [MaxNumOrdersFilter].
  const MaxNumOrdersFilter({required this.maxNumOrders});

  /// Creates a [MaxNumOrdersFilter] from a JSON map.
  factory MaxNumOrdersFilter.fromJson(Map<String, dynamic> json) {
    return MaxNumOrdersFilter(maxNumOrders: json['maxNumOrders'] as int);
  }

  /// Maximum number of orders.
  final int maxNumOrders;
}

/// Filter for maximum number of algo orders.
final class MaxNumAlgoOrdersFilter extends SymbolFilter {
  /// Creates a [MaxNumAlgoOrdersFilter].
  const MaxNumAlgoOrdersFilter({required this.maxNumAlgoOrders});

  /// Creates a [MaxNumAlgoOrdersFilter] from a JSON map.
  factory MaxNumAlgoOrdersFilter.fromJson(Map<String, dynamic> json) {
    return MaxNumAlgoOrdersFilter(
      maxNumAlgoOrders: json['maxNumAlgoOrders'] as int,
    );
  }

  /// Maximum number of algo orders.
  final int maxNumAlgoOrders;
}

/// Filter for maximum number of iceberg orders.
final class MaxNumIcebergOrdersFilter extends SymbolFilter {
  /// Creates a [MaxNumIcebergOrdersFilter].
  const MaxNumIcebergOrdersFilter({required this.maxNumIcebergOrders});

  /// Creates a [MaxNumIcebergOrdersFilter] from a JSON map.
  factory MaxNumIcebergOrdersFilter.fromJson(Map<String, dynamic> json) {
    return MaxNumIcebergOrdersFilter(
      maxNumIcebergOrders: json['maxNumIcebergOrders'] as int,
    );
  }

  /// Maximum number of iceberg orders.
  final int maxNumIcebergOrders;
}

/// Filter for maximum position.
final class MaxPositionFilter extends SymbolFilter {
  /// Creates a [MaxPositionFilter].
  const MaxPositionFilter({required this.maxPosition});

  /// Creates a [MaxPositionFilter] from a JSON map.
  factory MaxPositionFilter.fromJson(Map<String, dynamic> json) {
    return MaxPositionFilter(
      maxPosition: Quantity.fromString(json['maxPosition'] as String),
    );
  }

  /// Maximum position.
  final Quantity maxPosition;
}

/// Filter for trailing delta constraints.
final class TrailingDeltaFilter extends SymbolFilter {
  /// Creates a [TrailingDeltaFilter].
  const TrailingDeltaFilter({
    required this.minTrailingDelta,
    required this.maxTrailingDelta,
  });

  /// Creates a [TrailingDeltaFilter] from a JSON map.
  factory TrailingDeltaFilter.fromJson(Map<String, dynamic> json) {
    return TrailingDeltaFilter(
      minTrailingDelta: json['minTrailingDelta'] as int,
      maxTrailingDelta: json['maxTrailingDelta'] as int,
    );
  }

  /// Minimum trailing delta.
  final int minTrailingDelta;

  /// Maximum trailing delta.
  final int maxTrailingDelta;
}

/// Unknown filter type.
final class UnknownFilter extends SymbolFilter {
  /// Creates an [UnknownFilter].
  const UnknownFilter(this.type, this.data);

  /// The filter type.
  final String type;

  /// The raw filter data.
  final Map<String, dynamic> data;
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

  /// Bids as a list of `(price, quantity)` tuples.
  final List<(Price, Quantity)> bids;

  /// Asks as a list of `(price, quantity)` tuples.
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
