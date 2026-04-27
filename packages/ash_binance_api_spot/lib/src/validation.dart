import 'package:ash_binance_api_core/ash_binance_api_core.dart';
import 'package:ash_binance_api_spot/src/enums.dart';
import 'package:ash_binance_api_spot/src/models/market_data.dart';

/// Validator for Binance Spot orders.
class BinanceSpotValidator {
  /// Validates a new order against [SymbolInfo] and [ExchangeInfo].
  static Result<void, BinanceValidationError> validateOrder({
    required SymbolInfo symbolInfo,
    required Side side,
    required OrderType type,
    TimeInForce? timeInForce,
    Quantity? quantity,
    Quantity? quoteOrderQty,
    Price? price,
    Price? stopPrice,
    Price? trailingDelta,
    Price? icebergQty,
    Price? avgPrice, // Required for PERCENT_PRICE filters
  }) {
    // 1. Check if order type is allowed for the symbol
    if (!symbolInfo.orderTypes.contains(type.value)) {
      return Result.failure(
        BinanceValidationError(
          'Order type ${type.value} not allowed for symbol '
          '${symbolInfo.symbol}',
        ),
      );
    }

    // 2. Check timeInForce compatibility
    if (timeInForce != null) {
      final isCompatible = _isTimeInForceCompatible(type, timeInForce);
      if (!isCompatible) {
        return Result.failure(
          BinanceValidationError(
            'TimeInForce ${timeInForce.value} is not compatible with '
            'OrderType ${type.value}',
          ),
        );
      }
    }

    // 3. quoteOrderQty only for MARKET
    if (quoteOrderQty != null && type != OrderType.market) {
      return const Result.failure(
        BinanceValidationError(
          'quoteOrderQty is only allowed for MARKET orders',
        ),
      );
    }

    // 4. stopPrice required for STOP_LOSS/TAKE_PROFIT variants
    if (_isStopPriceRequired(type) && stopPrice == null) {
      return Result.failure(
        BinanceValidationError('stopPrice is required for $type orders'),
      );
    }

    // 5. Apply Symbol Filters
    for (final filter in symbolInfo.filters) {
      final result = _applyFilter(
        filter,
        side: side,
        type: type,
        price: price,
        quantity: quantity,
        quoteOrderQty: quoteOrderQty,
        stopPrice: stopPrice,
        avgPrice: avgPrice,
      );
      if (result.isFailure) return result;
    }

    return const Result.success(null);
  }

  static bool _isTimeInForceCompatible(OrderType type, TimeInForce tif) {
    return switch (type) {
      OrderType.limit ||
      OrderType.stopLossLimit ||
      OrderType.takeProfitLimit =>
        true,
      OrderType.market => false,
      _ => true,
    };
  }

  static bool _isStopPriceRequired(OrderType type) {
    return type == OrderType.stopLoss ||
        type == OrderType.stopLossLimit ||
        type == OrderType.takeProfit ||
        type == OrderType.takeProfitLimit;
  }

  static Result<void, BinanceValidationError> _applyFilter(
    SymbolFilter filter, {
    required Side side,
    required OrderType type,
    Price? price,
    Quantity? quantity,
    Quantity? quoteOrderQty,
    Price? stopPrice,
    Price? avgPrice,
  }) {
    return switch (filter) {
      PriceFilter() => _applyPriceFilter(filter, price ?? stopPrice),
      LotSizeFilter() => _applyLotSizeFilter(filter, quantity),
      MarketLotSizeFilter() => type == OrderType.market
          ? _applyMarketLotSizeFilter(filter, quantity)
          : const Result.success(null),
      MinNotionalFilter() => _applyMinNotionalFilter(
          filter,
          type,
          price: price,
          quantity: quantity,
          quoteOrderQty: quoteOrderQty,
        ),
      NotionalFilter() => _applyNotionalFilter(
          filter,
          type,
          price: price,
          quantity: quantity,
          quoteOrderQty: quoteOrderQty,
        ),
      PercentPriceBySideFilter() => _applyPercentPriceBySideFilter(
          filter,
          side,
          price,
          avgPrice,
        ),
      _ => const Result.success(null),
    };
  }

  static Result<void, BinanceValidationError> _applyPriceFilter(
    PriceFilter filter,
    Price? price,
  ) {
    if (price == null) return const Result.success(null);

    if (price.value < filter.minPrice.value) {
      return Result.failure(
        BinanceValidationError('Price is below minPrice ${filter.minPrice}'),
      );
    }
    if (price.value > filter.maxPrice.value) {
      return Result.failure(
        BinanceValidationError('Price is above maxPrice ${filter.maxPrice}'),
      );
    }
    if (!_isMultipleOf(price.value, filter.tickSize.value)) {
      return Result.failure(
        BinanceValidationError(
          'Price is not a multiple of tickSize ${filter.tickSize}',
        ),
      );
    }
    return const Result.success(null);
  }

