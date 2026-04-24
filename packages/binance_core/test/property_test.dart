import 'package:binance_core/src/models.dart';
import 'package:binance_core/src/utils.dart';
import 'package:glados/glados.dart';

void main() {
  group('BinanceUtils Property Tests', () {
    Glados(any.map(any.lowercaseLetters, any.lowercaseLetters)).test(
      'buildCanonicalPayload roundtrip/consistency',
      (Map<String, String> params) {
        final payload = BinanceUtils.buildCanonicalPayload(params);

        if (params.isEmpty) {
          expect(payload, isEmpty);
        } else {
          expect(payload, contains('='));
          final pairs = payload.split('&');
          expect(pairs.length, params.length);

          final keys = pairs.map((p) => p.split('=')[0]).toList();
          final sortedKeys = List<String>.from(keys)..sort();
          expect(keys, sortedKeys);
        }
      },
    );

    Glados(any.lowercaseLetters).test(
      'strictPercentEncode is idempotent for unreserved',
      (input) {
        final encoded = BinanceUtils.strictPercentEncode(input);
        expect(encoded, input);
      },
    );
  });

  group('Decimal Property Tests', () {
    Glados(any.double).test(
      'Decimal.parse(toString()) roundtrip (approx)',
      (value) {
        if (value.isNaN || value.isInfinite) return;

        // Use a fixed precision to avoid scientific notation issues in toString
        final s = value.toStringAsFixed(8);
        final decimal = Decimal.parse(s);
        expect(
            decimal.toString(), Decimal.parse(decimal.toString()).toString());
      },
    );
  });
}
