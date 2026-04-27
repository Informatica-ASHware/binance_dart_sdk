import 'package:ash_binance_api_spot/binance_spot.dart';
import 'package:test/test.dart';

void main() {
  group('Market Data Models', () {
    test('ExchangeInfo.fromJson', () {
      final json = {
        'timezone': 'UTC',
        'serverTime': 1600000000000,
        'rateLimits': <dynamic>[],
        'exchangeFilters': <dynamic>[],
        'symbols': [
          {
            'symbol': 'BTCUSDT',
            'status': 'TRADING',
            'baseAsset': 'BTC',
            'baseAssetPrecision': 8,
            'quoteAsset': 'USDT',
            'quotePrecision': 8,
            'quoteAssetPrecision': 8,
            'baseCommissionPrecision': 8,
            'quoteCommissionPrecision': 8,
            'orderTypes': ['LIMIT', 'MARKET'],
            'icebergAllowed': true,
            'ocoAllowed': true,
            'otoAllowed': false,
            'quoteOrderQtyMarketAllowed': true,
            'allowTrailingStop': true,
            'cancelReplaceAllowed': true,
            'isSpotTradingAllowed': true,
            'isMarginTradingAllowed': true,
            'filters': <dynamic>[],
            'permissions': ['SPOT'],
            'defaultSelfTradePreventionMode': 'NONE',
            'allowedSelfTradePreventionModes': ['NONE'],
          },
        ],
      };

      final info = ExchangeInfo.fromJson(json);
      expect(info.timezone, 'UTC');
      expect(info.symbols.first.symbol.value, 'BTCUSDT');
    });

    test('OrderBook.fromJson', () {
      final json = {
        'lastUpdateId': 100,
        'bids': [
          ['50000.00', '1.000'],
        ],
        'asks': [
          ['50010.00', '2.000'],
        ],
      };
      final book = OrderBook.fromJson(json);
      expect(book.lastUpdateId, 100);
      expect(book.bids.first.$1.value.toString(), '50000');
    });
  });

  group('Account Models', () {
    test('AssetBalance.fromJson', () {
      final json = {'asset': 'BTC', 'free': '1.0', 'locked': '0.0'};
      final balance = AssetBalance.fromJson(json);
      expect(balance.asset.value, 'BTC');
      expect(balance.free.value.toString(), '1');
    });
  });
}
