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
      expect(s1.hashCode, equals(s2.hashCode));
      expect(s1.toString(), 'BTCUSDT');
    });
  });

  group('Asset', () {
    test('stores value and supports equality', () {
      const a1 = Asset('BTC');
      const a2 = Asset('BTC');
      const a3 = Asset('USDT');

      expect(a1.value, 'BTC');
      expect(a1, equals(a2));
      expect(a1, isNot(equals(a3)));
      expect(a1.hashCode, a2.hashCode);
      expect(a1.toString(), 'BTC');
    });
  });

  group('Price', () {
    test('parsing and equality', () {
      final p1 = Price.fromString('50000.50');
      final p2 = Price.fromString('50000.5');
      final p3 = Price.fromString('50000.51');

      expect(p1, equals(p2));
      expect(p1, isNot(equals(p3)));
      expect(p1.hashCode, p2.hashCode);
      expect(p1.toString(), '50000.5');
    });
  });

  group('Quantity', () {
    test('parsing and equality', () {
      final q1 = Quantity.fromString('1.250');
      final q2 = Quantity.fromString('1.25');
      final q3 = Quantity.fromString('1.26');

      expect(q1, equals(q2));
      expect(q1, isNot(equals(q3)));
      expect(q1.hashCode, q2.hashCode);
      expect(q1.toString(), '1.25');
    });
  });

  group('Percentage', () {
    test('parsing and equality', () {
      final p1 = Percentage.fromString('0.05');
      final p2 = Percentage.fromString('0.05');
      expect(p1, p2);
      expect(p1.hashCode, p2.hashCode);
      expect(p1.toString(), '0.05%');
    });
  });

  group('Money', () {
    const btc = Asset('BTC');
    const usdt = Asset('USDT');

    test('equality and toString', () {
      final m1 = Money(Decimal.parse('1.5'), btc);
      final m2 = Money(Decimal.parse('1.5'), btc);
      final m3 = Money(Decimal.parse('1.5'), usdt);

      expect(m1, m2);
      expect(m1, isNot(m3));
      expect(m1.hashCode, m2.hashCode);
      expect(m1.toString(), '1.5 BTC');
    });

    test('addition and subtraction', () {
      final m1 = Money(Decimal.parse('1.5'), btc);
      final m2 = Money(Decimal.parse('2.5'), btc);

      expect((m1 + m2).amount, Decimal.parse('4.0'));
      expect((m2 - m1).amount, Decimal.parse('1'));
    });

    test('throws on asset mismatch', () {
      final m1 = Money(Decimal.parse('1.5'), btc);
      final m2 = Money(Decimal.parse('2.5'), usdt);

      expect(() => m1 + m2, throwsArgumentError);
      expect(() => m1 - m2, throwsArgumentError);
    });
    group('Decimal (Internal)', () {
      test('handles integers', () {
        final d = Decimal.parse('100');
        expect(d.units, BigInt.from(100));
        expect(d.precision, 0);
        expect(d.toString(), '100');
      });

      test('handles leading zeros', () {
        final d = Decimal.parse('0.001');
        expect(d.units, BigInt.from(1));
        expect(d.precision, 3);
        expect(d.toString(), '0.001');
      });

      test('handles negative numbers', () {
        final d = Decimal.parse('-1.5');
        expect(d.units, BigInt.from(-15));
        expect(d.precision, 1);
        expect(d.toString(), '-1.5');
      });

      test('arithmetic operations', () {
        final d1 = Decimal.parse('1.5');
        final d2 = Decimal.parse('2.25');

        expect(d1 + d2, Decimal.parse('3.75'));
        expect(d2 - d1, Decimal.parse('0.75'));
        expect(d1 * d2, Decimal.parse('3.375'));
      });

      test('comparison operators', () {
        final d1 = Decimal.parse('1.5');
        final d2 = Decimal.parse('2.25');
        final d3 = Decimal.parse('1.50');

        expect(d1 < d2, isTrue);
        expect(d1 <= d2, isTrue);
        expect(d1 <= d3, isTrue);
        expect(d2 > d1, isTrue);
        expect(d2 >= d1, isTrue);
        expect(d1 >= d3, isTrue);
        expect(d1 == d3, isTrue);
      });

      test('throws on invalid input', () {
        expect(() => Decimal.parse('1.2.3'), throwsFormatException);
        expect(() => Decimal.parse('abc'), throwsFormatException);
      });

      test('hashCode works', () {
        final d1 = Decimal.parse('1.5');
        final d2 = Decimal.parse('1.50');
        expect(d1 == d2, isTrue);
        expect(d1.hashCode, d2.hashCode);
      });
    });

    group('OrderId, ClientOrderId, Timestamp', () {
      test('OrderId works', () {
        const id1 = OrderId(12345);
        const id2 = OrderId(12345);
        const id3 = OrderId(12346);
        expect(id1, id2);
        expect(id1, isNot(id3));
        expect(id1.hashCode, id2.hashCode);
        expect(id1.toString(), '12345');
      });

      test('ClientOrderId works', () {
        const cid1 = ClientOrderId('my_order_1');
        const cid2 = ClientOrderId('my_order_1');
        const cid3 = ClientOrderId('my_order_2');
        expect(cid1, cid2);
        expect(cid1, isNot(cid3));
        expect(cid1.hashCode, cid2.hashCode);
        expect(cid1.toString(), 'my_order_1');
      });

      test('Timestamp works', () {
        final now = DateTime.now().millisecondsSinceEpoch;
        final ts1 = Timestamp(now);
        final ts2 = Timestamp(now);
        final ts3 = Timestamp(now + 1);
        expect(ts1, ts2);
        expect(ts1, isNot(ts3));
        expect(ts1.hashCode, ts2.hashCode);
        expect(ts1.milliseconds, now);
        expect(ts1.toDateTime().millisecondsSinceEpoch, now);
        expect(Timestamp.now().milliseconds, greaterThanOrEqualTo(now));
        expect(ts1.toString(), now.toString());
      });
    });
  });
}
