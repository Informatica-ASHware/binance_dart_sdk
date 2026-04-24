# binance_core

The foundation of the `binance_dart_sdk`. It provides the core primitives, network transport, and authentication mechanisms used by all venue-specific packages.

## Features

- **Robust HTTP Client:** With built-in retry logic, circuit breakers, and rate-limit tracking.
- **WebSocket Infrastructure:** Base classes for both API (Request/Response) and Stream (Unsolicited) connections.
- **Flexible Authentication:** Supports API Key/Secret and modern Ed25519 signing.
- **Type-Safe Results:** Uses the `Result<S, E>` pattern for expressive error handling.
- **Observability:** `BinanceTelemetrySink` for deep insights into the SDK's internal operations.

## Quick Start

```dart
import 'package:binance_core/binance_core.dart';

// Create a simple telemetry sink
class MyLogger extends BinanceTelemetrySink {
  @override
  void report(BinanceTelemetryEvent event) => print(event);
}

// Initialize the core HTTP client
final client = DefaultBinanceHttpClient(
  environment: BinanceEnvironment.mainnet,
  observability: BinanceObservabilityHooks(telemetry: MyLogger()),
);
```

## Authentication (Ed25519)

```dart
import 'dart:io';
import 'package:binance_core/binance_core.dart';

final privateKeyPem = File('path/to/private_key.pem').readAsStringSync();
final credentials = BinanceCredentials(
  apiKey: 'your_api_key',
  apiSecret: 'not_used_for_ed25519',
);

final signer = Ed25519Signer.fromPem(privateKeyPem);

final client = DefaultBinanceHttpClient(
  environment: BinanceEnvironment.mainnet,
  credentials: credentials,
  signer: signer,
);
```

## Known Differences vs Official Spec

- **Result Pattern:** Instead of throwing exceptions, methods return a `Result` type to force handling of error cases.
- **Decimal:** All price and quantity fields use the `Decimal` type to avoid floating-point precision issues.

## Changelog

### 0.1.0
- Initial internal release with core HTTP and WebSocket components.
- Added support for Ed25519 signing.
- Implemented rate limiting and circuit breakers.
