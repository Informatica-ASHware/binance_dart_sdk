import 'package:binance_core/binance_core.dart';

void main() {
  const symbol = Symbol('BTCUSDT');
  final price = Price.fromString('50000.00');

  /// Printing is allowed in examples.
  // ignore: avoid_print
  print('Symbol: $symbol');

  /// Printing is allowed in examples.
  // ignore: avoid_print
  print('Price: $price');

  const Result<Symbol, String>.success(symbol).fold(
    onSuccess: (s) {
      /// Printing is allowed in examples.
      // ignore: avoid_print
      print('Success: $s');
    },
    onFailure: (e) {
      /// Printing is allowed in examples.
      // ignore: avoid_print
      print('Error: $e');
    },
  );
}
