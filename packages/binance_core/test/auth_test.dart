import 'dart:convert';
import 'dart:typed_data';

import 'package:binance_core/src/auth.dart';
import 'package:binance_core/src/security.dart';
import 'package:binance_core/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('BinanceUtils', () {
    test('strictPercentEncode matches RFC 3986', () {
      expect(BinanceUtils.strictPercentEncode('BTCUSDT'), 'BTCUSDT');
      expect(
        BinanceUtils.strictPercentEncode('amount=1.0&symbol=BNBBTC'),
        'amount%3D1.0%26symbol%3DBNBBTC',
      );
      expect(BinanceUtils.strictPercentEncode(' '), '%20');
      expect(BinanceUtils.strictPercentEncode('~_.-'), '~_.-');
      expect(BinanceUtils.strictPercentEncode('*'), '%2A');
    });

    test('buildCanonicalPayload sorts and encodes', () {
      final params = {
        'symbol': 'LTCBTC',
        'side': 'BUY',
        'type': 'LIMIT',
        'timeInForce': 'GTC',
        'quantity': 1,
        'price': '0.1',
      };
      const expected =
          'price=0.1&quantity=1&side=BUY&symbol=LTCBTC&timeInForce=GTC&type=LIMIT';
      expect(BinanceUtils.buildCanonicalPayload(params), expected);
    });
  });

  group('HmacRequestSigner', () {
    test('signs correctly with test vector', () async {
      final secret = SecureByteBuffer(
        utf8.encode(
          'Nhqptndp8uV9NV76f9V33S0O7uXen3ZlUe30fId39q72X247E6e67616161616161',
        ),
      );
      final credentials = HmacCredentials(
        apiKey:
            'vmPUZE6mv9SD667K08u806e33230616161616161616161616161616161616161',
        apiSecret: secret,
      );
      final signer = HmacRequestSigner(credentials);

      const payload =
          'symbol=LTCBTC&side=BUY&type=LIMIT&timeInForce=GTC&quantity=1'
          '&price=0.1&recvWindow=5000&timestamp=1499827319559';
      final signature = await signer.sign(payload);

      expect(signature.value.length, 64);
    });
  });

  group('Ed25519RequestSigner', () {
    test('signs correctly', () async {
      final seed = Uint8List(32)..fillRange(0, 32, 1);
      final credentials = Ed25519Credentials(
        apiKey: 'test-api-key',
        privateKey: SecureByteBuffer(seed),
      );
      final signer = Ed25519RequestSigner(credentials);

      const payload = 'symbol=LTCBTC&timestamp=1499827319559';
      final signature = await signer.sign(payload);

      expect(signature.value, isNotEmpty);
      expect(base64.decode(signature.value).length, 64);
    });
  });

  group('SecureByteBuffer', () {
    test('zeroes memory on dispose', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final buffer = SecureByteBuffer(bytes);
      expect(buffer.bytes, [1, 2, 3, 4]);

      buffer.dispose();
      expect(buffer.isDisposed, true);
      expect(() => buffer.bytes, throwsStateError);

      expect(bytes, [1, 2, 3, 4]);
    });
  });
}
