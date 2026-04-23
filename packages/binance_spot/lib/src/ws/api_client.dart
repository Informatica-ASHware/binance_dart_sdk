import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:binance_spot/src/models/account.dart';
import 'package:binance_spot/src/models/market_data.dart';

/// Client for Binance Spot WebSocket API (Request-Response over WS).
class BinanceSpotWsApiClient {
  /// Creates a [BinanceSpotWsApiClient].
  BinanceSpotWsApiClient(this._apiClient);

  final WebSocketApiClient _apiClient;

  /// Underlying API client status.
  Stream<WebSocketApiClientStatus> get status => _apiClient.status;

  /// Underlying API client unsolicited events.
  Stream<dynamic> get events => _apiClient.events;

  /// Connects to the WebSocket API.
  Future<void> connect() => _apiClient.connect();

  /// Logs in to the session.
  Future<void> logon(BinanceCredentials credentials) =>
      _apiClient.logon(credentials);

  /// Logs out of the session.
  Future<void> logout() => _apiClient.logout();

  /// Gets the current session status.
  Future<dynamic> getSessionStatus() => _apiClient.getSessionStatus();

  /// Ping the server.
  Future<Result<void, BinanceError>> ping() async {
    final response = await _apiClient.sendRequest('ping');
    return _handleResponse(response, (_) => null);
  }

  /// Get server time.
  Future<Result<DateTime, BinanceError>> time() async {
    final response = await _apiClient.sendRequest('time');
    return _handleResponse(
      response,
      (data) => DateTime.fromMillisecondsSinceEpoch(data['serverTime'] as int),
    );
  }

  /// Get exchange information.
  Future<Result<ExchangeInfo, BinanceError>> exchangeInfo({
    List<Symbol>? symbols,
    List<String>? permissions,
  }) async {
    final params = <String, dynamic>{};
    if (symbols != null)
      params['symbols'] = symbols.map((s) => s.value).toList();
    if (permissions != null) params['permissions'] = permissions;

    final response = await _apiClient.sendRequest('exchangeInfo', params);
    return _handleResponse(response,
        (data) => ExchangeInfo.fromJson(data as Map<String, dynamic>));
  }

  /// New order.
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
  }) async {
    final params = {
      'symbol': symbol.value,
      'side': side.value,
      'type': type.value,
    };
    if (timeInForce != null) params['timeInForce'] = timeInForce.value;
    if (quantity != null) params['quantity'] = quantity.toString();
    if (quoteOrderQty != null)
      params['quoteOrderQty'] = quoteOrderQty.toString();
    if (price != null) params['price'] = price.toString();
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice.toString();
    if (icebergQty != null) params['icebergQty'] = icebergQty.toString();
    if (newOrderRespType != null)
      params['newOrderRespType'] = newOrderRespType.value;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode.value;
    }

    final response = await _apiClient.sendRequest('order.place', params);
    return _handleResponse(
      response,
      (data) => NewOrderResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  Result<T, BinanceError> _handleResponse<T>(
    dynamic response,
    T Function(dynamic data) mapper,
  ) {
    if (response is! Map) {
      return Result.failure(
        BinanceNetworkError(message: 'Invalid WS API response: $response'),
      );
    }

    final status = response['status'] as int?;
    if (status == 200) {
      return Result.success(mapper(response['result']));
    }

    final error = response['error'] as Map?;
    if (error != null) {
      return Result.failure(
        BinanceApiError(
          code: error['code'] as int? ?? -1,
          message: error['msg'] as String? ?? 'Unknown WS error',
        ),
      );
    }

    return Result.failure(
      BinanceNetworkError(message: 'WS API error $status: $response'),
    );
  }

  /// Closes the client.
  Future<void> close() => _apiClient.close();
}