  static Result<void, BinanceValidationError> _applyLotSizeFilter(
    LotSizeFilter filter,
    Quantity? quantity,
  ) {
    if (quantity == null) return const Result.success(null);

    if (quantity.value < filter.minQty.value) {
      return Result.failure(
        BinanceValidationError('Quantity is below minQty ${filter.minQty}'),
      );
    }
    if (quantity.value > filter.maxQty.value) {
      return Result.failure(
        BinanceValidationError('Quantity is above maxQty ${filter.maxQty}'),
      );
    }
    if (!_isMultipleOf(quantity.value, filter.stepSize.value)) {
      return Result.failure(
        BinanceValidationError(
          'Quantity is not a multiple of stepSize ${filter.stepSize}',
        ),
      );
    }
    return const Result.success(null);
  }

  static Result<void, BinanceValidationError> _applyMarketLotSizeFilter(
    MarketLotSizeFilter filter,
    Quantity? quantity,
  ) {
    if (quantity == null) return const Result.success(null);

    if (quantity.value < filter.minQty.value) {
      return Result.failure(
        BinanceValidationError(
          'Market quantity is below minQty ${filter.minQty}',
        ),
      );
    }
    if (quantity.value > filter.maxQty.value) {
      return Result.failure(
        BinanceValidationError(
          'Market quantity is above maxQty ${filter.maxQty}',
        ),
      );
    }
    if (!_isMultipleOf(quantity.value, filter.stepSize.value)) {
      return Result.failure(
        BinanceValidationError(
          'Market quantity is not a multiple of stepSize ${filter.stepSize}',
        ),
      );
    }
    return const Result.success(null);
  }

  static Result<void, BinanceValidationError> _applyMinNotionalFilter(
    MinNotionalFilter filter,
    OrderType type, {
    Price? price,
    Quantity? quantity,
    Quantity? quoteOrderQty,
  }) {
    if (type == OrderType.market && !filter.applyToMarket) {
      return const Result.success(null);
    }

    final notional = _calculateNotional(
      price: price,
      quantity: quantity,
      quoteOrderQty: quoteOrderQty,
    );
    if (notional == null) return const Result.success(null);

    if (notional < filter.minNotional.value) {
      return Result.failure(
        BinanceValidationError(
          'Notional $notional is below minNotional ${filter.minNotional}',
        ),
      );
    }
    return const Result.success(null);
  }

  static Result<void, BinanceValidationError> _applyNotionalFilter(
    NotionalFilter filter,
    OrderType type, {
    Price? price,
    Quantity? quantity,
    Quantity? quoteOrderQty,
  }) {
    final notional = _calculateNotional(
      price: price,
      quantity: quantity,
      quoteOrderQty: quoteOrderQty,
    );
    if (notional == null) return const Result.success(null);

    if (notional < filter.minNotional.value &&
        (type != OrderType.market || filter.applyMinToMarket)) {
      return Result.failure(
        BinanceValidationError(
          'Notional $notional is below minNotional ${filter.minNotional}',
        ),
      );
    }
    if (notional > filter.maxNotional.value &&
        (type != OrderType.market || filter.applyMaxToMarket)) {
      return Result.failure(
        BinanceValidationError(
          'Notional $notional is above maxNotional ${filter.maxNotional}',
        ),
      );
    }
    return const Result.success(null);
  }

  static Result<void, BinanceValidationError> _applyPercentPriceBySideFilter(
    PercentPriceBySideFilter filter,
    Side side,
    Price? price,
    Price? avgPrice,
  ) {
    if (price == null || avgPrice == null) return const Result.success(null);

    if (side == Side.buy) {
      final maxPrice = avgPrice.value * filter.bidMultiplierUp;
      final minPrice = avgPrice.value * filter.bidMultiplierDown;
      if (price.value > maxPrice) {
        return Result.failure(
          BinanceValidationError(
            'Price $price is above max allowed $maxPrice (BUY)',
          ),
        );
      }
      if (price.value < minPrice) {
        return Result.failure(
          BinanceValidationError(
            'Price $price is below min allowed $minPrice (BUY)',
          ),
        );
      }
    } else {
      final maxPrice = avgPrice.value * filter.askMultiplierUp;
      final minPrice = avgPrice.value * filter.askMultiplierDown;
      if (price.value > maxPrice) {
        return Result.failure(
          BinanceValidationError(
            'Price $price is above max allowed $maxPrice (SELL)',
          ),
        );
      }
      if (price.value < minPrice) {
        return Result.failure(
          BinanceValidationError(
            'Price $price is below min allowed $minPrice (SELL)',
          ),
        );
      }
    }
    return const Result.success(null);
  }

  static Decimal? _calculateNotional({
    Price? price,
    Quantity? quantity,
    Quantity? quoteOrderQty,
  }) {
    if (quoteOrderQty != null) return quoteOrderQty.value;
    if (price != null && quantity != null) return price.value * quantity.value;
    return null;
  }

  static bool _isMultipleOf(Decimal value, Decimal step) {
    if (step.units == BigInt.zero) return true;

    // Convert both to same precision
    final maxPrecision =
        value.precision > step.precision ? value.precision : step.precision;
    final valueUnits =
        value.units * BigInt.from(10).pow(maxPrecision - value.precision);
    final stepUnits =
        step.units * BigInt.from(10).pow(maxPrecision - step.precision);

    return valueUnits % stepUnits == BigInt.zero;
  }
}
