import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/builders.dart';
import 'package:binance_spot/src/models/market_data.dart';
import 'package:glados/glados.dart';

void main() {
  const btcUsdt = SymbolInfo(
    symbol: Symbol('BTCUSDT'),
    status: 'TRADING',
    baseAsset: Asset('BTC'),
    baseAssetPrecision: 8,
    quoteAsset: Asset('USDT'),
    quotePrecision: 8,
    quoteAssetPrecision: 8,
    baseCommissionPrecision: 8,
    quoteCommissionPrecision: 8,
    orderTypes: ['LIMIT', 'MARKET'],
    icebergAllowed: true,
    ocoAllowed: true,
    quoteOrderQtyMarketAllowed: true,
    allowTrailingStop: true,
    cancelReplaceAllowed: true,
    isSpotTradingAllowed: true,
    isMarginTradingAllowed: true,
    filters: [],
    permissions: ['SPOT', 'MARGIN'],
    defaultSelfTradePreventionMode: 'NONE',
    allowedSelfTradePreventionModes: ['NONE', 'EXPIRE_TAKER'],
  );

  group('SpotOrderBuilder Property Tests', () {
    Glados(any.double).test(
      'build LIMIT order with various prices',
      (priceValue) {
        if (priceValue <= 0 || priceValue.isNaN || priceValue.isInfinite) {
          return;
        }

        final priceStr = priceValue.toStringAsFixed(8);
        final builder = SpotOrderBuilder.limit()
            .symbol(const Symbol('BTCUSDT'))
            .price(Price.fromString(priceStr))
            .quantity(Quantity.fromString('1.0'));

        final result = builder.build(btcUsdt);
        expect(result, isNotNull);
      },
    );
  });
}
