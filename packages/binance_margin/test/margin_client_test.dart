import 'package:binance_core/binance_core.dart';
import 'package:binance_margin/binance_margin.dart';
import 'package:binance_spot/binance_spot.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBinanceHttpClient extends Mock implements BinanceHttpClient {}

void main() {
  late MockBinanceHttpClient mockHttpClient;
  late BinanceMarginClient marginClient;

  setUp(() {
    mockHttpClient = MockBinanceHttpClient();
    marginClient = BinanceMarginClient(mockHttpClient);
    registerFallbackValue(
      BinanceRequest(
        method: HttpMethod.get,
        path: '',
        securityType: BinanceSecurityType.public,
      ),
    );
  });

  group('BinanceMarginClient', () {
    test('borrow sends correct request', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => const Result.success({'tranId': 12345}),
      );

      final result = await marginClient.borrow(
        asset: Asset('BTC'),
        amount: Decimal.parse('0.1'),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.fold(onSuccess: (v) => v, onFailure: (e) => throw e),
        12345,
      );

      final captured = verify(() => mockHttpClient.send(captureAny())).captured;
      final request = captured.first as BinanceRequest;
      expect(request.method, HttpMethod.post);
      expect(request.path, '/sapi/v1/margin/loan');
      expect(request.queryParams['asset'], 'BTC');
      expect(request.queryParams['amount'], '0.1');
    });

    test('getAccount sends correct request', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => const Result.success({
          "borrowEnabled": true,
          "marginLevel": "11.64",
          "totalAssetOfBtc": "6.82",
          "totalLiabilityOfBtc": "0.58",
          "totalNetAssetOfBtc": "6.24",
          "tradeEnabled": true,
          "transferEnabled": true,
          "userAssets": []
        }),
      );

      final result = await marginClient.getAccount();

      expect(result.isSuccess, isTrue);
      final account =
          result.fold(onSuccess: (v) => v, onFailure: (e) => throw e);
      expect(account.borrowEnabled, isTrue);

      final captured = verify(() => mockHttpClient.send(captureAny())).captured;
      final request = captured.first as BinanceRequest;
      expect(request.method, HttpMethod.get);
      expect(request.path, '/sapi/v1/margin/account');
    });

    test('newOrder sends correct request', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => const Result.success({
          "symbol": "BTCUSDT",
          "orderId": 28,
          "clientOrderId": "6g6z9p",
          "transactTime": 1507725176595,
          "orderListId": -1
        }),
      );

      final result = await marginClient.newOrder(
        symbol: Symbol('BTCUSDT'),
        side: Side.buy,
        type: OrderType.market,
        quantity: Quantity.fromString('0.1'),
      );

      expect(result.isSuccess, isTrue);
      expect(
        result.fold(onSuccess: (v) => v.symbol, onFailure: (e) => throw e),
        Symbol('BTCUSDT'),
      );

      final captured = verify(() => mockHttpClient.send(captureAny())).captured;
      final request = captured.first as BinanceRequest;
      expect(request.method, HttpMethod.post);
      expect(request.path, '/sapi/v1/margin/order');
      expect(request.queryParams['symbol'], 'BTCUSDT');
      expect(request.queryParams['side'], 'BUY');
    });

    test('getIsolatedAccount sends correct request', () async {
      when(() => mockHttpClient.send(any())).thenAnswer(
        (_) async => const Result.success({"assets": []}),
      );

      final result = await marginClient.getIsolatedAccount(
        symbols: [Symbol('BTCUSDT')],
      );

      expect(result.isSuccess, isTrue);

      final captured = verify(() => mockHttpClient.send(captureAny())).captured;
      final request = captured.first as BinanceRequest;
      expect(request.method, HttpMethod.get);
      expect(request.path, '/sapi/v1/margin/isolated/account');
      expect(request.queryParams['symbols'], 'BTCUSDT');
    });
  });
}
