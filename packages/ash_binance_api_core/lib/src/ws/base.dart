import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';

/// Strategy for handling reconnections with exponential backoff and jitter.
@immutable
final class ReconnectionStrategy {
  /// Creates a [ReconnectionStrategy].
  const ReconnectionStrategy({
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(minutes: 1),
    this.multiplier = 2.0,
    this.jitter = 0.2,
  });

  /// Initial delay before the first reconnection attempt.
  final Duration initialDelay;

  /// Maximum delay between reconnection attempts.
  final Duration maxDelay;

  /// Multiplier applied to the delay after each failed attempt.
  final double multiplier;

  /// Jitter factor to apply to the delay (0.0 to 1.0).
  final double jitter;

  /// Calculates the delay for the given [attempt] number (0-based).
  Duration getDelay(int attempt) {
    if (attempt < 0) return Duration.zero;

    final exponentialDelay =
        initialDelay.inMilliseconds * pow(multiplier, attempt);
    final maxDelayMs = maxDelay.inMilliseconds;
    final baseDelay = min(exponentialDelay, maxDelayMs.toDouble());

    final random = Random();
    final jitterFactor = random.nextDouble() * 2 - 1; // -1.0 to 1.0
    final jitterMs = baseDelay * jitter * jitterFactor;
    final finalDelay = (baseDelay + jitterMs).round();

    return Duration(milliseconds: max(0, finalDelay));
  }
}

/// Interface for a WebSocket channel.
abstract interface class BinanceWebSocketChannel {
  /// The stream of messages from the server.
  Stream<dynamic> get stream;

  /// The sink for sending messages to the server.
  Sink<dynamic> get sink;

  /// Closes the WebSocket connection.
  Future<void> close([int? closeCode, String? closeReason]);
}

/// Interface for a provider of WebSocket channels.
// ignore: one_member_abstracts
abstract interface class BinanceWebSocketProvider {
  /// Connects to the given [url].
  Future<BinanceWebSocketChannel> connect(Uri url);
}

/// Warning emitted when the consumer is not draining the stream fast enough.
@immutable
final class StreamLagWarning {
  /// Creates a [StreamLagWarning].
  const StreamLagWarning({
    required this.streamName,
    required this.bufferSize,
    required this.maxBufferSize,
  });

  /// The name of the stream that is lagging.
  final String streamName;

  /// Current number of buffered messages.
  final int bufferSize;

  /// Maximum allowed buffer size.
  final int maxBufferSize;

  @override
  String toString() =>
      'StreamLagWarning(stream: $streamName, buffer: $bufferSize/$maxBufferSize)';
}
