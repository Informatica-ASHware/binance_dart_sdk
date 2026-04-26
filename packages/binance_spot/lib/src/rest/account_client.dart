import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:binance_spot/src/models/account.dart';

/// Client for Binance Spot Account and Trade REST API.
class BinanceSpotAccountClient {
  /// Creates a [BinanceSpotAccountClient].
  const BinanceSpotAccountClient(this._httpClient);

  final BinanceHttpClient _httpClient;

  /// Send in a new order.
  ///
  /// Weight: 1
  Future<Result<NewOrderResponse, BinanceError>> newOrder({
    required Symbol symbol,
    required Side side,
    required OrderType type,
    TimeInForce? timeInForce,
    Quantity? quantity,
    Quantity? quoteOrderQty,
    Price? price,
    String? newClientOrderId,
    Price? stopPrice,
    Quantity? icebergQty,
    NewOrderRespType? newOrderRespType,
    SelfTradePreventionMode? selfTradePreventionMode,
    int? recvWindow,
  }) async {
    final params = {
      'symbol': symbol.value,
      'side': side.value,
      'type': type.value,
    };

    if (timeInForce != null) params['timeInForce'] = timeInForce.value;
    if (quantity != null) params['quantity'] = quantity.toString();
    if (quoteOrderQty != null) {
      params['quoteOrderQty'] = quoteOrderQty.toString();
    }
    if (price != null) params['price'] = price.toString();
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (icebergQty != null) params['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null) {
      params['newOrderRespType'] = newOrderRespType.value;
    }
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode.value;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/api/v3/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
    );

    final result = await _httpClient.send(request);
    return result.map<NewOrderResponse>(
      (dynamic data) => NewOrderResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Test new order creation and signature/params.
  ///
  /// Weight: 1
  Future<Result<void, BinanceError>> testNewOrder({
    required Symbol symbol,
    required Side side,
    required OrderType type,
    TimeInForce? timeInForce,
    Quantity? quantity,
    Quantity? quoteOrderQty,
    Price? price,
    String? newClientOrderId,
    Price? stopPrice,
    Quantity? icebergQty,
    NewOrderRespType? newOrderRespType,
    SelfTradePreventionMode? selfTradePreventionMode,
    int? recvWindow,
  }) async {
    final params = {
      'symbol': symbol.value,
      'side': side.value,
      'type': type.value,
    };

    if (timeInForce != null) params['timeInForce'] = timeInForce.value;
    if (quantity != null) params['quantity'] = quantity.toString();
    if (quoteOrderQty != null) {
      params['quoteOrderQty'] = quoteOrderQty.toString();
    }
    if (price != null) params['price'] = price.toString();
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (icebergQty != null) params['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null) {
      params['newOrderRespType'] = newOrderRespType.value;
    }
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode.value;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/api/v3/order/test',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
    );

    final result = await _httpClient.send(request);
    return result.map<void>((dynamic _) {});
  }

  /// Check an order's status.
  ///
  /// Weight: 4
  Future<Result<Order, BinanceError>> getOrder(
    Symbol symbol, {
    int? orderId,
    String? origClientOrderId,
    int? recvWindow,
  }) async {
    final params = {'symbol': symbol.value};
    if (orderId != null) params['orderId'] = orderId.toString();
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 4,
    );

    final result = await _httpClient.send(request);
    return result.map<Order>(
      (dynamic data) => Order.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Cancel an active order.
  ///
  /// Weight: 1
  Future<Result<Order, BinanceError>> cancelOrder(
    Symbol symbol, {
    int? orderId,
    String? origClientOrderId,
    String? newClientOrderId,
    int? recvWindow,
  }) async {
    final params = {'symbol': symbol.value};
    if (orderId != null) params['orderId'] = orderId.toString();
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.delete,
      path: '/api/v3/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
    );

    final result = await _httpClient.send(request);
    return result.map<Order>(
      (dynamic data) => Order.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get current account information.
  ///
  /// Weight: 20
  Future<Result<AccountInfo, BinanceError>> getAccount({
    bool? omitZeroBalances,
    int? recvWindow,
  }) async {
    final params = <String, String>{};
    if (omitZeroBalances != null) {
      params['omitZeroBalances'] = omitZeroBalances.toString();
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/account',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 20,
    );

    final result = await _httpClient.send(request);
    return result.map<AccountInfo>(
      (dynamic data) => AccountInfo.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get all open orders on a symbol.
  ///
  /// Weight: 6 for a single symbol; 80 when the symbol parameter is omitted.
  Future<Result<List<Order>, BinanceError>> getOpenOrders({
    Symbol? symbol,
    int? recvWindow,
  }) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/openOrders',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: symbol != null ? 6 : 80,
    );

    final result = await _httpClient.send(request);
    return result.map<List<Order>>(
      (dynamic data) => (data as List<dynamic>)
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get all account orders; active, canceled, or filled.
  ///
  /// Weight: 20
  Future<Result<List<Order>, BinanceError>> getAllOrders(
    Symbol symbol, {
    int? orderId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (orderId != null) params['orderId'] = orderId.toString();
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/allOrders',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 20,
    );

    final result = await _httpClient.send(request);
    return result.map<List<Order>>(
      (dynamic data) => (data as List<dynamic>)
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get trades for a specific account and symbol.
  ///
  /// Weight: 20
  Future<Result<List<MyTrade>, BinanceError>> getMyTrades(
    Symbol symbol, {
    int? orderId,
    DateTime? startTime,
    DateTime? endTime,
    int? fromId,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = {
      'symbol': symbol.value,
      'limit': limit.toString(),
    };
    if (orderId != null) params['orderId'] = orderId.toString();
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (fromId != null) params['fromId'] = fromId.toString();
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/api/v3/myTrades',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 20,
    );

    final result = await _httpClient.send(request);
    return result.map<List<MyTrade>>(
      (dynamic data) => (data as List<dynamic>)
          .map((t) => MyTrade.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}
