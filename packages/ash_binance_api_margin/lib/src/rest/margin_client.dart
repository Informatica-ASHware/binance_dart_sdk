import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_margin/src/enums.dart';
import 'package:ash_binance_api_margin/src/models/account.dart';
import 'package:ash_binance_api_spot/ash_binance_api_spot.dart';
import 'package:ash_binance_api_margin/src/models/history.dart';

/// Client for Binance Margin REST API.
class BinanceMarginClient {
  /// Creates a [BinanceMarginClient].
  const BinanceMarginClient(this._httpClient);

  final BinanceHttpClient _httpClient;

  // --- Loans ---

  /// Apply for a margin loan.
  ///
  /// Weight: 3000
  Future<Result<int, BinanceError>> borrow({
    required Asset asset,
    required Decimal amount,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {
      'asset': asset.value,
      'amount': amount.toString(),
    };
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/sapi/v1/margin/loan',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 3000,
    );

    final result = await _httpClient.send(request);
    return result.map<int>((dynamic data) => (data as Map)['tranId'] as int);
  }

  /// Repay margin loan.
  ///
  /// Weight: 3000
  Future<Result<int, BinanceError>> repay({
    required Asset asset,
    required Decimal amount,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {
      'asset': asset.value,
      'amount': amount.toString(),
    };
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/sapi/v1/margin/repay',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 3000,
    );

    final result = await _httpClient.send(request);
    return result.map<int>((dynamic data) => (data as Map)['tranId'] as int);
  }

