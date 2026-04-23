import 'dart:async';
import 'package:binance_core/binance_core.dart';

/// WebSocket API client for Binance Futures.
class BinanceFuturesWsApi {
  /// Creates a [BinanceFuturesWsApi].
  BinanceFuturesWsApi(this._apiClient);

  final WebSocketApiClient _apiClient;

  /// Connect to the WebSocket API.
  Future<void> connect() => _apiClient.connect();

  /// Log in with credentials.
  Future<void> logon(BinanceCredentials credentials) =>
      _apiClient.logon(credentials);

  /// Send a request and wait for the response.
  Future<dynamic> sendRequest(
    String method, {
    Map<String, dynamic>? params,
  }) =>
      _apiClient.sendRequest(method, params);

  /// Place a new order via WebSocket API.
  Future<dynamic> newOrder({
    required Symbol symbol,
    required String side,
    required String type,
    Decimal? quantity,
    Decimal? price,
    String? timeInForce,
  }) {
    final params = {
      'symbol': symbol.value,
      'side': side,
      'type': type,
    };
    if (quantity != null) params['quantity'] = quantity.toString();
    if (price != null) params['price'] = price.toString();
    if (timeInForce != null) params['timeInForce'] = timeInForce;

    return sendRequest('order.place', params: params);
  }

  /// Close the connection.
  Future<void> disconnect() => _apiClient.close();
}
