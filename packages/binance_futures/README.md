# binance_futures

Comprehensive implementation of the Binance USD-M Futures API.

## Features

- **Market Data:** Real-time prices, klines, and open interest.
- **Position Management:** Change leverage, margin type, and monitor PnL.
- **Trading:** Support for Hedge and One-way position modes.
- **High Performance:** Optimized for the low-latency requirements of futures trading.

## Quick Start

```dart
import 'package:binance_futures/binance_futures.dart';
import 'package:binance_core/binance_core.dart';

void main() async {
  final client = FuturesMarketDataClient(environment: BinanceEnvironment.mainnet);
  final klines = await client.getKlines(symbol: 'BTCUSDT', interval: '1h');

  klines.when(
    success: (data) => print('Latest close: ${data.last.close}'),
    failure: (error) => print('Error: $error'),
  );
}
```

## Endpoints Covered

| Category | Endpoint | Spec Link |
| -------- | -------- | --------- |
| Market | `GET /fapi/v1/ticker/price` | [Symbol Price Ticker](https://binance-docs.github.io/apidocs/futures/en/#symbol-price-ticker) |
| Account | `GET /fapi/v2/account` | [Account Information](https://binance-docs.github.io/apidocs/futures/en/#account-information-v2-user_data) |
| Position | `GET /fapi/v2/positionRisk` | [Position Information](https://binance-docs.github.io/apidocs/futures/en/#position-information-v2-user_data) |
| Trade | `POST /fapi/v1/order` | [New Order](https://binance-docs.github.io/apidocs/futures/en/#new-order-trade) |

## Known Differences vs Official Spec

- **Wallet Balance Mapping:** In unified `AccountUpdate` events, the `wb` (wallet balance) raw field is mapped to the unified `free` balance property for consistency with Spot.

## Changelog

### 0.1.0
- Initial release with full USD-M Futures REST and WebSocket support.
- Support for Hedge Mode and multi-asset margin.
