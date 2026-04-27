import 'dart:io';
import 'package:ash_binance_api_core/binance_core.dart';

void main(List<String> args) async {
  final symbols = args.isNotEmpty
      ? args
      : ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT', 'ADAUSDT'];

  print('Watching book tickers for: ${symbols.join(', ')}');
  print('Press Ctrl+C to exit\n');

  final provider = DefaultBinanceWebSocketProvider();
  final client = WebSocketStreamClient(
    baseUrl: Uri.parse(BinanceEnvironment.mainnet.spotStreamBaseUrl),
    provider: provider,
  );

  // Simple manual combined stream for the example
  final streams = symbols.map((s) => '${s.toLowerCase()}@bookTicker').join('/');
  final stream = client.subscribe('stream?streams=$streams');

  final subscription = stream.listen(
    (event) {
      final data =
          (event as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final symbol = (data['s'] as String).padRight(8);
      final bid = (data['b'] as String).padLeft(12);
      final ask = (data['a'] as String).padLeft(12);

      // ANSI color codes: \x1B[32m (Green), \x1B[31m (Red), \x1B[0m (Reset)
      print('$symbol | \x1B[32mBid: $bid\x1B[0m | \x1B[31mAsk: $ask\x1B[0m');
    },
    onError: (e) => print('Stream Error: $e'),
    onDone: () => print('Stream Closed'),
  );

  ProcessSignal.sigint.watch().listen((signal) async {
    print('\nShutting down...');
    await subscription.cancel();
    await client.close();
    print('Goodbye!');
    exit(0);
  });
}
