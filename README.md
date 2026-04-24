# binance_dart_sdk

A comprehensive, pure-Dart SDK for the Binance API, covering Spot, Margin, and USD-M Futures.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.5+-blue.svg)](https://dart.dev)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://makeapullrequest.com)

## Packages

This monorepo contains the following packages:

| Package | Description | Version |
| ------- | ----------- | ------- |
| [`binance_core`](./packages/binance_core) | Core primitives, HTTP/WS transport, and authentication. | 0.1.0 |
| [`binance_spot`](./packages/binance_spot) | Comprehensive Binance Spot API coverage. | 0.1.0 |
| [`binance_margin`](./packages/binance_margin) | Support for Cross and Isolated Margin trading. | 0.1.0 |
| [`binance_futures`](./packages/binance_futures) | Comprehensive Binance USD-M Futures API coverage. | 0.1.0 |

## Support Matrix

| Platform | Supported | Notes |
| -------- | :-------: | ----- |
| Dart VM (CLI/Server) | :white_check_mark: | Full support including AOT. |
| Flutter (Mobile/Desktop) | :white_check_mark: | Compatible (Pure Dart). |
| Web | :x: | Limited by custom header requirements in browser WebSockets. |

### Operating Systems
- Linux
- macOS
- Windows

## Key Features

- **Pure Dart:** Zero Flutter dependencies, optimized for server-side and CLI applications.
- **Type-Safe:** Robust models for all API responses and WebSocket events.
- **Observability:** Built-in telemetry for monitoring requests, rate limits, and errors.
- **Resilience:** Automatic retries, circuit breakers, and rate-limit tracking.
- **Modern Auth:** Support for API Key/Secret and Ed25519 signing.
- **Unified User Data Feed:** Simplified management of account updates across all venues.

## Quick Start

```dart
import 'package:binance_spot/binance_spot.dart';
import 'package:binance_core/binance_core.dart';

void main() async {
  final client = MarketDataClient(
    environment: BinanceEnvironment.mainnet,
  );

  final result = await client.getTickerPrice(symbol: 'BTCUSDT');

  result.when(
    success: (ticker) => print('BTC Price: ${ticker.price}'),
    failure: (error) => print('Error: $error'),
  );
}
```

## Documentation

- [Full API Reference (Dartdoc)](https://pub.dev/documentation/binance_spot/latest/) (Coming soon)
- [Examples](./examples)

## Security and Contributing

Please refer to [SECURITY.md](./SECURITY.md) and [CONTRIBUTING.md](./CONTRIBUTING.md) for more information.

## License

MIT License. See [LICENSE](./LICENSE) for details.