  /// Query margin loan history.
  ///
  /// Weight: 10
  Future<Result<List<MarginLoan>, BinanceError>> getLoanHistory({
    required Asset asset,
    int? txId,
    DateTime? startTime,
    DateTime? endTime,
    int current = 1,
    int size = 10,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {
      'asset': asset.value,
      'current': current.toString(),
      'size': size.toString(),
    };
    if (txId != null) params['txId'] = txId.toString();
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/loan',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<List<MarginLoan>>(
      (dynamic data) => ((data as Map)['rows'] as List)
          .map((e) => MarginLoan.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Query margin repayment history.
  ///
  /// Weight: 10
  Future<Result<List<MarginRepayment>, BinanceError>> getRepayHistory({
    required Asset asset,
    int? txId,
    DateTime? startTime,
    DateTime? endTime,
    int current = 1,
    int size = 10,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {
      'asset': asset.value,
      'current': current.toString(),
      'size': size.toString(),
    };
    if (txId != null) params['txId'] = txId.toString();
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/repay',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<List<MarginRepayment>>(
      (dynamic data) => ((data as Map)['rows'] as List)
          .map((e) => MarginRepayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Query max borrowable amount.
  ///
  /// Weight: 50
  Future<Result<Decimal, BinanceError>> getMaxBorrowable({
    required Asset asset,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {'asset': asset.value};
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/maxBorrowable',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 50,
    );

    final result = await _httpClient.send(request);
    return result.map<Decimal>(
        (dynamic data) => Decimal.parse(data['amount'] as String));
  }

  /// Query max transferable-out amount.
  ///
  /// Weight: 50
  Future<Result<Decimal, BinanceError>> getMaxTransferable({
    required Asset asset,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {'asset': asset.value};
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/maxTransferable',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 50,
    );

    final result = await _httpClient.send(request);
    return result.map<Decimal>(
        (dynamic data) => Decimal.parse(data['amount'] as String));
  }

  // --- Transfers ---

  /// Isolated Margin Account Transfer.
  ///
  /// Weight: 600
  Future<Result<int, BinanceError>> isolatedTransfer({
    required Asset asset,
    required Symbol symbol,
    required MarginTransferType transFrom,
    required MarginTransferType transTo,
    required Decimal amount,
    int? recvWindow,
  }) async {
    final params = {
      'asset': asset.value,
      'symbol': symbol.value,
      'transFrom': transFrom.value.toString(),
      'transTo': transTo.value.toString(),
      'amount': amount.toString(),
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/sapi/v1/margin/isolated/transfer',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 600,
    );

    final result = await _httpClient.send(request);
    return result.map<int>((dynamic data) => (data as Map)['tranId'] as int);
  }

  /// Enable Isolated Margin Account.
  ///
  /// Weight: 300
  Future<Result<bool, BinanceError>> enableIsolatedAccount({
    required Symbol symbol,
    int? recvWindow,
  }) async {
    final params = {'symbol': symbol.value};
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/sapi/v1/margin/isolated/account',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 300,
    );

    final result = await _httpClient.send(request);
    return result.map<bool>((dynamic data) => (data as Map)['success'] as bool);
  }

  /// Disable Isolated Margin Account.
  ///
  /// Weight: 300
  Future<Result<bool, BinanceError>> disableIsolatedAccount({
    required Symbol symbol,
    int? recvWindow,
  }) async {
    final params = {'symbol': symbol.value};
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.delete,
      path: '/sapi/v1/margin/isolated/account',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 300,
    );

    final result = await _httpClient.send(request);
    return result.map<bool>((dynamic data) => (data as Map)['success'] as bool);
  }

  // --- Trading ---

  /// Margin Account New Order.
  ///
  /// Weight: 6
  Future<Result<NewOrderResponse, BinanceError>> newOrder({
    required Symbol symbol,
    required Side side,
    required OrderType type,
    Quantity? quantity,
    Quantity? quoteOrderQty,
    Price? price,
    Price? stopPrice,
    String? newClientOrderId,
    Quantity? icebergQty,
    NewOrderRespType? newOrderRespType,
    MarginSideEffect? sideEffectType,
    TimeInForce? timeInForce,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {
      'symbol': symbol.value,
      'side': side.value,
      'type': type.value,
    };

    if (quantity != null) params['quantity'] = quantity.toString();
    if (quoteOrderQty != null) {
      params['quoteOrderQty'] = quoteOrderQty.toString();
    }
    if (price != null) params['price'] = price.toString();
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (icebergQty != null) params['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null) {
      params['newOrderRespType'] = newOrderRespType.value;
    }
    if (sideEffectType != null) {
      params['sideEffectType'] = sideEffectType.value;
    }
    if (timeInForce != null) params['timeInForce'] = timeInForce.value;
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.post,
      path: '/sapi/v1/margin/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 6,
    );

    final result = await _httpClient.send(request);
    return result.map<NewOrderResponse>(
      (dynamic data) => NewOrderResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Margin Account Cancel Order.
  ///
  /// Weight: 10
  Future<Result<Order, BinanceError>> cancelOrder(
    Symbol symbol, {
    int? orderId,
    String? origClientOrderId,
    String? newClientOrderId,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {'symbol': symbol.value};
    if (orderId != null) params['orderId'] = orderId.toString();
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.delete,
      path: '/sapi/v1/margin/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<Order>(
      (dynamic data) => Order.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Query Margin Account's Order.
  ///
  /// Weight: 10
  Future<Result<Order, BinanceError>> getOrder(
    Symbol symbol, {
    int? orderId,
    String? origClientOrderId,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = {'symbol': symbol.value};
    if (orderId != null) params['orderId'] = orderId.toString();
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<Order>(
      (dynamic data) => Order.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Query Margin Account's Open Orders.
  ///
  /// Weight: 10
  Future<Result<List<Order>, BinanceError>> getOpenOrders({
    Symbol? symbol,
    Symbol? isolatedSymbol,
    int? recvWindow,
  }) async {
    final params = <String, String>{};
    if (symbol != null) params['symbol'] = symbol.value;
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/openOrders',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<List<Order>>(
      (dynamic data) => (data as List<dynamic>)
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Query Margin Account's All Orders.
  ///
  /// Weight: 200
  Future<Result<List<Order>, BinanceError>> getAllOrders(
    Symbol symbol, {
    int? orderId,
    DateTime? startTime,
    DateTime? endTime,
    int limit = 500,
    Symbol? isolatedSymbol,
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
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/allOrders',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 200,
    );

    final result = await _httpClient.send(request);
    return result.map<List<Order>>(
      (dynamic data) => (data as List<dynamic>)
          .map((o) => Order.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Query Margin Account's Trade List.
  ///
  /// Weight: 10
  Future<Result<List<MyTrade>, BinanceError>> getMyTrades(
    Symbol symbol, {
    int? orderId,
    DateTime? startTime,
    DateTime? endTime,
    int? fromId,
    int limit = 500,
    Symbol? isolatedSymbol,
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
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/myTrades',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<List<MyTrade>>(
      (dynamic data) => (data as List<dynamic>)
          .map((t) => MyTrade.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  // --- Account ---

  /// Query Cross Margin Account Details.
  ///
  /// Weight: 10
  Future<Result<MarginAccount, BinanceError>> getAccount({
    int? recvWindow,
  }) async {
    final params = <String, String>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/account',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<MarginAccount>(
      (dynamic data) => MarginAccount.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Query Isolated Margin Account Details.
  ///
  /// Weight: 1
  Future<Result<IsolatedMarginAccount, BinanceError>> getIsolatedAccount({
    List<Symbol>? symbols,
    int? recvWindow,
  }) async {
    final params = <String, String>{};
    if (symbols != null && symbols.isNotEmpty) {
      params['symbols'] = symbols.map((s) => s.value).join(',');
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/isolated/account',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 1,
    );

    final result = await _httpClient.send(request);
    return result.map<IsolatedMarginAccount>(
      (dynamic data) =>
          IsolatedMarginAccount.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Get Force Liquidation Record.
  ///
  /// Weight: 1
  Future<Result<List<Map<String, dynamic>>, BinanceError>>
      getForceLiquidationRec({
    DateTime? startTime,
    DateTime? endTime,
    Symbol? isolatedSymbol,
    int current = 1,
    int size = 10,
    int? recvWindow,
  }) async {
    final params = {
      'current': current.toString(),
      'size': size.toString(),
    };
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (isolatedSymbol != null) params['isolatedSymbol'] = isolatedSymbol.value;
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/forceLiquidationRec',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 1,
    );

    final result = await _httpClient.send(request);
    return result.map<List<Map<String, dynamic>>>(
      (dynamic data) =>
          ((data as Map)['rows'] as List).cast<Map<String, dynamic>>(),
    );
  }

  /// Query Margin PriceIndex.
  ///
  /// Weight: 10
  Future<Result<Decimal, BinanceError>> getPriceIndex(Symbol symbol) async {
    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/priceIndex',
      queryParams: {'symbol': symbol.value},
      securityType: BinanceSecurityType.public,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result
        .map<Decimal>((dynamic data) => Decimal.parse(data['price'] as String));
  }

  /// Get Small Liability Exchange History.
  ///
  /// Weight: 100
  Future<Result<DustLog, BinanceError>> getDustLog({
    DateTime? startTime,
    DateTime? endTime,
    int? recvWindow,
  }) async {
    final params = <String, String>{};
    if (startTime != null) {
      params['startTime'] = startTime.millisecondsSinceEpoch.toString();
    }
    if (endTime != null) {
      params['endTime'] = endTime.millisecondsSinceEpoch.toString();
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow.toString();

    final request = BinanceRequest(
      method: HttpMethod.get,
      path: '/sapi/v1/margin/dustLog',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 100,
    );

    final result = await _httpClient.send(request);
    return result.map<DustLog>(
      (dynamic data) => DustLog.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Query Capital Flow.
  ///
  /// Weight: 10
  Future<Result<List<CapitalFlow>, BinanceError>> getCapitalFlow({
    Asset? asset,
    String? type,
    DateTime? startTime,
    DateTime? endTime,
    int? fromId,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = {'limit': limit.toString()};
    if (asset != null) params['asset'] = asset.value;
    if (type != null) params['type'] = type;
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
      path: '/sapi/v1/margin/capital-flow',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 10,
    );

    final result = await _httpClient.send(request);
    return result.map<List<CapitalFlow>>(
      (dynamic data) => (data as List<dynamic>)
          .map((e) => CapitalFlow.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
