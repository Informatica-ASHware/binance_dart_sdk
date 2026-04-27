# binance_margin

Support for Binance Margin Trading, covering both Cross and Isolated margin.

## Features

- **Margin Management:** Transfer funds, borrow, and repay.
- **Trading:** Execute orders with margin side effects.
- **Risk Monitoring:** Track account equity, debt, and margin level.

## Quick Start

```dart
import 'package:binance_margin/binance_margin.dart';
import 'package:binance_core/binance_core.dart';

void main() async {
  final client = MarginAccountClient(
    environment: BinanceEnvironment.mainnet,
    credentials: myCredentials,
    signer: mySigner,
  );

  final account = await client.getCrossMarginAccountDetails();
  account.when(
    success: (data) => print('Total Equity: ${data.totalEquityBTC} BTC'),
    failure: (error) => print('Error: $error'),
  );
}
```

## Endpoints Covered

| Category | Endpoint | Spec Link |
| -------- | -------- | --------- |
| Account | `GET /sapi/v1/margin/account` | [Query Margin Account Details](https://binance-docs.github.io/apidocs/spot/en/#query-cross-margin-account-details-user_data) |
| Asset | `POST /sapi/v1/margin/borrow` | [Margin Account Borrow](https://binance-docs.github.io/apidocs/spot/en/#margin-account-borrow-margin) |
| Asset | `POST /sapi/v1/margin/repay` | [Margin Account Repay](https://binance-docs.github.io/apidocs/spot/en/#margin-account-repay-margin) |
| Trade | `POST /sapi/v1/margin/order` | [Margin Account New Order](https://binance-docs.github.io/apidocs/spot/en/#margin-account-new-order-trade) |

## Changelog

### 0.1.0
- Initial support for Cross and Isolated Margin REST API.
- Integration with unified `OrderTradeUpdate` events.
