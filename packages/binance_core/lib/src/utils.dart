/// Utility class for Binance-specific encoding and payload building.
abstract final class BinanceUtils {
  /// Strictly percent-encodes a string according to RFC 3986.
  ///
  /// This is required for Binance signatures after 2026-01-15.
  /// It encodes all characters except unreserved characters:
  /// ALPHA / DIGIT / "-" / "." / "_" / "~"
  static String strictPercentEncode(String input) {
    final buffer = StringBuffer();
    for (final codeUnit in input.codeUnits) {
      if (_isUnreserved(codeUnit)) {
        buffer.writeCharCode(codeUnit);
      } else {
        buffer.write(
          '%${codeUnit.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        );
      }
    }
    return buffer.toString();
  }

  static bool _isUnreserved(int codeUnit) {
    // A-Z
    if (codeUnit >= 65 && codeUnit <= 90) return true;
    // a-z
    if (codeUnit >= 97 && codeUnit <= 122) return true;
    // 0-9
    if (codeUnit >= 48 && codeUnit <= 57) return true;
    // - . _ ~
    if (codeUnit == 45 || codeUnit == 46 || codeUnit == 95 || codeUnit == 126) {
      return true;
    }
    return false;
  }

  /// Builds a canonical payload from a map of parameters.
  ///
  /// Parameters are sorted by key and percent-encoded.
  static String buildCanonicalPayload(Map<String, dynamic> params) {
    final sortedKeys = params.keys.toList()..sort();
    return sortedKeys.map((key) {
      final value = params[key];
      final encodedKey = strictPercentEncode(key);
      final encodedValue = strictPercentEncode(value.toString());
      return '$encodedKey=$encodedValue';
    }).join('&');
  }
}
