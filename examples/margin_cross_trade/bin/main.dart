import 'dart:async';
import 'dart:io';
import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_margin/ash_binance_api_margin.dart';
import 'package:ash_binance_api_spot/ash_binance_api_spot.dart';

void main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run bin/main.dart <API_KEY> <PRIVATE_KEY_PEM_FILE>');
    return;
  }

  final apiKey = args[0];
  final pemPath = args[1];
  final privateKeyPem = await File(pemPath).readAsBytes();

  final credentials = Ed25519Credentials(
    apiKey: apiKey,
    privateKey: SecureByteBuffer(privateKeyPem),
  );

  final httpClient = DefaultBinanceHttpClient(
    environment: BinanceEnvironment.mainnet,
    credentials: credentials,
    signer: Ed25519RequestSigner(credentials),
  );

  final apiClient = WebSocketApiClient(
    baseUrl: Uri.parse(BinanceEnvironment.mainnet.spotWsApiBaseUrl),
    provider: const DefaultBinanceWebSocketProvider(),
  );

  final marginClient = BinanceMarginClient(httpClient);

  print('--- Margin Workflow Example ---');

  // 1. Query Margin Account
  print('Step 1: Querying Margin Account...');
  final accountResult = await marginClient.getAccount();

  accountResult.when(
    success: (account) {
      print('Account Level: ${account.marginLevel}');
      print('Total Net Asset: ${account.totalNetAssetOfBtc} BTC');
    },
    failure: (error) {
      print('Failed to get account details: $error');
      exit(1);
    },
  );

  // 2. Open User Data Stream
  print('\nStep 2: Opening User Data Stream...');
  final feed = UserDataFeed.create(
    venue: BinanceVenue.margin,
    httpClient: httpClient,
    apiClient: apiClient,
    streamClient: WebSocketStreamClient(
      baseUrl: Uri.parse(BinanceEnvironment.mainnet.spotStreamBaseUrl),
      provider: const DefaultBinanceWebSocketProvider(),
    ),
    credentials: credentials,
  );

  await feed.start();
  print('Connected to User Data Stream.');

  final fillCompleter = Completer<OrderId>();

  // 3. Monitor via stream
  final subscription = feed.events.listen((event) {
    if (event is OrderTradeUpdate) {
      print('Order Update: ${event.symbol} ${event.status} '
          'Filled: ${event.cumulativeFilledQuantity}/${event.quantity}');
      if (event.status == 'FILLED') {
        fillCompleter.complete(event.orderId);
      }
    }
  });

  // 4. Place a Limit Buy Order with Margin Buy sideEffect
  print('\nStep 4: Placing Margin BUY order...');
  final symbol = Symbol('BTCUSDT');

  // We'll use a very low price to ensure it doesn't fill immediately or at all
  // unless the user really wants to test it. For safety, we use a low price.
  final orderResult = await marginClient.newOrder(
    symbol: symbol,
    side: Side.buy,
    type: OrderType.limit,
    quantity: Quantity.fromString('0.001'),
    price: Price.fromString('10000'),
    timeInForce: TimeInForce.gtc,
    sideEffectType: MarginSideEffect.marginBuy,
  );

  final orderResponse = orderResult.when(
    success: (resp) {
      print('Order placed: ${resp.orderId}');
      return resp;
    },
    failure: (error) {
      print('Failed to place order: $error');
      return null;
    },
  );

  if (orderResponse != null) {
    print('Waiting for fill (Timeout 30s for demo)...');
    try {
      final filledId =
          await fillCompleter.future.timeout(Duration(seconds: 30));
      print('Order $filledId FILLED!');

      // 5. Repay automatic (Sell with AUTO_REPAY)
      print('\nStep 5: Closing position with AUTO_REPAY...');
      final sellResult = await marginClient.newOrder(
        symbol: symbol,
        side: Side.sell,
        type: OrderType.market,
        quantity: Quantity.fromString('0.001'),
        sideEffectType: MarginSideEffect.autoRepay,
      );

      sellResult.when(
        success: (resp) => print('Sell order placed: ${resp.orderId}'),
        failure: (error) => print('Failed to place sell order: $error'),
      );
    } on TimeoutException {
      print('Timed out waiting for fill. Cancelling order...');
      await marginClient.cancelOrder(symbol, orderId: orderResponse.orderId);
    }
  }

  // Cleanup
  print('\nCleaning up...');
  await subscription.cancel();
  await feed.stop();
  await apiClient.close();
  print('Done.');
}
