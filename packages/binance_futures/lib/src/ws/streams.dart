import 'package:binance_core/binance_core.dart';

/// WebSocket stream client for Binance Futures.
class BinanceFuturesStreamClient {
  /// Creates a [BinanceFuturesStreamClient].
  BinanceFuturesStreamClient(this._environment, this._client);

  final BinanceEnvironment _environment;
  final WebSocketStreamClient _client;

  /// Subscribe to a single stream.
  Stream<dynamic> subscribe(String stream) {
    return _client.subscribe(stream);
  }

  /// Aggregate Trade Stream.
  Stream<dynamic> aggTrade(Symbol symbol) =>
      subscribe('${symbol.value.toLowerCase()}@aggTrade');

  /// Mark Price Stream.
  Stream<dynamic> markPrice(Symbol symbol, {bool fast = false}) =>
      subscribe('${symbol.value.toLowerCase()}@markPrice${fast ? '@1s' : ''}');

  /// All Market Mark Price Stream.
  Stream<dynamic> allMarkPrice({bool fast = false}) =>
      subscribe('!markPrice@arr${fast ? '@1s' : ''}');

  /// Kline/Candlestick Stream.
  Stream<dynamic> kline(Symbol symbol, Interval interval) =>
      subscribe('${symbol.value.toLowerCase()}@kline_${interval.value}');

  /// Continuous Contract Kline Stream.
  Stream<dynamic> continuousKline(
    Symbol pair,
    String contractType,
    Interval interval,
  ) =>
      subscribe(
        '${pair.value.toLowerCase()}_${contractType.toLowerCase()}@continuousKline_${interval.value}',
      );

  /// Individual Symbol Mini Ticker Stream.
  Stream<dynamic> miniTicker(Symbol symbol) =>
      subscribe('${symbol.value.toLowerCase()}@miniTicker');

  /// Individual Symbol Ticker Stream.
  Stream<dynamic> ticker(Symbol symbol) =>
      subscribe('${symbol.value.toLowerCase()}@ticker');

  /// Individual Symbol Book Ticker Stream.
  Stream<dynamic> bookTicker(Symbol symbol) =>
      subscribe('${symbol.value.toLowerCase()}@bookTicker');

  /// Liquidation Order Stream.
  Stream<dynamic> liquidationOrder(Symbol symbol) =>
      subscribe('${symbol.value.toLowerCase()}@forceOrder');

  /// All Market Liquidation Order Stream.
  Stream<dynamic> allLiquidationOrders() => subscribe('!forceOrder@arr');

  /// Partial Book Depth Stream.
  Stream<dynamic> partialDepth(Symbol symbol, int levels, {String? speed}) =>
      subscribe(
        '${symbol.value.toLowerCase()}@depth$levels'
        '${speed != null ? '@$speed' : ''}',
      );

  /// Diff. Book Depth Stream.
  Stream<dynamic> diffDepth(Symbol symbol, {String? speed}) => subscribe(
        '${symbol.value.toLowerCase()}@depth'
        '${speed != null ? '@$speed' : ''}',
      );

  /// Index Price Stream.
  Stream<dynamic> indexPrice(Symbol pair, {bool fast = false}) =>
      subscribe('${pair.value.toLowerCase()}@indexPrice${fast ? '@1s' : ''}');

  /// Asset Index Stream.
  Stream<dynamic> assetIndex(Asset asset) =>
      subscribe('${asset.value.toLowerCase()}@assetIndex');
}
