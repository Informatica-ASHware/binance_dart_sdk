import 'package:ash_binance_api_core/binance_core.dart';
import 'package:ash_binance_api_futures/binance_futures.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockBinanceHttpClient extends Mock implements BinanceHttpClient {}

class MockWebSocketStreamClient extends Mock implements WebSocketStreamClient {}

void main() {
  group('Models', () {
    test('FuturesPosition.fromJson', () {
      final json = {
        'symbol': 'BTCUSDT',
        'initialMargin': '10.5',
        'maintMargin': '5.2',
        'unrealizedProfit': '1.2',
        'positionInitialMargin': '10.5',
        'openOrderInitialMargin': '0.0',
        'leverage': '20',
        'isolated': true,
        'entryPrice': '50000',
        'markPrice': '50100',
        'liquidationPrice': '45000',
        'maxNotionalValue': '1000000',
        'positionSide': 'LONG',
        'positionAmt': '0.1',
        'notional': '5010',
        'isolatedWallet': '100',
        'updateTime': 123456789,
        'marginType': 'isolated',
        'isolatedMargin': '100',
      };
      final position = FuturesPosition.fromJson(json);
      expect(position.symbol.value, 'BTCUSDT');
      expect(position.positionSide, PositionSide.long);
      expect(position.marginType, MarginType.isolated);
    });

    test('FundingRate.fromJson', () {
      final json = {
        'symbol': 'BTCUSDT',
        'fundingRate': '0.0001',
        'fundingTime': 123456789,
      };
      final rate = FundingRate.fromJson(json);
      expect(rate.symbol.value, 'BTCUSDT');
      expect(rate.fundingRate.toString(), '0.0001');
    });

    test('MarkPrice.fromJson', () {
      final json = {
        'symbol': 'BTCUSDT',
        'markPrice': '50000',
        'indexPrice': '49950',
        'estimatedSettlePrice': '50050',
        'lastFundingRate': '0.0001',
        'nextFundingTime': 123456789,
        'time': 123456789,
      };
      final mp = MarkPrice.fromJson(json);
      expect(mp.markPrice.toString(), '50000');
    });

    test('Income.fromJson', () {
      final json = {
        'symbol': 'BTCUSDT',
        'incomeType': 'TRANSFER',
        'income': '100',
        'asset': 'USDT',
        'info': 'test',
        'time': 123456789,
        'tranId': 123,
      };
      final income = Income.fromJson(json);
      expect(income.tranId, '123');
    });

    test('FuturesOrder.fromJson', () {
      final json = {
        'symbol': 'BTCUSDT',
        'orderId': 1,
        'clientOrderId': 'abc',
        'price': '50000',
        'origQty': '1',
        'executedQty': '0.5',
        'cumQuote': '25000',
        'status': 'PARTIALLY_FILLED',
        'timeInForce': 'GTC',
        'type': 'LIMIT',
        'side': 'BUY',
        'stopPrice': '0',
        'workingType': 'MARK_PRICE',
        'time': 123456789,
        'updateTime': 123456789,
      };
      final order = FuturesOrder.fromJson(json);
      expect(order.workingType, WorkingType.markPrice);
      expect(order.status, 'PARTIALLY_FILLED');
    });
  });

  group('BinanceFuturesMarketDataRest', () {
    late MockBinanceHttpClient httpClient;
    late BinanceFuturesMarketDataRest marketData;

    setUp(() {
      httpClient = MockBinanceHttpClient();
      marketData = BinanceFuturesMarketDataRest(httpClient);
      registerFallbackValue(
        const BinanceRequest(
          method: HttpMethod.get,
          path: '',
        ),
      );
    });

    test('ping returns success', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{}),
      );
      final result = await marketData.ping();
      expect(result.isSuccess, isTrue);
    });

    test('time returns server time', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async =>
            const Result.success(<String, dynamic>{'serverTime': 123456789}),
      );
      final result = await marketData.time();
      expect(
        result.fold(onSuccess: (v) => v, onFailure: (e) => null),
        123456789,
      );
    });

    test('exchangeInfo returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'timezone': 'UTC'}),
      );
      final result = await marketData.exchangeInfo();
      expect(result.getOrNull()?['timezone'], 'UTC');
    });

    test('depth returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async =>
            const Result.success(<String, dynamic>{'lastUpdateId': 123}),
      );
      final result = await marketData.depth(const Symbol('BTCUSDT'));
      expect(result.getOrNull()?['lastUpdateId'], 123);
    });

    test('trades returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.trades(const Symbol('BTCUSDT'));
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('historicalTrades returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.historicalTrades(const Symbol('BTCUSDT'));
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('aggTrades returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.aggTrades(const Symbol('BTCUSDT'));
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('klines returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result =
          await marketData.klines(const Symbol('BTCUSDT'), Interval.h1);
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('continuousKlines returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.continuousKlines(
        const Symbol('BTCUSDT'),
        'PERPETUAL',
        Interval.h1,
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('markPrice returns MarkPrice list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[
          <String, dynamic>{
            'symbol': 'BTCUSDT',
            'markPrice': '50000',
            'indexPrice': '49900',
            'estimatedSettlePrice': '50100',
            'lastFundingRate': '0.0001',
            'nextFundingTime': 123456789,
            'time': 123456789,
          }
        ]),
      );
      final result =
          await marketData.markPrice(symbol: const Symbol('BTCUSDT'));
      final list = result.getOrNull();
      expect(list, hasLength(1));
      expect(list?.first.markPrice.toString(), '50000');
    });

    test('fundingRate returns FundingRate list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[
          <String, dynamic>{
            'symbol': 'BTCUSDT',
            'fundingRate': '0.0001',
            'fundingTime': 123456789,
          }
        ]),
      );
      final result =
          await marketData.fundingRate(symbol: const Symbol('BTCUSDT'));
      expect(result.getOrNull(), hasLength(1));
    });

    test('ticker24hr returns dynamic', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async =>
            const Result.success(<String, dynamic>{'priceChange': '100'}),
      );
      final result =
          await marketData.ticker24hr(symbol: const Symbol('BTCUSDT'));
      expect(result.isSuccess, isTrue);
    });

    test('tickerPrice returns dynamic', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'price': '50000'}),
      );
      final result =
          await marketData.tickerPrice(symbol: const Symbol('BTCUSDT'));
      expect(result.isSuccess, isTrue);
    });

    test('tickerBookTicker returns dynamic', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async =>
            const Result.success(<String, dynamic>{'bidPrice': '49999'}),
      );
      final result =
          await marketData.tickerBookTicker(symbol: const Symbol('BTCUSDT'));
      expect(result.isSuccess, isTrue);
    });

    test('openInterest returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async =>
            const Result.success(<String, dynamic>{'openInterest': '100'}),
      );
      final result = await marketData.openInterest(const Symbol('BTCUSDT'));
      expect(result.getOrNull()?['openInterest'], '100');
    });

    test('openInterestHist returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.openInterestHist(
        const Symbol('BTCUSDT'),
        '5m',
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('indexPriceKlines returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.indexPriceKlines(
        const Symbol('BTCUSDT'),
        Interval.m1,
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('markPriceKlines returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.markPriceKlines(
        const Symbol('BTCUSDT'),
        Interval.m1,
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('globalLongShortAccountRatio returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.globalLongShortAccountRatio(
        const Symbol('BTCUSDT'),
        '5m',
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('takerlongshortRatio returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.takerlongshortRatio(
        const Symbol('BTCUSDT'),
        '5m',
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('indexInfo returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.indexInfo();
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('topLongShortAccountRatio returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.topLongShortAccountRatio(
        const Symbol('BTCUSDT'),
        '5m',
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('topLongShortPositionRatio returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.topLongShortPositionRatio(
        const Symbol('BTCUSDT'),
        '5m',
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('basis returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await marketData.basis(
        const Symbol('BTCUSDT'),
        Interval.m1,
      );
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('constituents returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'symbol': 'BTC'}),
      );
      final result = await marketData.constituents(const Symbol('BTCUSDT'));
      expect(result.getOrNull()?['symbol'], 'BTC');
    });
  });

  group('BinanceFuturesTradeRest', () {
    late MockBinanceHttpClient httpClient;
    late BinanceFuturesTradeRest trade;

    setUp(() {
      httpClient = MockBinanceHttpClient();
      trade = BinanceFuturesTradeRest(httpClient);
    });

    test('newOrder returns FuturesOrder', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{
          'symbol': 'BTCUSDT',
          'orderId': 1,
          'clientOrderId': 'abc',
          'price': '50000',
          'origQty': '1',
          'executedQty': '0',
          'cumQuote': '0',
          'status': 'NEW',
          'timeInForce': 'GTC',
          'type': 'LIMIT',
          'side': 'BUY',
          'stopPrice': '0',
          'workingType': 'CONTRACT_PRICE',
          'time': 123456789,
          'updateTime': 123456789,
        }),
      );

      final result = await trade.newOrder(
        symbol: const Symbol('BTCUSDT'),
        side: 'BUY',
        type: 'LIMIT',
        price: Decimal.parse('50000'),
        quantity: Decimal.parse('1'),
      );
      expect(result.getOrNull()?.symbol.value, 'BTCUSDT');
    });

    test('batchOrders returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await trade.batchOrders(<Map<String, dynamic>>[]);
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('cancelOrder returns FuturesOrder', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{
          'symbol': 'BTCUSDT',
          'orderId': 1,
          'clientOrderId': 'abc',
          'price': '50000',
          'origQty': '1',
          'executedQty': '0',
          'cumQuote': '0',
          'status': 'CANCELED',
          'timeInForce': 'GTC',
          'type': 'LIMIT',
          'side': 'BUY',
          'stopPrice': '0',
          'workingType': 'CONTRACT_PRICE',
          'time': 123456789,
          'updateTime': 123456789,
        }),
      );
      final result =
          await trade.cancelOrder(const Symbol('BTCUSDT'), orderId: 1);
      expect(result.getOrNull()?.status, 'CANCELED');
    });

    test('cancelAllOpenOrders returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'code': 200}),
      );
      final result = await trade.cancelAllOpenOrders(const Symbol('BTCUSDT'));
      expect(result.getOrNull()?['code'], 200);
    });

    test('getOrder returns FuturesOrder', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{
          'symbol': 'BTCUSDT',
          'orderId': 1,
          'clientOrderId': 'abc',
          'price': '50000',
          'origQty': '1',
          'executedQty': '0',
          'cumQuote': '0',
          'status': 'NEW',
          'timeInForce': 'GTC',
          'type': 'LIMIT',
          'side': 'BUY',
          'stopPrice': '0',
          'workingType': 'CONTRACT_PRICE',
          'time': 123456789,
          'updateTime': 123456789,
        }),
      );
      final result = await trade.getOrder(const Symbol('BTCUSDT'), orderId: 1);
      expect(result.getOrNull()?.orderId, 1);
    });

    test('getOpenOrders returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await trade.getOpenOrders();
      expect(result.getOrNull(), isA<List<FuturesOrder>>());
    });

    test('getAllOrders returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await trade.getAllOrders(const Symbol('BTCUSDT'));
      expect(result.getOrNull(), isA<List<FuturesOrder>>());
    });

    test('testOrder returns success', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{}),
      );
      final result = await trade.testOrder(
        symbol: const Symbol('BTCUSDT'),
        side: 'BUY',
        type: 'LIMIT',
        price: Decimal.parse('50000'),
        quantity: Decimal.parse('1'),
      );
      expect(result.isSuccess, isTrue);
    });

    test('getForceOrders returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await trade.getForceOrders();
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('getOrderRateLimit returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await trade.getOrderRateLimit();
      expect(result.getOrNull(), isA<List<dynamic>>());
    });
  });

  group('BinanceFuturesAccountRest', () {
    late MockBinanceHttpClient httpClient;
    late BinanceFuturesAccountRest account;

    setUp(() {
      httpClient = MockBinanceHttpClient();
      account = BinanceFuturesAccountRest(httpClient);
    });

    test('getAccountInfo returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async =>
            const Result.success(<String, dynamic>{'canDeposit': true}),
      );
      final result = await account.getAccountInfo();
      expect(result.getOrNull()?['canDeposit'], true);
    });

    test('getBalances returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await account.getBalances();
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('getPositionRisk returns list of positions', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[
          <String, dynamic>{
            'symbol': 'BTCUSDT',
            'initialMargin': '0',
            'maintMargin': '0',
            'unrealizedProfit': '0',
            'positionInitialMargin': '0',
            'openOrderInitialMargin': '0',
            'leverage': '20',
            'isolated': false,
            'entryPrice': '0',
            'markPrice': '50000',
            'liquidationPrice': '0',
            'maxNotionalValue': '1000000',
            'positionSide': 'BOTH',
            'positionAmt': '0',
            'notional': '0',
            'isolatedWallet': '0',
            'updateTime': 123456789,
            'marginType': 'CROSSED',
            'isolatedMargin': '0',
          },
        ]),
      );
      final result = await account.getPositionRisk();
      expect(result.getOrNull()?.first.symbol.value, 'BTCUSDT');
    });

    test('changeLeverage returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'leverage': 20}),
      );
      final result = await account.changeLeverage(const Symbol('BTCUSDT'), 20);
      expect(result.getOrNull()?['leverage'], 20);
    });

    test('changeMarginType returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'code': 200}),
      );
      final result = await account.changeMarginType(
        const Symbol('BTCUSDT'),
        MarginType.isolated,
      );
      expect(result.getOrNull()?['code'], 200);
    });

    test('modifyPositionMargin returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'amount': '100'}),
      );
      final result = await account.modifyPositionMargin(
        const Symbol('BTCUSDT'),
        Decimal.parse('100'),
        1,
      );
      expect(result.getOrNull()?['amount'], '100');
    });

    test('getIncomeHistory returns list of Income', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[
          <String, dynamic>{
            'symbol': 'BTCUSDT',
            'incomeType': 'FUNDING_FEE',
            'income': '-0.1',
            'asset': 'USDT',
            'info': 'info',
            'time': 123456789,
            'tranId': 1,
          }
        ]),
      );
      final result = await account.getIncomeHistory();
      expect(result.getOrNull()?.first.incomeType, 'FUNDING_FEE');
    });

    test('getUserTrades returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result = await account.getUserTrades(const Symbol('BTCUSDT'));
      expect(result.getOrNull(), isA<List<dynamic>>());
    });

    test('getCommissionRate returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'symbol': 'BTC'}),
      );
      final result = await account.getCommissionRate(const Symbol('BTCUSDT'));
      expect(result.getOrNull()?['symbol'], 'BTC');
    });

    test('getPmAccountInfo returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'asset': 'USDT'}),
      );
      final result = await account.getPmAccountInfo();
      expect(result.getOrNull()?['asset'], 'USDT');
    });

    test('changeMultiAssetsMode returns map', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<String, dynamic>{'code': 200}),
      );
      final result =
          await account.changeMultiAssetsMode(multiAssetsMargin: true);
      expect(result.getOrNull()?['code'], 200);
    });

    test('getPositionMarginHistory returns list', () async {
      when(() => httpClient.send(any())).thenAnswer(
        (_) async => const Result.success(<dynamic>[]),
      );
      final result =
          await account.getPositionMarginHistory(const Symbol('BTCUSDT'));
      expect(result.getOrNull(), isA<List<dynamic>>());
    });
  });

  group('BinanceFuturesStreamClient', () {
    late MockWebSocketStreamClient streamClient;
    late BinanceFuturesStreamClient futuresStream;

    setUp(() {
      streamClient = MockWebSocketStreamClient();
      futuresStream = BinanceFuturesStreamClient(streamClient);
    });

    test('aggTrade returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.aggTrade(const Symbol('BTCUSDT'));
      verify(() => streamClient.subscribe('btcusdt@aggTrade')).called(1);
    });

    test('markPrice returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.markPrice(const Symbol('BTCUSDT'));
      verify(() => streamClient.subscribe('btcusdt@markPrice')).called(1);
    });

    test('allMarkPrice returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.allMarkPrice();
      verify(() => streamClient.subscribe('!markPrice@arr')).called(1);
    });

    test('kline returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.kline(const Symbol('BTCUSDT'), Interval.m1);
      verify(() => streamClient.subscribe('btcusdt@kline_1m')).called(1);
    });

    test('continuousKline returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.continuousKline(
        const Symbol('BTCUSDT'),
        'PERPETUAL',
        Interval.m1,
      );
      verify(
        () => streamClient.subscribe('btcusdt_perpetual@continuousKline_1m'),
      ).called(1);
    });

    test('liquidationOrder returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.liquidationOrder(const Symbol('BTCUSDT'));
      verify(() => streamClient.subscribe('btcusdt@forceOrder')).called(1);
    });

    test('allLiquidationOrders returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.allLiquidationOrders();
      verify(() => streamClient.subscribe('!forceOrder@arr')).called(1);
    });

    test('indexPrice returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.indexPrice(const Symbol('BTCUSDT'));
      verify(() => streamClient.subscribe('btcusdt@indexPrice')).called(1);
    });

    test('assetIndex returns stream', () {
      when(() => streamClient.subscribe(any()))
          .thenAnswer((_) => const Stream.empty());
      futuresStream.assetIndex(const Asset('USDT'));
      verify(() => streamClient.subscribe('usdt@assetIndex')).called(1);
    });
  });
}

extension ResultX<S, E> on Result<S, E> {
  S? getOrNull() => fold(onSuccess: (v) => v, onFailure: (e) => null);
}
