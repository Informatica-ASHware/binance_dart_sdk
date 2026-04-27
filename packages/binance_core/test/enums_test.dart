import 'package:ash_binance_api_core/binance_core.dart';
import 'package:test/test.dart';

void main() {
  group('Interval', () {
    test('values are correct', () {
      expect(Interval.s1.value, '1s');
      expect(Interval.m1.value, '1m');
      expect(Interval.h1.value, '1h');
      expect(Interval.d1.value, '1d');
      expect(Interval.mo1.value, '1M');
    });

    test('toString returns value', () {
      expect(Interval.m15.toString(), '15m');
    });
  });

  group('BinanceEnvironment', () {
    test('mainnet urls', () {
      expect(BinanceEnvironment.mainnet.spotBaseUrl, 'https://api.binance.com');
      expect(
        BinanceEnvironment.mainnet.futuresBaseUrl,
        'https://fapi.binance.com',
      );
    });

    test('spotTestnet urls', () {
      expect(
        BinanceEnvironment.spotTestnet.spotBaseUrl,
        'https://testnet.binance.vision',
      );
      expect(BinanceEnvironment.spotTestnet.futuresBaseUrl, isEmpty);
    });

    test('futuresTestnet urls', () {
      expect(BinanceEnvironment.futuresTestnet.spotBaseUrl, isEmpty);
      expect(
        BinanceEnvironment.futuresTestnet.futuresBaseUrl,
        'https://testnet.binancefuture.com',
      );
    });
  });
}
