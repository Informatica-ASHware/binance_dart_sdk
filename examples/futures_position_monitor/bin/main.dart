import 'dart:async';
import 'dart:io';
import 'package:ash_binance_api_core/binance_core.dart';

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
    provider: const DefaultBinanceWebSocketProvider(),
  );

  final feed = UserDataFeed.create(
    venue: BinanceVenue.usdMFutures,
    httpClient: httpClient,
    apiClient: WebSocketApiClient(
      baseUrl: Uri.parse(BinanceEnvironment.mainnet.spotWsApiBaseUrl),
      provider: const DefaultBinanceWebSocketProvider(),
    ),
    streamClient: streamClient,
    credentials: credentials,
  );

  print('Connecting to Futures User Data Stream...');
  await feed.start();

  Map<Symbol, AccountPosition> positions = {};
  Map<Symbol, Decimal> markPrices = {};

  // Subscribe to position updates
  feed.events.listen((event) {
    if (event is AccountUpdate) {
      for (final pos in event.positions) {
        positions[pos.symbol] = pos;
      }
    }
  });

  // Simple manual mark price subscription for top symbols
  final topSymbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];
  for (final s in topSymbols) {
    final symbol = Symbol(s);
    streamClient.subscribe('${s.toLowerCase()}@markPrice').listen((event) {
      final data = event as Map<String, dynamic>;
      markPrices[symbol] = Decimal.parse(data['p'] as String);
    });
  }

  // Periodically print status
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (positions.isEmpty) {
      print('Waiting for position updates...');
      return;
    }

    print('\x1B[2J\x1B[H'); // Clear console
    print('--- Futures Position Monitor ---');
    print(
        '${'Symbol'.padRight(12)} | ${'PnL'.padLeft(10)} | ${'Mark Price'.padLeft(12)} | ${'Margin %'.padLeft(10)}');
    print('-' * 55);

    for (final pos in positions.values) {
      if (pos.amount == Decimal.zero) continue;

      final symbol = pos.symbol.value.padRight(12);
      final pnl = pos.unrealizedProfit.toString().padLeft(10);
      final markPrice =
          (markPrices[pos.symbol] ?? pos.entryPrice).toString().padLeft(12);

      // Calculate Margin Ratio (Simulated if not in event)
      // Usually: Maintenance Margin / Margin Balance
      // Here we simulate for the demonstration
      final marginRatio = 0.05; // 5%

      String color = '';
      if (marginRatio > 0.8) {
        color = '\x1B[31m'; // Red
        stderr.writeln('ALERT: High margin ratio for ${pos.symbol}!');
      }

      print(
          '$color$symbol | $pnl | $markPrice | ${(marginRatio * 100).toStringAsFixed(2)}%\x1B[0m');
    }
  });

  ProcessSignal.sigint.watch().listen((signal) async {
    print('\nStopping...');
    await feed.stop();
    await streamClient.close();
    exit(0);
  });
}
