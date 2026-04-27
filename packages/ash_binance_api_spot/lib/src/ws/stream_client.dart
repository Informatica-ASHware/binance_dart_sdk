import 'dart:async';
import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_spot/src/models/events/spot_events.dart';
import 'package:ash_binance_api_spot/src/models/market_data.dart';

/// Client for Binance Spot WebSocket Market Streams.
class BinanceSpotStreamClient {
  /// Creates a [BinanceSpotStreamClient].
  BinanceSpotStreamClient({
    required BinanceEnvironment environment,
    required BinanceWebSocketProvider provider,
  }) : _streamClient = WebSocketStreamClient(
          baseUrl: Uri.parse(environment.spotStreamBaseUrl),
          provider: provider,
        );

  final WebSocketStreamClient _streamClient;

  /// Aggregate Trade Stream.
  Stream<AggTradeEvent> aggTrade(Symbol symbol) {
    return _streamClient
        .subscribe('${symbol.value.toLowerCase()}@aggTrade')
        .map((data) => AggTradeEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Trade Stream.
  Stream<TradeEvent> trade(Symbol symbol) {
    return _streamClient
        .subscribe('${symbol.value.toLowerCase()}@trade')
        .map((data) => TradeEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Kline/Candlestick Streams.
  Stream<KlineEvent> kline(Symbol symbol, Interval interval) {
    return _streamClient
        .subscribe('${symbol.value.toLowerCase()}@kline_${interval.value}')
        .map((data) => KlineEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Individual Symbol Mini Ticker Stream.
  Stream<MiniTickerEvent> miniTicker(Symbol symbol) {
    return _streamClient
        .subscribe('${symbol.value.toLowerCase()}@miniTicker')
        .map((data) => MiniTickerEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Individual Symbol Ticker Stream.
  Stream<TickerEvent> ticker(Symbol symbol) {
    return _streamClient
        .subscribe('${symbol.value.toLowerCase()}@ticker')
        .map((data) => TickerEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Individual Symbol Book Ticker Stream.
  Stream<BookTickerEvent> bookTicker(Symbol symbol) {
    return _streamClient
        .subscribe('${symbol.value.toLowerCase()}@bookTicker')
        .map((data) => BookTickerEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Partial Book Depth Streams.
  Stream<OrderBook> partialDepth(Symbol symbol, int levels, {String? speed}) {
    var stream = '${symbol.value.toLowerCase()}@depth$levels';
    if (speed != null) stream += '@$speed';
    return _streamClient
        .subscribe(stream)
        .map((data) => OrderBook.fromJson(data as Map<String, dynamic>));
  }

  /// Diff. Depth Stream.
  Stream<DepthUpdateEvent> depthUpdate(Symbol symbol, {String? speed}) {
    var stream = '${symbol.value.toLowerCase()}@depth';
    if (speed != null) stream += '@$speed';
    return _streamClient
        .subscribe(stream)
        .map((data) => DepthUpdateEvent.fromJson(data as Map<String, dynamic>));
  }

  /// Listens to user data stream.
  Stream<SpotEvent> userData(String listenKey) {
    return _streamClient.subscribe(listenKey).map((data) {
      final map = data as Map<String, dynamic>;
      final type = map['e'] as String;
      return switch (type) {
        'executionReport' => ExecutionReportEvent.fromJson(map),
        'outboundAccountPosition' => OutboundAccountPositionEvent.fromJson(map),
        _ => throw UnimplementedError('Unknown user data event type: $type'),
      };
    });
  }

  /// Closes the client.
  Future<void> close() => _streamClient.close();
}
