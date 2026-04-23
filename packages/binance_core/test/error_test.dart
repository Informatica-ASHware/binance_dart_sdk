import 'package:binance_core/binance_core.dart';
import 'package:test/test.dart';

void main() {
  group('BinanceError hierarchy', () {
    test('BinanceApiError.fromCode creates correct subclass', () {
      expect(
        BinanceApiError.fromCode(code: -1022, message: 'Invalid signature'),
        isA<BinanceSignatureError>(),
      );
      expect(
        BinanceApiError.fromCode(code: -1021, message: 'Timestamp error'),
        isA<BinanceTimestampError>(),
      );
      expect(
        BinanceApiError.fromCode(code: -1003, message: 'Rate limit'),
        isA<BinanceRateLimitError>(),
      );
      expect(
        BinanceApiError.fromCode(code: -1121, message: 'Invalid symbol'),
        isA<BinanceInvalidSymbol>(),
      );
      expect(
        BinanceApiError.fromCode(code: -2010, message: 'Rejected'),
        isA<BinanceOrderRejected>(),
      );
      expect(
        BinanceApiError.fromCode(code: -2011, message: 'Cancel rejected'),
        isA<BinanceCancelRejected>(),
      );
      expect(
        BinanceApiError.fromCode(code: -2013, message: 'Not found'),
        isA<BinanceOrderNotFound>(),
      );
      expect(
        BinanceApiError.fromCode(code: -2014, message: 'Invalid API Key'),
        isA<BinanceInvalidApiKey>(),
      );
      expect(
        BinanceApiError.fromCode(code: -21015, message: 'Endpoint gone'),
        isA<BinanceEndpointGone>(),
      );
      expect(
        BinanceApiError.fromCode(code: -4109, message: 'Account inactive'),
        isA<BinanceAccountInactive>(),
      );
      expect(
        BinanceApiError.fromCode(code: -999, message: 'Unknown'),
        isA<GenericBinanceApiError>(),
      );
    });

    test('BinanceHttpError toString', () {
      const error = BinanceHttpError(statusCode: 404, message: 'Not Found');
      expect(error.toString(), contains('404'));
      expect(error.toString(), contains('Not Found'));
    });
  });
}
