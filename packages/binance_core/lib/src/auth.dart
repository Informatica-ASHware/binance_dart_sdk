import 'dart:convert';
import 'dart:typed_data';

import 'package:binance_core/src/security.dart';
import 'package:cryptography/cryptography.dart' as crypto;
import 'package:meta/meta.dart';
import 'package:pointycastle/asn1.dart' as pc_asn1;
import 'package:pointycastle/export.dart' as pc;

/// Represents a cryptographic signature.
@immutable
final class Signature {
  /// Creates a [Signature].
  const Signature(this.value);

  /// The signature as a hex-encoded string.
  final String value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Signature &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// Base class for Binance credentials.
@immutable
sealed class BinanceCredentials {
  /// Creates [BinanceCredentials].
  const BinanceCredentials({required this.apiKey});

  /// The API key.
  final String apiKey;
}

/// HMAC-SHA256 credentials (Legacy).
final class HmacCredentials extends BinanceCredentials {
  /// Creates [HmacCredentials].
  const HmacCredentials({
    required super.apiKey,
    required SecureByteBuffer apiSecret,
  }) : _apiSecret = apiSecret;

  final SecureByteBuffer _apiSecret;

  /// The API secret buffer.
  SecureByteBuffer get apiSecret => _apiSecret;
}

/// RSA credentials (Asymmetric).
final class RsaCredentials extends BinanceCredentials {
  /// Creates [RsaCredentials].
  const RsaCredentials({
    required super.apiKey,
    required SecureByteBuffer privateKey,
  }) : _privateKey = privateKey;

  final SecureByteBuffer _privateKey;

  /// The private key buffer (typically PKCS#8).
  SecureByteBuffer get privateKey => _privateKey;
}

/// Ed25519 credentials (Recommended).
final class Ed25519Credentials extends BinanceCredentials {
  /// Creates [Ed25519Credentials].
  const Ed25519Credentials({
    required super.apiKey,
    required SecureByteBuffer privateKey,
  }) : _privateKey = privateKey;

  final SecureByteBuffer _privateKey;

  /// The private key buffer (Raw seed or PKCS#8).
  SecureByteBuffer get privateKey => _privateKey;
}

/// Interface for signing Binance API requests.
abstract interface class RequestSigner {
  /// Signs the given [canonicalPayload] and returns a [Signature].
  Future<Signature> sign(String canonicalPayload);
}

/// Request signer for HMAC-SHA256.
final class HmacRequestSigner implements RequestSigner {
  /// Creates [HmacRequestSigner].
  HmacRequestSigner(this._credentials);

  final HmacCredentials _credentials;

  @override
  Future<Signature> sign(String canonicalPayload) async {
    final hmac = crypto.Hmac.sha256();
    final secretKey = crypto.SecretKey(_credentials.apiSecret.bytes);
    final mac = await hmac.calculateMac(
      utf8.encode(canonicalPayload),
      secretKey: secretKey,
    );
    return Signature(_toHex(mac.bytes));
  }

  String _toHex(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join()
        .toLowerCase();
  }
}

/// Request signer for RSA.
final class RsaRequestSigner implements RequestSigner {
  /// Creates [RsaRequestSigner].
  RsaRequestSigner(this._credentials);

  final RsaCredentials _credentials;

  @override
  Future<Signature> sign(String canonicalPayload) async {
    final privateKey = _parsePrivateKey(_credentials.privateKey.bytes);
    final signer = pc.RSASigner(pc.SHA256Digest(), '0609608648016503040201');
    signer.init(true, pc.PrivateKeyParameter<pc.RSAPrivateKey>(privateKey));

    final signature = signer.generateSignature(
      Uint8List.fromList(utf8.encode(canonicalPayload)),
    );

    return Signature(base64.encode(signature.bytes));
  }

  pc.RSAPrivateKey _parsePrivateKey(Uint8List bytes) {
    final asn1Parser = pc_asn1.ASN1Parser(bytes);
    final topLevelSeq = asn1Parser.nextObject() as pc_asn1.ASN1Sequence;

    final privateKeyOctetString =
        topLevelSeq.elements![2] as pc_asn1.ASN1OctetString;
    final rsaAsn1Parser = pc_asn1.ASN1Parser(privateKeyOctetString.valueBytes);
    final rsaSeq = rsaAsn1Parser.nextObject() as pc_asn1.ASN1Sequence;

    return pc.RSAPrivateKey(
      (rsaSeq.elements![1] as pc_asn1.ASN1Integer).integer!,
      (rsaSeq.elements![3] as pc_asn1.ASN1Integer).integer!,
      (rsaSeq.elements![4] as pc_asn1.ASN1Integer).integer!,
      (rsaSeq.elements![5] as pc_asn1.ASN1Integer).integer!,
    );
  }
}

/// Request signer for Ed25519.
final class Ed25519RequestSigner implements RequestSigner {
  /// Creates [Ed25519RequestSigner].
  Ed25519RequestSigner(this._credentials);

  final Ed25519Credentials _credentials;

  @override
  Future<Signature> sign(String canonicalPayload) async {
    final ed25519 = crypto.Ed25519();
    final keyPair = await ed25519.newKeyPairFromSeed(
      _credentials.privateKey.bytes,
    );

    final signature = await ed25519.sign(
      utf8.encode(canonicalPayload),
      keyPair: keyPair,
    );

    return Signature(base64.encode(signature.bytes));
  }
}
