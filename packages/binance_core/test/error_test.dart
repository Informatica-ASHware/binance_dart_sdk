import 'package:binance_core/binance_core.dart';
import 'package:test/test.dart';

void main() {
  group('BinanceError', () {
    test('BinanceApiError', () {
      const error = BinanceApiError(code: -1001, message: 'Invalid format');
      expect(error.code, -1001);
      expect(error.message, 'Invalid format');
      expect(error.toString(), contains('-1001'));
    });

    test('BinanceNetworkError', () {
      final error = BinanceNetworkError(
        message: 'Timeout',
        cause: 'SocketException',
      );
      expect(error.message, 'Timeout');
      expect(error.cause, 'SocketException');
      expect(error.toString(), contains('Timeout'));
    });

    test('BinanceParseError', () {
      const error = BinanceParseError('Bad JSON');
      expect(error.message, 'Bad JSON');
    });

    test('BinanceAuthError', () {
      const error = BinanceAuthError('Invalid API Key');
      expect(error.message, 'Invalid API Key');
    });
  });

  group('Result with BinanceError', () {
    test('Success stores value', () {
      const result = Result<int, BinanceError>.success(42);
      expect(result.isSuccess, isTrue);
      expect(
        result.fold(
          onSuccess: (v) => v,
          onFailure: (e) => 0,
        ),
        42,
      );
    });

    test('Failure stores BinanceError', () {
      const error = BinanceApiError(code: 1, message: 'err');
      const result = Result<int, BinanceError>.failure(error);
      expect(result.isFailure, isTrue);
      expect(
        result.fold(
          onSuccess: (v) => null,
          onFailure: (e) => e,
        ),
        error,
      );
    });
  });
}
