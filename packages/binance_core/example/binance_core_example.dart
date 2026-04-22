import 'package:binance_core/binance_core.dart';

void main() {
  const symbol = Symbol('BTCUSDT');
  final price = Price.fromString('50000.00');

  print('Symbol: $symbol');
  print('Price: $price');

  const result = Result<Symbol, String>.success(symbol);

  result.fold(
    onSuccess: (s) => print('Success: $s'),
    onFailure: (e) => print('Error: $e'),
  );
}
