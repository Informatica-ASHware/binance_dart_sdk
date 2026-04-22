import 'dart:convert';
import 'package:binance_core/src/observability.dart';
import 'package:binance_core/src/time.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('ServerTimeSynchronizer', () {
    test('synchronizes time correctly', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final serverTime = now + 5000;

      final client = MockClient((request) async {
        if (request.url.path == '/api/v3/time') {
          return http.Response(json.encode({'serverTime': serverTime}), 200);
        }
        return http.Response('Not Found', 404);
      });

      final synchronizer = ServerTimeSynchronizer(
        baseUrl: 'https://api.binance.com',
        httpClient: client,
      );

      await synchronizer.syncInternal();

      expect(synchronizer.offset, closeTo(5000, 500));
      expect(synchronizer.adjustedNow().milliseconds, greaterThan(now));
    });

    test('emits warning if offset is too large', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final serverTime = now + 10000;

      int? warningOffset;
      final hooks = BinanceObservabilityHooks(
        onTimeSyncWarning: (offset, jitter) {
          warningOffset = offset;
        },
      );

      final client = MockClient((request) async {
        return http.Response(json.encode({'serverTime': serverTime}), 200);
      });

      final synchronizer = ServerTimeSynchronizer(
        baseUrl: 'https://api.binance.com',
        httpClient: client,
        observability: hooks,
      );

      await synchronizer.syncInternal();

      expect(warningOffset, isNotNull);
      expect(warningOffset!.abs(), greaterThan(2500));
    });
  });
}
