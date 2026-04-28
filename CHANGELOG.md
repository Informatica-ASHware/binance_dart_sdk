# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](https://conventionalcommits.org) for commit guidelines.

## 2026-04-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`ash_binance_api_core` - `v0.1.1+3`](#ash_binance_api_core---v0113)

---

#### `ash_binance_api_core` - `v0.1.1+3`

 - Bump "ash_binance_api_core" to `0.1.1+3`.


## 2026-04-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`ash_binance_api_core` - `v0.1.1+2`](#ash_binance_api_core---v0112)

---

#### `ash_binance_api_core` - `v0.1.1+2`

 - Bump "ash_binance_api_core" to `0.1.1+2`.


## 2026-04-28

### Changes

---

Packages with breaking changes:

 - There are no breaking changes in this release.

Packages with other changes:

 - [`ash_binance_api_core` - `v0.1.1+1`](#ash_binance_api_core---v0111)

---

#### `ash_binance_api_core` - `v0.1.1+1`

 - Bump "ash_binance_api_core" to `0.1.1+1`.

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-04-23

### Added
- New `binance_futures` package covering Binance USD-M Futures.
- Full REST Market Data API support for Futures.
- REST Trade and Account API support (Orders, Positions, Leverage, Margin).
- WebSocket Market Streams support (aggTrade, markPrice, kline, liquidationOrder, etc.).
- WebSocket API support for Futures.
- Updated unified `UserDataFeed` in `binance_core` with Futures-specific fields.

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
