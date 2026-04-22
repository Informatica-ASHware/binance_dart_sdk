import 'package:binance_core/binance_core.dart';

void main() {
  const symbol = Symbol('BTCUSDT');
  final price = Price.fromString('50000.00');

  // ignore: avoid_print
  print('Symbol: $symbol');
  // ignore: avoid_print
  print('Price: $price');

  const result = Result<Symbol, String>.success(symbol);

  result.fold(
    onSuccess: (s) {
      // ignore: avoid_print
      print('Success: $s');
    },
    onFailure: (e) {
      // ignore: avoid_print
      print('Error: $e');
    },
  );
}
