# Changelog

## 0.2.0

- Added unified `UserDataFeed` abstraction in `binance_core`.
- Implemented `SpotUserDataFeed` using modern WS API mechanism (post 2026-02-20).
- Implemented `FuturesUserDataFeed` using classic `listenKey` mechanism with 30-minute auto-renewal.
- Added support for `session.logon` in `WebSocketApiClient` and automatic re-authentication.
- Enhanced `DefaultBinanceHttpClient` with better venue routing and improved retry logic.
- Defined sealed class hierarchies for `UserDataEvent` and `UserDataFeedStatus`.
- Implemented gap detection in user data streams for state reconciliation.

## 0.1.1

- Added HTTP transport layer with rate limiting, circuit breaker, and retry policy.
- Implemented `BinanceHttpClient` and `DefaultBinanceHttpClient`.
- Added support for preventative rate-limiting and 429/418 error handling.

## 0.1.0

- Initial monorepo setup with Melos.
- Created binance_core package.
