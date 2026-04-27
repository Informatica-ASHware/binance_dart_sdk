import 'dart:typed_data';

/// A buffer that holds sensitive data and can be zeroed out when no longer
/// needed.
final class SecureByteBuffer {
  /// Creates a [SecureByteBuffer] from the given [bytes].
  SecureByteBuffer(Uint8List bytes) : _bytes = Uint8List.fromList(bytes);

  Uint8List? _bytes;

  /// Returns the bytes stored in this buffer.
  ///
  /// Throws a [StateError] if the buffer has been disposed.
  Uint8List get bytes {
    final b = _bytes;
    if (b == null) {
      throw StateError('SecureByteBuffer has been disposed');
    }
    return b;
  }

  /// Zeroes out the memory and releases the buffer.
  void dispose() {
    final b = _bytes;
    if (b != null) {
      for (var i = 0; i < b.length; i++) {
        b[i] = 0;
      }
      _bytes = null;
    }
  }

  /// Whether the buffer has been disposed.
  bool get isDisposed => _bytes == null;
}
