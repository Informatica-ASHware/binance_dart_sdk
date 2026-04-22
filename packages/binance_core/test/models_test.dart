import 'package:binance_core/binance_core.dart';
import 'package:test/test.dart';

void main() {
  group('Symbol', () {
    test('stores value and supports equality', () {
      const s1 = Symbol('BTCUSDT');
      const s2 = Symbol('BTCUSDT');
      const s3 = Symbol('ETHUSDT');

      expect(s1.value, 'BTCUSDT');
      expect(s1, equals(s2));
      expect(s1, isNot(equals(s3)));
      expect(s1.toString(), 'BTCUSDT');
      expect(s1.hashCode, equals('BTCUSDT'.hashCode));
    });
  });

  group('Price', () {
    test('parsing and equality', () {
      final p1 = Price.fromString('42000.50');
      final p2 = Price.fromString('42000.50');
      final p3 = Price.fromString('42000.51');

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.toString(), '42000.50');
      expect(p1.hashCode, isA<int>());
    });
  });

  group('Quantity', () {
    test('parsing and equality', () {
      final q1 = Quantity.fromString('1.234567');
      final q2 = Quantity.fromString('1.234567');
      final q3 = Quantity.fromString('1.234568');

      expect(q1, equals(q2));
      expect(q1, isNot(equals(q3)));
      expect(q1.toString(), '1.234567');
      expect(q1.hashCode, isA<int>());
    });
  });

  group('Decimal (Internal)', () {
    test('handles integers', () {
      final d = Decimal.parse('100');
      expect(d.toString(), '100');
    });

    test('handles leading zeros', () {
      final d = Decimal.parse('0.00123');
      expect(d.toString(), '0.00123');
    });

    test('handles negative numbers', () {
      expect(Decimal.parse('-0.05').toString(), '-0.05');
      expect(Decimal.parse('-1.05').toString(), '-1.05');
      expect(Decimal.parse('-100').toString(), '-100');
    });

    test('throws on invalid input', () {
      expect(() => Decimal.parse('1.2.3'), throwsFormatException);
      expect(() => Decimal.parse('abc'), throwsFormatException);
    });

    test('hashCode works', () {
      final d = Decimal.parse('10.5');
      expect(d.hashCode, isA<int>());
    });
  });
}
