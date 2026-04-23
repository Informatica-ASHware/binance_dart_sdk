import 'package:binance_core/binance_core.dart';
import 'package:binance_futures/src/models/market.dart';

/// REST Market Data API for Binance Futures.
class BinanceFuturesMarketDataRest {
  /// Creates a [BinanceFuturesMarketDataRest].
  BinanceFuturesMarketDataRest(this._client);

  final BinanceHttpClient _client;

  /// Test connectivity.
  Future<Result<dynamic, BinanceError>> ping() async {
    return _client.send(
      const BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/ping',
      ),
    );
  }

  /// Check server time.
  Future<Result<int, BinanceError>> time() async {
    final result = await _client.send(
      const BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/time',
      ),
    );

    return result.map(
      (data) => (data as Map<String, dynamic>)['serverTime'] as int,
    );
  }

  /// Get exchange information.
  Future<Result<Map<String, dynamic>, BinanceError>> exchangeInfo() async {
    final result = await _client.send(
      const BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/exchangeInfo',
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Get order book.
  Future<Result<Map<String, dynamic>, BinanceError>> depth(
    Symbol symbol, {
    int limit = 100,
  }) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/depth',
        queryParams: {
          'symbol': symbol.value,
          'limit': limit.toString(),
        },
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Recent trades list.
  Future<Result<List<dynamic>, BinanceError>> trades(
    Symbol symbol, {
    int limit = 500,
  }) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/trades',
        queryParams: {
          'symbol': symbol.value,
          'limit': limit.toString(),
        },
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Old trades lookup (requires API key).
  Future<Result<List<dynamic>, BinanceError>> historicalTrades(
    Symbol symbol, {
    int limit = 500,
    int? fromId,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (fromId != null) params['fromId'] = fromId.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/historicalTrades',
        queryParams: params,
        securityType: BinanceSecurityType.marketData,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Compressed/Aggregate trades list.
  Future<Result<List<dynamic>, BinanceError>> aggTrades(
    Symbol symbol, {
    int? fromId,
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (fromId != null) params['fromId'] = fromId.toString();
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/aggTrades',
        queryParams: params,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get klines.
  Future<Result<List<dynamic>, BinanceError>> klines(
    Symbol symbol,
    Interval interval, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'interval': interval.value,
      'limit': limit.toString(),
    };
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/klines',
        queryParams: params,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get continuous contract klines.
  Future<Result<List<dynamic>, BinanceError>> continuousKlines(
    Symbol pair,
    String contractType,
    Interval interval, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = {
      'pair': pair.value,
      'contractType': contractType,
      'interval': interval.value,
      'limit': limit.toString(),
    };
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/continuousKlines',
        queryParams: params,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get mark price and funding rate.
  Future<Result<List<MarkPrice>, BinanceError>> markPrice({
    Symbol? symbol,
  }) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/premiumIndex',
        queryParams: params,
      ),
    );

    return result.map((data) {
      if (data is List) {
        return data
            .map((e) => MarkPrice.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [MarkPrice.fromJson(data as Map<String, dynamic>)];
      }
    });
  }

  /// Get funding rate history.
  Future<Result<List<FundingRate>, BinanceError>> fundingRate({
    Symbol? symbol,
    int? startTime,
    int? endTime,
    int limit = 100,
  }) async {
    final params = <String, String>{'limit': limit.toString()};
    if (symbol != null) params['symbol'] = symbol.value;
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/fundingRate',
        queryParams: params,
      ),
    );

    return result.map(
      (data) => (data as List)
          .map((e) => FundingRate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get 24hr ticker price change statistics.
  Future<Result<dynamic, BinanceError>> ticker24hr({Symbol? symbol}) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;

    return _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/ticker/24hr',
        queryParams: params,
      ),
    );
  }

  /// Symbol price ticker.
  Future<Result<dynamic, BinanceError>> tickerPrice({Symbol? symbol}) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;

    return _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/ticker/price',
        queryParams: params,
      ),
    );
  }

  /// Symbol order book ticker.
  Future<Result<dynamic, BinanceError>> tickerBookTicker({
    Symbol? symbol,
  }) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;

    return _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/ticker/bookTicker',
        queryParams: params,
      ),
    );
  }

  /// Get open interest.
  Future<Result<Map<String, dynamic>, BinanceError>> openInterest(
    Symbol symbol,
  ) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/openInterest',
        queryParams: {'symbol': symbol.value},
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }
}
