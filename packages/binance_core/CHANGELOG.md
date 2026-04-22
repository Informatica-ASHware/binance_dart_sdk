# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-05-22

### Added

- Initial implementation of core primitives.
- `Symbol`, `Asset`, `Price`, `Quantity`, `Percentage`, `Money`, `OrderId`, `ClientOrderId`, `Timestamp` immutable classes.
- `Interval` enum for Binance timeframes.
- `BinanceEnvironment` enum for environment configuration.
- `BinanceError` sealed class hierarchy for robust error handling.
- `Result<S, E>` sealed class for functional error handling.
- `Decimal` internal implementation for high-precision arithmetic.
- Full unit test suite with >95% coverage.
- Strict linting with `very_good_analysis`.
