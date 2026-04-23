import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/builders.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:binance_spot/src/models/market_data.dart';
import 'package:test/test.dart';

void main() {
  group('SpotOrderBuilder', () {
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
        orderTypes: const ['LIMIT', 'MARKET'],
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
        ],
        permissions: const ['SPOT'],
        defaultSelfTradePreventionMode: 'NONE',
        allowedSelfTradePreventionModes: const ['NONE'],
      );
    });

    test('builds valid limit order', () {
      final result = SpotOrderBuilder.limit()
          .symbol(const Symbol('BTCUSDT'))
          .side(Side.buy)
          .quantity(Quantity.fromString('0.001'))
          .price(Price.fromString('50000'))
          .build(btcUsdt);

      expect(result.isSuccess, isTrue);
      final request =
          result.fold(onSuccess: (r) => r, onFailure: (_) => throw Exception());
      expect(request.symbol.value, 'BTCUSDT');
      expect(request.price?.value.toString(), '50000');
    });

    test('fails on symbol mismatch', () {
      final result = SpotOrderBuilder.limit()
          .symbol(const Symbol('ETHUSDT'))
          .build(btcUsdt);

      expect(result.isFailure, isTrue);
      expect(result.fold(onSuccess: (_) => '', onFailure: (e) => e.message),
          contains('Symbol mismatch'));
    });
  });

  group('OcoOrderBuilder', () {
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
        orderTypes: const ['LIMIT', 'MARKET'],
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
        ],
        permissions: const ['SPOT'],
        defaultSelfTradePreventionMode: 'NONE',
        allowedSelfTradePreventionModes: const ['NONE'],
      );
    });

    test('builds valid OCO order', () {
      final result = OcoOrderBuilder.oco()
          .symbol(const Symbol('BTCUSDT'))
          .side(Side.buy)
          .quantity(Quantity.fromString('0.001'))
          .price(Price.fromString('40000'))
          .stopPrice(Price.fromString('50000'))
          .stopLimitPrice(Price.fromString('50100'))
          .build(btcUsdt);

      expect(result.isSuccess, isTrue);
    });
  });
}
