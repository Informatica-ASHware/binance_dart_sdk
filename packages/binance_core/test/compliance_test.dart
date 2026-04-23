import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:binance_core/src/auth.dart';
import 'package:binance_core/src/security.dart';
import 'package:binance_core/src/utils.dart';
import 'package:test/test.dart';

void main() {
  /// Resolves the absolute path to a fixture file.
  File findVectors() {
    var dir = Directory.current;
    while (true) {
      final fallback = File('${dir.path}/test/fixtures/signatures/vectors.json');
      if (fallback.existsSync()) return fallback;
      if (dir.path == dir.parent.path) break;
      dir = dir.parent;
    }
    throw Exception('Could not find vectors.json');
  }

  late Map<String, dynamic> vectors;

  setUpAll(() async {
    final vectorsFile = findVectors();
    vectors = jsonDecode(await vectorsFile.readAsString()) as Map<String, dynamic>;
  });

  group('Signature Compliance', () {
    test('HMAC-SHA256 official test vector', () async {
      final data = vectors['hmac'] as Map<String, dynamic>;
      final secret = SecureByteBuffer(utf8.encode(data['secret'] as String));
      final credentials = HmacCredentials(
        apiKey: data['apiKey'] as String,
        apiSecret: secret,
      );
      final signer = HmacRequestSigner(credentials);

      final signature = await signer.sign(data['payload'] as String);
      expect(signature.value, data['signature']);
    });

    test('Non-ASCII symbol percent-encoding (RFC 3986)', () {
      final data = vectors['non_ascii'] as Map<String, dynamic>;
      final params = {
        'symbol': '１２３４５６',
        'timestamp': 1499827319559,
      };

      final canonical = BinanceUtils.buildCanonicalPayload(params);
      expect(canonical, data['canonical']);
    });

    test('HMAC-SHA256 with non-ASCII symbols', () async {
      final data = vectors['non_ascii'] as Map<String, dynamic>;
      final secret = SecureByteBuffer(utf8.encode(data['secret'] as String));
      final credentials = HmacCredentials(
        apiKey: 'test-api-key',
        apiSecret: secret,
      );
      final signer = HmacRequestSigner(credentials);

      final signature = await signer.sign(data['canonical'] as String);
      expect(signature.value, data['signature']);
    });

    test('Ed25519 request signer', () async {
      final data = vectors['ed25519'] as Map<String, dynamic>;
      // 32-byte seed of all zeroes
      final seed = Uint8List(32);
      final credentials = Ed25519Credentials(
        apiKey: 'test-api-key',
        privateKey: SecureByteBuffer(seed),
      );
      final signer = Ed25519RequestSigner(credentials);

      final signature = await signer.sign(data['payload'] as String);
      expect(signature.value, isNotEmpty);
    });
  });
}
