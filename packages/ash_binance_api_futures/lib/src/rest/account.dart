import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_futures/src/enums.dart';
import 'package:ash_binance_api_futures/src/models/futures_position.dart';
import 'package:ash_binance_api_futures/src/models/market.dart';

/// REST Account API for Binance Futures.
class BinanceFuturesAccountRest {
  /// Creates a [BinanceFuturesAccountRest].
  BinanceFuturesAccountRest(this._client);

  final BinanceHttpClient _client;

  /// Get account information.
  Future<Result<Map<String, dynamic>, BinanceError>> getAccountInfo() async {
    final result = await _client.send(
      const BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v2/account',
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Get account balances.
  Future<Result<List<dynamic>, BinanceError>> getBalances() async {
    final result = await _client.send(
      const BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v2/balance',
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get position risk.
  Future<Result<List<FuturesPosition>, BinanceError>> getPositionRisk({
    Symbol? symbol,
  }) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v2/positionRisk',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map(
      (data) => (data as List)
          .map((e) => FuturesPosition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Change leverage.
  Future<Result<Map<String, dynamic>, BinanceError>> changeLeverage(
    Symbol symbol,
    int leverage,
  ) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/leverage',
        queryParams: {
          'symbol': symbol.value,
          'leverage': leverage.toString(),
        },
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Change margin type.
  Future<Result<Map<String, dynamic>, BinanceError>> changeMarginType(
    Symbol symbol,
    MarginType marginType,
  ) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/marginType',
        queryParams: {
          'symbol': symbol.value,
          'marginType': marginType.value,
        },
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Modify isolated position margin.
  Future<Result<Map<String, dynamic>, BinanceError>> modifyPositionMargin(
    Symbol symbol,
    Decimal amount,
    int type, {
    PositionSide? positionSide,
  }) async {
    final params = {
      'symbol': symbol.value,
      'amount': amount.toString(),
      'type': type.toString(),
    };
    if (positionSide != null) params['positionSide'] = positionSide.value;

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/positionMargin',
        queryParams: params,
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Get position margin change history.
  Future<Result<List<dynamic>, BinanceError>> getPositionMarginHistory(
    Symbol symbol, {
    int? type,
    int? startTime,
    int? endTime,
    int limit = 100,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (type != null) params['type'] = type.toString();
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/positionMargin/history',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get income history.
  Future<Result<List<Income>, BinanceError>> getIncomeHistory({
    Symbol? symbol,
    String? incomeType,
    int? startTime,
    int? endTime,
    int limit = 100,
  }) async {
    final params = {'limit': limit.toString()};
    if (symbol != null) params['symbol'] = symbol.value;
    if (incomeType != null) params['incomeType'] = incomeType;
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/income',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map(
      (data) => (data as List)
          .map((e) => Income.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get user trades.
  Future<Result<List<dynamic>, BinanceError>> getUserTrades(
    Symbol symbol, {
    int? startTime,
    int? endTime,
    int? fromId,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();
    if (fromId != null) params['fromId'] = fromId.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/userTrades',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get commission rate.
  Future<Result<Map<String, dynamic>, BinanceError>> getCommissionRate(
    Symbol symbol,
  ) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/commissionRate',
        queryParams: {'symbol': symbol.value},
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Get portfolio margin account info.
  Future<Result<Map<String, dynamic>, BinanceError>> getPmAccountInfo({
    Asset? asset,
  }) async {
    final params = <String, String>{};
    if (asset != null) params['asset'] = asset.value;

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/pmAccountInfo',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Change multi-assets mode.
  Future<Result<Map<String, dynamic>, BinanceError>> changeMultiAssetsMode({
    required bool multiAssetsMargin,
  }) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/multiAssetsMargin',
        queryParams: {'multiAssetsMargin': multiAssetsMargin.toString()},
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }
}
