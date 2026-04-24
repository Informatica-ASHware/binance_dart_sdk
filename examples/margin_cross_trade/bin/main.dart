import 'dart:async';
import 'dart:io';
import 'package:binance_core/binance_core.dart';
import 'package:binance_margin/binance_margin.dart';

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
    baseUrl: Uri.parse(BinanceEnvironment.mainnet.spotApiBaseUrl),
    provider: DefaultBinanceWebSocketProvider(),
  );

  final marginClient = BinanceMarginClient(httpClient);

  print('--- Margin Workflow Example ---');

  // 1. Query Margin Account
  print('Step 1: Querying Margin Account...');
  final accountResult = await marginClient.getAccount();

  accountResult.when(
    success: (account) {
      print('Account Level: ${account.marginLevel}');
      print('Total Equity: ${account.totalEquityBTC} BTC');
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
      provider: DefaultBinanceWebSocketProvider(),
    ),
    credentials: credentials,
  );

  await feed.start();
  print('Connected to User Data Stream.');

  // 4. Monitor via stream
  print('\nStep 3: Monitoring for fills (waiting 10s)...');
  final subscription = feed.events.listen((event) {
    if (event is OrderTradeUpdate) {
      print('Received Order Update: ${event.symbol} ${event.status}');
    }
  });

  await Future<void>.delayed(Duration(seconds: 10));

  // 5. Cleanup
  print('\nCleaning up...');
  await subscription.cancel();
  await feed.stop();
  await apiClient.close();
  print('Done.');
}
