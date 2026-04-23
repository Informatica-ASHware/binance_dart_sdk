import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:binance_spot/src/models/account.dart';

/// Client for Binance Spot SOR (Smart Order Routing) REST API.
class BinanceSpotSorClient {
  /// Creates a [BinanceSpotSorClient].
  const BinanceSpotSorClient(this._httpClient);

  final BinanceHttpClient _httpClient;

  /// Places an order using SOR.
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
      path: '/api/v3/sor/order',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 1,
    );

    final result = await _httpClient.send(request);
    return result.map(
      (data) => NewOrderResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Test SOR order creation.
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
      path: '/api/v3/sor/order/test',
      queryParams: params,
      securityType: BinanceSecurityType.signed,
      weight: 1,
    );

    final result = await _httpClient.send(request);
    return result.map((_) => null);
  }
}
