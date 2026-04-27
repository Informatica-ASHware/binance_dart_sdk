import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_spot/src/models/market_data.dart';

/// Client for Binance Spot Market Data REST API.
class BinanceSpotMarketDataClient {
  /// Creates a [BinanceSpotMarketDataClient].
  const BinanceSpotMarketDataClient(this._httpClient);

  final BinanceHttpClient _httpClient;

  /// Test connectivity to the Rest API.
  ///
  /// Weight: 1
  Future<Result<void, BinanceError>> ping() async {
    const request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/ping',
    );
    final result = await _httpClient.send(request);
    return result.map((_) {});
  }

  /// Check server time.
  ///
  /// Weight: 1
  Future<Result<DateTime, BinanceError>> time() async {
    const request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/time',
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) => DateTime.fromMillisecondsSinceEpoch(
        (data as Map<String, dynamic>)['serverTime'] as int,
      ),
    );
  }

  /// Current exchange trading rules and symbol information.
  ///
  /// Weight: 20
  Future<Result<ExchangeInfo, BinanceError>> exchangeInfo({
    List<Symbol>? symbols,
    List<String>? permissions,
  }) async {
    final builder = BinanceRequest.builder()
        .method(HttpMethod.get)
        .path('/api/v3/exchangeInfo')
        .weight(20);

    if (symbols != null && symbols.isNotEmpty) {
      builder.queryParam(
        'symbols',
        '[${symbols.map((s) => '"$s"').join(',')}]',
      );
    }
    if (permissions != null && permissions.isNotEmpty) {
      builder.queryParam(
        'permissions',
        '[${permissions.map((p) => '"$p"').join(',')}]',
      );
    }

    final result = await _httpClient.send(builder.build());
    return result
        .map((data) => ExchangeInfo.fromJson(data as Map<String, dynamic>));
  }

  /// Order book.
  ///
  /// Weight: Adjusted based on limit.
  Future<Result<OrderBook, BinanceError>> depth(
    Symbol symbol, {
    int limit = 100,
  }) async {
    final weight = _getDepthWeight(limit);
    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/depth',
      queryParams: {
        'symbol': symbol.value,
        'limit': limit.toString(),
      },
      weight: weight,
    );
    final result = await _httpClient.send(request);
    return result
        .map((data) => OrderBook.fromJson(data as Map<String, dynamic>));
  }

  int _getDepthWeight(int limit) {
    if (limit <= 100) return 5;
    if (limit <= 500) return 25;
    if (limit <= 1000) return 50;
    if (limit <= 5000) return 250;
    return 1;
  }

  /// Recent trades list.
  ///
  /// Weight: 10
  Future<Result<List<Trade>, BinanceError>> trades(
    Symbol symbol, {
    int limit = 500,
  }) async {
    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/trades',
      queryParams: {
        'symbol': symbol.value,
        'limit': limit.toString(),
      },
      weight: 10,
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) => (data as List<dynamic>)
          .map((t) => Trade.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Old trade lookup.
  ///
  /// Weight: 10
  Future<Result<List<Trade>, BinanceError>> historicalTrades(
    Symbol symbol, {
    int limit = 500,
    int? fromId,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (fromId != null) params['fromId'] = fromId.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/historicalTrades',
      queryParams: params,
      securityType: BinanceSecurityType.marketData,
      weight: 10,
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) => (data as List<dynamic>)
          .map((t) => Trade.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Compressed, Aggregate Trades List.
  ///
  /// Weight: 2
  Future<Result<List<AggTrade>, BinanceError>> aggTrades(
    Symbol symbol, {
    int? fromId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (fromId != null) params['fromId'] = fromId.toString();
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/aggTrades',
      queryParams: params,
      weight: 2,
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) => (data as List<dynamic>)
          .map((t) => AggTrade.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Kline/Candlestick bars for a symbol.
  ///
  /// Weight: 2
  Future<Result<List<Kline>, BinanceError>> klines(
    Symbol symbol,
    Interval interval, {
    DateTime? startTime,
    DateTime? endTime,
    int? timeZone,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'interval': interval.value,
      'limit': limit.toString(),
    };
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (timeZone != null) params['timeZone'] = timeZone.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/klines',
      queryParams: params,
      weight: 2,
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) => (data as List<dynamic>)
          .map((k) => Kline.fromJson(k as List<dynamic>))
          .toList(),
    );
  }

  /// UI Kline/Candlestick bars for a symbol.
  ///
  /// Weight: 2
  Future<Result<List<Kline>, BinanceError>> uiKlines(
    Symbol symbol,
    Interval interval, {
    DateTime? startTime,
    DateTime? endTime,
    int? timeZone,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'interval': interval.value,
      'limit': limit.toString(),
    };
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (timeZone != null) params['timeZone'] = timeZone.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/uiKlines',
      queryParams: params,
      weight: 2,
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) => (data as List<dynamic>)
          .map((k) => Kline.fromJson(k as List<dynamic>))
          .toList(),
    );
  }

  /// Current average price for a symbol.
  ///
  /// Weight: 2
  Future<Result<Price, BinanceError>> avgPrice(Symbol symbol) async {
    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/avgPrice',
      queryParams: {'symbol': symbol.value},
      weight: 2,
    );
    final result = await _httpClient.send(request);
    return result.map(
      (data) =>
          Price.fromString((data as Map<String, dynamic>)['price'] as String),
    );
  }

  /// 24 hour rolling window price change statistics.
  ///
  /// Weight: 2 for single symbol, 80 for all.
  Future<Result<dynamic, BinanceError>> ticker24hr({
    Symbol? symbol,
    List<Symbol>? symbols,
    String? type,
  }) async {
    final params = <String, String>{};
    var weight = 2;
    if (symbol != null) {
      params['symbol'] = symbol.value;
    } else if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = '[${symbols.map((s) => '"$s"').join(',')}]';
      weight = 40; // Approx
    } else {
      weight = 80;
    }
    if (type != null) params['type'] = type;

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/ticker/24hr',
      queryParams: params,
      weight: weight,
    );
    final result = await _httpClient.send(request);
    return result.map((data) {
      if (data is List) {
        return data
            .map((t) => TickerStatistics.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      return TickerStatistics.fromJson(data as Map<String, dynamic>);
    });
  }

  /// Latest price for a symbol or symbols.
  ///
  /// Weight: 2 for single symbol, 4 for all.
  Future<Result<dynamic, BinanceError>> tickerPrice({
    Symbol? symbol,
    List<Symbol>? symbols,
  }) async {
    final params = <String, String>{};
    var weight = 2;
    if (symbol != null) {
      params['symbol'] = symbol.value;
    } else if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = '[${symbols.map((s) => '"$s"').join(',')}]';
      weight = 4;
    } else {
      weight = 4;
    }

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/ticker/price',
      queryParams: params,
      weight: weight,
    );
    final result = await _httpClient.send(request);
    return result.map((data) {
      if (data is List) {
        return data
            .map((t) => PriceTicker.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      return PriceTicker.fromJson(data as Map<String, dynamic>);
    });
  }

  /// Best price/qty on the order book for a symbol or symbols.
  ///
  /// Weight: 2 for single symbol, 4 for all.
  Future<Result<dynamic, BinanceError>> tickerBookTicker({
    Symbol? symbol,
    List<Symbol>? symbols,
  }) async {
    final params = <String, String>{};
    var weight = 2;
    if (symbol != null) {
      params['symbol'] = symbol.value;
    } else if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = '[${symbols.map((s) => '"$s"').join(',')}]';
      weight = 4;
    } else {
      weight = 4;
    }

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/ticker/bookTicker',
      queryParams: params,
      weight: weight,
    );
    final result = await _httpClient.send(request);
    return result.map((data) {
      if (data is List) {
        return data
            .map((t) => BookTicker.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      return BookTicker.fromJson(data as Map<String, dynamic>);
    });
  }

  /// Rolling window price change statistics.
  ///
  /// Weight: 4 for single symbol, 200 for all symbols.
  Future<Result<dynamic, BinanceError>> ticker({
    Symbol? symbol,
    List<Symbol>? symbols,
    String? windowSize,
    String? type,
  }) async {
    final params = <String, String>{};
    var weight = 4;
    if (symbol != null) {
      params['symbol'] = symbol.value;
    } else if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = '[${symbols.map((s) => '"$s"').join(',')}]';
      weight = 100; // Guessing mid-weight
    } else {
      weight = 200;
    }
    if (windowSize != null) params['windowSize'] = windowSize;
    if (type != null) params['type'] = type;

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/ticker',
      queryParams: params,
      weight: weight,
    );
    final result = await _httpClient.send(request);
    return result.map((data) {
      if (data is List) {
        return data
            .map((t) => RollingWindowTicker.fromJson(t as Map<String, dynamic>))
            .toList();
      }
      return RollingWindowTicker.fromJson(data as Map<String, dynamic>);
    });
  }
}
