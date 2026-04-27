# binance_spot

Comprehensive implementation of the Binance Spot API.

## Features

- **Market Data:** Full coverage of public market data endpoints.
- **Trading:** Support for Limit, Market, Stop-Loss, and OCO orders.
- **Account Management:** Query balances, trade history, and account status.
- **User Data Stream:** Real-time updates for account balances and order status.

## Quick Start

```dart
import 'package:binance_spot/binance_spot.dart';
import 'package:binance_core/binance_core.dart';

void main() async {
  final client = MarketDataClient(environment: BinanceEnvironment.mainnet);
  final orderBook = await client.getOrderBook(symbol: 'BTCUSDT');

  orderBook.when(
    success: (book) => print('Best bid: ${book.bids.first.price}'),
    failure: (error) => print('Error: $error'),
  );
}
```

## Endpoints Covered

| Category | Endpoint | Spec Link |
| -------- | -------- | --------- |
| Market | `GET /api/v3/depth` | [Order Book](https://binance-docs.github.io/apidocs/spot/en/#order-book) |
| Market | `GET /api/v3/ticker/price` | [Symbol Price Ticker](https://binance-docs.github.io/apidocs/spot/en/#symbol-price-ticker) |
| Account | `GET /api/v3/account` | [Account Information](https://binance-docs.github.io/apidocs/spot/en/#account-information-user_data) |
| Trade | `POST /api/v3/order` | [New Order](https://binance-docs.github.io/apidocs/spot/en/#new-order-trade) |
| User Stream| `POST /api/v3/userDataStream` | [Create a ListenKey](https://binance-docs.github.io/apidocs/spot/en/#user-data-streams) |

## Known Differences vs Official Spec

- **WS API (Schema 2.0):** This SDK prioritizes the WebSocket API for authenticated actions, following Binance's modern recommendations.
- **Fluid Builders:** Uses `SpotOrderBuilder` for type-safe order creation with client-side validation.

## Changelog

### 0.1.0
- Full Market Data and Account/Trade REST API coverage.
- WebSocket Stream and API client implementation.
- Support for `UserDataFeed` abstraction.
