import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_futures/ash_binance_api_futures.dart';

void main() async {
  // 1. Initialize the HTTP client
  final httpClient = BinanceHttpClient();

  // 2. Initialize the Futures Market Data client
  final marketClient = BinanceFuturesMarketDataRest(httpClient);

  // 3. Ping the server
  print('Pinging Binance Futures server...');
  final result = await marketClient.ping();

  result.match(
    (_) => print('Ping successful! Server is reachable.'),
    (error) => print('Error: ${error.message}'),
  );

  // 4. Get current server time
  final timeResult = await marketClient.time();
  timeResult.match(
    (serverTime) => print('Server Time: $serverTime'),
    (error) => print('Error: ${error.message}'),
  );

  // 5. Close the client
  httpClient.close();
}
