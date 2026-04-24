import 'dart:async';
import 'dart:io';
import 'package:binance_core/binance_core.dart';
import 'package:binance_futures/binance_futures.dart';

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

  final streamClient = WebSocketStreamClient(
    baseUrl: Uri.parse(BinanceEnvironment.mainnet.futuresStreamBaseUrl),
    provider: DefaultBinanceWebSocketProvider(),
  );

  final feed = UserDataFeed.create(
    venue: BinanceVenue.usdMFutures,
    httpClient: httpClient,
    apiClient: WebSocketApiClient(
      baseUrl: Uri.parse(BinanceEnvironment.mainnet.spotApiBaseUrl), // Unused by Futures feed
      provider: DefaultBinanceWebSocketProvider(),
    ),
    streamClient: streamClient,
    credentials: credentials,
  );

  print('Connecting to Futures User Data Stream...');
  await feed.start();

  Map<Symbol, AccountPosition> positions = {};

  // Subscribe to position updates
  feed.events.listen((event) {
    if (event is AccountUpdate) {
      for (final pos in event.positions) {
        positions[pos.symbol] = pos;
      }
    }
  });

  // Periodically print status
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (positions.isEmpty) {
      print('Waiting for position updates...');
      return;
    }

    print('\x1B[2J\x1B[H'); // Clear console
    print('--- Futures Position Monitor ---');
    print('${'Symbol'.padRight(12)} | ${'PnL'.padLeft(10)} | ${'Entry Price'.padLeft(12)} | ${'Amount'.padLeft(10)}');
    print('-' * 55);

    for (final pos in positions.values) {
      if (pos.amount == Decimal.zero) continue;

      final symbol = pos.symbol.value.padRight(12);
      final pnl = pos.unrealizedProfit.toString().padLeft(10);
      final entry = pos.entryPrice.toString().padLeft(12);
      final amount = pos.amount.toString().padLeft(10);

      print('$symbol | $pnl | $entry | $amount');
    }
  });

  ProcessSignal.sigint.watch().listen((signal) async {
    print('\nStopping...');
    await feed.stop();
    await streamClient.close();
    exit(0);
  });
}
