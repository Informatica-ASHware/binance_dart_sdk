import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:binance_spot/src/models/market_data.dart';
import 'package:binance_spot/src/validation.dart';
import 'package:test/test.dart';

void main() {
  group('BinanceSpotValidator', () {
    late SymbolInfo btcUsdt;

    setUp(() {
      btcUsdt = SymbolInfo(
        symbol: const Symbol('BTCUSDT'),
        status: 'TRADING',
        baseAsset: const Asset('BTC'),
        baseAssetPrecision: 8,
        quoteAsset: const Asset('USDT'),
        quotePrecision: 8,
        quoteAssetPrecision: 8,
        baseCommissionPrecision: 8,
        quoteCommissionPrecision: 8,
        orderTypes: const ['LIMIT', 'MARKET', 'STOP_LOSS_LIMIT'],
        icebergAllowed: true,
        ocoAllowed: true,
        quoteOrderQtyMarketAllowed: true,
        allowTrailingStop: true,
        cancelReplaceAllowed: true,
        isSpotTradingAllowed: true,
        isMarginTradingAllowed: true,
        filters: [
          PriceFilter(
            minPrice: Price.fromString('1000'),
            maxPrice: Price.fromString('100000'),
            tickSize: Price.fromString('0.01'),
          ),
          LotSizeFilter(
            minQty: Quantity.fromString('0.0001'),
            maxQty: Quantity.fromString('100'),
            stepSize: Quantity.fromString('0.0001'),
          ),
          NotionalFilter(
            minNotional: Price.fromString('10'),
            applyMinToMarket: true,
            maxNotional: Price.fromString('1000000'),
            applyMaxToMarket: false,
            avgPriceMins: 5,
          ),
        ],
        permissions: const ['SPOT'],
        defaultSelfTradePreventionMode: 'NONE',
        allowedSelfTradePreventionModes: const ['NONE'],
      );
    });

    test('validates successful order', () {
      final result = BinanceSpotValidator.validateOrder(
        symbolInfo: btcUsdt,
        side: Side.buy,
        type: OrderType.limit,
        price: Price.fromString('50000.00'),
        quantity: Quantity.fromString('0.001'),
      );
      expect(result.isSuccess, isTrue);
    });

    test('fails on disallowed order type', () {
      final result = BinanceSpotValidator.validateOrder(
        symbolInfo: btcUsdt,
        side: Side.buy,
        type: OrderType.stopLoss, // Not in btcUsdt.orderTypes
      );
      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (_) => '', onFailure: (e) => e.message),
        contains('not allowed'),
      );
    });

    test('fails on price below minPrice', () {
      final result = BinanceSpotValidator.validateOrder(
        symbolInfo: btcUsdt,
        side: Side.buy,
        type: OrderType.limit,
        price: Price.fromString('500.00'),
        quantity: Quantity.fromString('0.1'),
      );
      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (_) => '', onFailure: (e) => e.message),
        contains('below minPrice'),
      );
    });

    test('fails on quantity not multiple of stepSize', () {
      final result = BinanceSpotValidator.validateOrder(
        symbolInfo: btcUsdt,
        side: Side.buy,
        type: OrderType.limit,
        price: Price.fromString('50000.00'),
        quantity: Quantity.fromString('0.00015'),
      );
      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (_) => '', onFailure: (e) => e.message),
        contains('not a multiple of stepSize'),
      );
    });

    test('fails on notional below minNotional', () {
      final result = BinanceSpotValidator.validateOrder(
        symbolInfo: btcUsdt,
        side: Side.buy,
        type: OrderType.limit,
        price: Price.fromString('1000.00'),
        quantity: Quantity.fromString('0.0001'), // 1000 * 0.0001 = 0.1 < 10
      );
      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (_) => '', onFailure: (e) => e.message),
        contains('below minNotional'),
      );
    });

    test('fails when stopPrice is required but missing', () {
      final result = BinanceSpotValidator.validateOrder(
        symbolInfo: btcUsdt,
        side: Side.buy,
        type: OrderType.stopLossLimit,
        price: Price.fromString('50000.00'),
        quantity: Quantity.fromString('0.001'),
        // stopPrice missing
      );
      expect(result.isFailure, isTrue);
      expect(
        result.fold(onSuccess: (_) => '', onFailure: (e) => e.message),
        contains('stopPrice is required'),
      );
    });
  });
}
