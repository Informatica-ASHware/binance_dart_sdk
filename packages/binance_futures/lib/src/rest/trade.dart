import 'dart:convert';
import 'package:binance_core/binance_core.dart';
import 'package:binance_futures/src/enums.dart';
import 'package:binance_futures/src/models/order.dart';

/// REST Trade API for Binance Futures.
class BinanceFuturesTradeRest {
  /// Creates a [BinanceFuturesTradeRest].
  BinanceFuturesTradeRest(this._client);

  final BinanceHttpClient _client;

  /// New order.
  Future<Result<FuturesOrder, BinanceError>> newOrder({
    required Symbol symbol,
    required String side,
    required String type,
    PositionSide? positionSide,
    Decimal? quantity,
    Decimal? price,
    String? timeInForce,
    Decimal? stopPrice,
    bool? closePosition,
    Decimal? activationPrice,
    Decimal? callbackRate,
    WorkingType? workingType,
    String? priceProtect,
    String? newClientOrderId,
    String? responseType,
    bool? reduceOnly,
  }) async {
    final params = {
      'symbol': symbol.value,
      'side': side,
      'type': type,
    };

    if (positionSide != null) params['positionSide'] = positionSide.value;
    if (quantity != null) params['quantity'] = quantity.toString();
    if (price != null) params['price'] = price.toString();
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (closePosition != null) {
      params['closePosition'] = closePosition.toString();
    }
    if (activationPrice != null) {
      params['activationPrice'] = activationPrice.toString();
    }
    if (callbackRate != null) params['callbackRate'] = callbackRate.toString();
    if (workingType != null) params['workingType'] = workingType.value;
    if (priceProtect != null) params['priceProtect'] = priceProtect;
    if (newClientOrderId != null) {
      params['newClientOrderId'] = newClientOrderId;
    }
    if (responseType != null) params['newOrderRespType'] = responseType;
    if (reduceOnly != null) params['reduceOnly'] = reduceOnly.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/order',
        queryParams: params,
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result
        .map((data) => FuturesOrder.fromJson(data as Map<String, dynamic>));
  }

  /// Place multiple orders.
  Future<Result<List<dynamic>, BinanceError>> batchOrders(
    List<Map<String, dynamic>> orders,
  ) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/batchOrders',
        queryParams: {
          'batchOrders': json.encode(orders),
        },
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Cancel order.
  Future<Result<FuturesOrder, BinanceError>> cancelOrder(
    Symbol symbol, {
    int? orderId,
    String? origClientOrderId,
  }) async {
    final params = {'symbol': symbol.value};
    if (orderId != null) params['orderId'] = orderId.toString();
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.delete,
        path: '/fapi/v1/order',
        queryParams: params,
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result
        .map((data) => FuturesOrder.fromJson(data as Map<String, dynamic>));
  }

  /// Cancel all open orders for a symbol.
  Future<Result<Map<String, dynamic>, BinanceError>> cancelAllOpenOrders(
    Symbol symbol,
  ) async {
    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.delete,
        path: '/fapi/v1/allOpenOrders',
        queryParams: {'symbol': symbol.value},
        securityType: BinanceSecurityType.signed,
      ),
    );

    return result.map((data) => data as Map<String, dynamic>);
  }

  /// Get order.
  Future<Result<FuturesOrder, BinanceError>> getOrder(
    Symbol symbol, {
    int? orderId,
    String? origClientOrderId,
  }) async {
    final params = {'symbol': symbol.value};
    if (orderId != null) params['orderId'] = orderId.toString();
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/order',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result
        .map((data) => FuturesOrder.fromJson(data as Map<String, dynamic>));
  }

  /// Test new order.
  Future<Result<dynamic, BinanceError>> testOrder({
    required Symbol symbol,
    required String side,
    required String type,
    PositionSide? positionSide,
    Decimal? quantity,
    Decimal? price,
    String? timeInForce,
    Decimal? stopPrice,
    bool? closePosition,
    Decimal? activationPrice,
    Decimal? callbackRate,
    WorkingType? workingType,
    String? priceProtect,
    String? newClientOrderId,
    String? responseType,
    bool? reduceOnly,
  }) async {
    final params = {
      'symbol': symbol.value,
      'side': side,
      'type': type,
    };

    if (positionSide != null) params['positionSide'] = positionSide.value;
    if (quantity != null) params['quantity'] = quantity.toString();
    if (price != null) params['price'] = price.toString();
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (closePosition != null) {
      params['closePosition'] = closePosition.toString();
    }
    if (activationPrice != null) {
      params['activationPrice'] = activationPrice.toString();
    }
    if (callbackRate != null) params['callbackRate'] = callbackRate.toString();
    if (workingType != null) params['workingType'] = workingType.value;
    if (priceProtect != null) params['priceProtect'] = priceProtect;
    if (newClientOrderId != null) {
      params['newClientOrderId'] = newClientOrderId;
    }
    if (responseType != null) params['newOrderRespType'] = responseType;
    if (reduceOnly != null) params['reduceOnly'] = reduceOnly.toString();

    return _client.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: '/fapi/v1/order/test',
        queryParams: params,
        securityType: BinanceSecurityType.signed,
      ),
    );
  }

  /// Get all open orders.
  Future<Result<List<FuturesOrder>, BinanceError>> getOpenOrders({
    Symbol? symbol,
  }) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/openOrders',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map(
      (data) => (data as List)
          .map((e) => FuturesOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get all orders.
  Future<Result<List<FuturesOrder>, BinanceError>> getAllOrders(
    Symbol symbol, {
    int? orderId,
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (orderId != null) params['orderId'] = orderId.toString();
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/allOrders',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map(
      (data) => (data as List)
          .map((e) => FuturesOrder.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get user force orders.
  Future<Result<List<dynamic>, BinanceError>> getForceOrders({
    Symbol? symbol,
    bool? autoCloseType,
    int? startTime,
    int? endTime,
    int limit = 100,
  }) async {
    final params = {'limit': limit.toString()};
    if (symbol != null) params['symbol'] = symbol.value;
    if (autoCloseType != null) {
      params['autoCloseType'] = autoCloseType ? 'LIQUIDATION' : 'ADL';
    }
    if (startTime != null) params['startTime'] = startTime.toString();
    if (endTime != null) params['endTime'] = endTime.toString();

    final result = await _client.send(
      BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/forceOrders',
        queryParams: params,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }

  /// Get order rate limit.
  Future<Result<List<dynamic>, BinanceError>> getOrderRateLimit() async {
    final result = await _client.send(
      const BinanceRequest(
        method: HttpMethod.get,
        path: '/fapi/v1/rateLimit/order',
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.map((data) => data as List<dynamic>);
  }
}
