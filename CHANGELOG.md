# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-04-23

### Added
- New `binance_margin` package covering Binance Margin Trading (Cross and Isolated).
- Support for Margin Loans (borrow, repay, history).
- Support for Margin Transfers (Universal and Isolated).
- Support for Margin Trading (orders, OCO, trades).
- Support for Margin Account management and risk levels.
- Integrated Margin events into unified `UserDataFeed`.

## [0.2.0] - 2026-04-23

### Added
- New `binance_spot` package covering Binance Spot API.
- Support for Spot Market Data REST endpoints (ping, time, exchangeInfo, depth, trades, etc.).
- Support for Spot Account and Trade REST endpoints (order, account, myTrades, etc.).
- Support for Spot Smart Order Routing (SOR) endpoints.
- Support for Spot WebSocket Market Streams (aggTrade, trade, kline, ticker, etc.).
- Enhanced `Result` class in `binance_core` with `map`, `mapError`, and `flatMap`.

### Changed
- Refactored `BinanceHttpClient` in `binance_core` to support generic JSON responses.
- Updated `DefaultBinanceHttpClient` to handle venue routing more robustly.

## [0.1.0] - 2026-04-23
- Initial release with `binance_core` base transport and primitives.
