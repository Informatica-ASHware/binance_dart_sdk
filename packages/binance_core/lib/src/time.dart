import 'dart:async';
import 'dart:convert';

import 'package:binance_core/src/models.dart';
import 'package:binance_core/src/observability.dart';
import 'package:http/http.dart' as http;

/// Synchronizes local time with Binance server time.
final class ServerTimeSynchronizer {
  /// Creates a [ServerTimeSynchronizer].
  ServerTimeSynchronizer({
    required this.baseUrl,
    this.observability = const BinanceObservabilityHooks(),
    this.syncInterval = const Duration(minutes: 30),
    this.alpha = 0.1, // Smoothing factor for EWMA
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  /// The base URL of the Binance API (e.g., https://api.binance.com).
  final String baseUrl;

  /// Observability hooks for logging and warnings.
  final BinanceObservabilityHooks observability;

  /// How often to synchronize time.
  final Duration syncInterval;

  /// EWMA smoothing factor.
  final double alpha;

  int _offset = 0;
  double _jitter = 0;
  Timer? _timer;

  /// The current estimated server time.
  Timestamp adjustedNow() {
    return Timestamp(DateTime.now().millisecondsSinceEpoch + _offset);
  }

  /// Starts the periodic synchronization.
  void start() {
    _timer?.cancel();
    _sync();
    _timer = Timer.periodic(syncInterval, (_) => _sync());
  }

  /// Stops the periodic synchronization.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _sync() async {
    await syncInternal();
  }

  /// Internal sync logic exposed for testing.
  Future<void> syncInternal() async {
    try {
      final start = DateTime.now().millisecondsSinceEpoch;
      final response = await _httpClient.get(Uri.parse('$baseUrl/api/v3/time'));
      final end = DateTime.now().millisecondsSinceEpoch;

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final serverTime = data['serverTime'] as int;

        final latency = (end - start) ~/ 2;
        final currentJitter = (end - start).toDouble();

        final newOffset = serverTime - (end - latency);

        _jitter = (alpha * currentJitter) + ((1 - alpha) * _jitter);
        _offset = newOffset;

        _checkOffset();
      } else {
        observability.logger.warning(
          'Failed to sync time: ${response.statusCode} ${response.body}',
        );
      }
    } on Exception catch (e, stackTrace) {
      observability.logger.error(
        'Error syncing time',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _checkOffset() {
    const threshold = 2500;
    if (_offset.abs() > threshold) {
      observability.logger.warning(
        'Significant time offset detected: ${_offset}ms. '
        'This may cause INVALID_SIGNATURE (-1022) errors.',
      );
      observability.onTimeSyncWarning?.call(_offset, _jitter);
    }
  }

  /// The current detected time offset in milliseconds.
  int get offset => _offset;

  /// The current estimated network jitter.
  double get jitter => _jitter;
}
