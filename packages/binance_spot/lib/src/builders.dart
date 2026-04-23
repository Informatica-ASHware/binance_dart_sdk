import 'package:binance_core/binance_core.dart';
import 'package:binance_spot/src/enums.dart';
import 'package:binance_spot/src/models/market_data.dart';
import 'package:binance_spot/src/validation.dart';

/// Request for a new order.
class NewOrderRequest {
  /// Creates a [NewOrderRequest].
  const NewOrderRequest({
    required this.symbol,
    required this.side,
    required this.type,
    this.timeInForce,
    this.quantity,
    this.quoteOrderQty,
    this.price,
    this.newClientOrderId,
    this.stopPrice,
    this.trailingDelta,
    this.icebergQty,
    this.newOrderRespType,
    this.selfTradePreventionMode,
    this.recvWindow,
  });

  /// The symbol.
  final Symbol symbol;

  /// The side.
  final Side side;

  /// The order type.
  final OrderType type;

  /// The time in force.
  final TimeInForce? timeInForce;

  /// The quantity.
  final Quantity? quantity;

  /// The quote order quantity.
  final Quantity? quoteOrderQty;

  /// The price.
  final Price? price;

  /// The client order ID.
  final String? newClientOrderId;

  /// The stop price.
  final Price? stopPrice;

  /// The trailing delta.
  final Price? trailingDelta;

  /// The iceberg quantity.
  final Price? icebergQty;

  /// The response type.
  final NewOrderRespType? newOrderRespType;

  /// The self-trade prevention mode.
  final SelfTradePreventionMode? selfTradePreventionMode;

  /// The receive window.
  final int? recvWindow;
}

/// Request for a new OCO order.
class OcoOrderRequest {
  /// Creates an [OcoOrderRequest].
  const OcoOrderRequest({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.price,
    required this.stopPrice,
    this.listClientOrderId,
    this.limitClientOrderId,
    this.limitIcebergQty,
    this.stopClientOrderId,
    this.stopLimitPrice,
    this.stopIcebergQty,
    this.stopLimitTimeInForce,
    this.newOrderRespType,
    this.recvWindow,
  });

  /// The symbol.
  final Symbol symbol;

  /// The side.
  final Side side;

  /// The quantity.
  final Quantity quantity;

  /// The price.
  final Price price;

  /// The stop price.
  final Price stopPrice;

  /// List client order ID.
  final String? listClientOrderId;

  /// Limit client order ID.
  final String? limitClientOrderId;

  /// Limit iceberg quantity.
  final Price? limitIcebergQty;

  /// Stop client order ID.
  final String? stopClientOrderId;

  /// Stop limit price.
  final Price? stopLimitPrice;

  /// Stop iceberg quantity.
  final Price? stopIcebergQty;

  /// Stop limit time in force.
  final TimeInForce? stopLimitTimeInForce;

  /// Response type.
  final NewOrderRespType? newOrderRespType;

  /// Receive window.
  final int? recvWindow;
}

/// Fluid builder for constructing Binance Spot orders with validation.
class SpotOrderBuilder {
  SpotOrderBuilder._({
    required Symbol symbol,
    required Side side,
    required OrderType type,
  })  : _symbol = symbol,
        _side = side,
        _type = type;

  /// Starts building a LIMIT order.
  factory SpotOrderBuilder.limit() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.limit,
      );

  /// Starts building a MARKET order.
  factory SpotOrderBuilder.market() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.market,
      );

  /// Starts building a STOP_LOSS order.
  factory SpotOrderBuilder.stopLoss() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.stopLoss,
      );

  /// Starts building a STOP_LOSS_LIMIT order.
  factory SpotOrderBuilder.stopLossLimit() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.stopLossLimit,
      );

  /// Starts building a TAKE_PROFIT order.
  factory SpotOrderBuilder.takeProfit() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.takeProfit,
      );

  /// Starts building a TAKE_PROFIT_LIMIT order.
  factory SpotOrderBuilder.takeProfitLimit() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.takeProfitLimit,
      );

  /// Starts building a LIMIT_MAKER order.
  factory SpotOrderBuilder.limitMaker() => SpotOrderBuilder._(
        symbol: const Symbol(''),
        side: Side.buy,
        type: OrderType.limitMaker,
      );

  Symbol _symbol;
  Side _side;
  final OrderType _type;
  TimeInForce? _timeInForce;
  Quantity? _quantity;
  Quantity? _quoteOrderQty;
  Price? _price;
  String? _newClientOrderId;
  Price? _stopPrice;
  Price? _trailingDelta;
  Price? _icebergQty;
  Price? _avgPrice;
  NewOrderRespType? _newOrderRespType;
  SelfTradePreventionMode? _selfTradePreventionMode;
  int? _recvWindow;

  /// Sets the symbol.
  SpotOrderBuilder symbol(Symbol symbol) {
    _symbol = symbol;
    return this;
  }

  /// Sets the side.
  SpotOrderBuilder side(Side side) {
    _side = side;
    return this;
  }

  /// Sets the quantity.
  SpotOrderBuilder quantity(Quantity quantity) {
    _quantity = quantity;
    return this;
  }

  /// Sets the quote order quantity.
  SpotOrderBuilder quoteOrderQty(Quantity quoteOrderQty) {
    _quoteOrderQty = quoteOrderQty;
    return this;
  }

  /// Sets the price.
  SpotOrderBuilder price(Price price) {
    _price = price;
    return this;
  }

  /// Sets the time in force.
  SpotOrderBuilder timeInForce(TimeInForce timeInForce) {
    _timeInForce = timeInForce;
    return this;
  }

  /// Sets the client order ID.
  SpotOrderBuilder clientOrderId(String clientOrderId) {
    _newClientOrderId = clientOrderId;
    return this;
  }

  /// Sets the stop price.
  SpotOrderBuilder stopPrice(Price stopPrice) {
    _stopPrice = stopPrice;
    return this;
  }

  /// Sets the trailing delta.
  SpotOrderBuilder trailingDelta(Price trailingDelta) {
    _trailingDelta = trailingDelta;
    return this;
  }

  /// Sets the iceberg quantity.
  SpotOrderBuilder icebergQty(Price icebergQty) {
    _icebergQty = icebergQty;
    return this;
  }

  /// Sets the average price (for PERCENT_PRICE validation).
  SpotOrderBuilder avgPrice(Price avgPrice) {
    _avgPrice = avgPrice;
    return this;
  }

  /// Sets the new order response type.
  SpotOrderBuilder responseType(NewOrderRespType responseType) {
    _newOrderRespType = responseType;
    return this;
  }

  /// Sets the self-trade prevention mode.
  SpotOrderBuilder stpMode(SelfTradePreventionMode stpMode) {
    _selfTradePreventionMode = stpMode;
    return this;
  }

  /// Sets the recvWindow.
  SpotOrderBuilder recvWindow(int recvWindow) {
    _recvWindow = recvWindow;
    return this;
  }

  /// Builds the order and validates it against the provided [symbolInfo].
  Result<NewOrderRequest, BinanceValidationError> build(SymbolInfo symbolInfo) {
    if (symbolInfo.symbol != _symbol) {
      return Result.failure(
        BinanceValidationError(
          'Symbol mismatch: builder symbol is $_symbol but SymbolInfo is for ${symbolInfo.symbol}',
        ),
      );
    }

    final validation = BinanceSpotValidator.validateOrder(
      symbolInfo: symbolInfo,
      side: _side,
      type: _type,
      timeInForce: _timeInForce,
      quantity: _quantity,
      quoteOrderQty: _quoteOrderQty,
      price: _price,
      stopPrice: _stopPrice,
      trailingDelta: _trailingDelta,
      icebergQty: _icebergQty,
      avgPrice: _avgPrice,
    );

    return validation.map(
      (_) => NewOrderRequest(
        symbol: _symbol,
        side: _side,
        type: _type,
        timeInForce: _timeInForce,
        quantity: _quantity,
        quoteOrderQty: _quoteOrderQty,
        price: _price,
        newClientOrderId: _newClientOrderId,
        stopPrice: _stopPrice,
        trailingDelta: _trailingDelta,
        icebergQty: _icebergQty,
        newOrderRespType: _newOrderRespType,
        selfTradePreventionMode: _selfTradePreventionMode,
        recvWindow: _recvWindow,
      ),
    );
  }
}

/// Fluid builder for OCO orders.
class OcoOrderBuilder {
  OcoOrderBuilder._();

  /// Starts building an OCO order.
  factory OcoOrderBuilder.oco() => OcoOrderBuilder._();

  Symbol _symbol = const Symbol('');
  Side _side = Side.buy;
  Quantity? _quantity;
  Price? _price;
  Price? _stopPrice;
  String? _listClientOrderId;
  String? _limitClientOrderId;
  Price? _limitIcebergQty;
  String? _stopClientOrderId;
  Price? _stopLimitPrice;
  Price? _stopIcebergQty;
  TimeInForce? _stopLimitTimeInForce;
  NewOrderRespType? _newOrderRespType;
  int? _recvWindow;

  /// Sets the symbol.
  OcoOrderBuilder symbol(Symbol symbol) {
    _symbol = symbol;
    return this;
  }

  /// Sets the side.
  OcoOrderBuilder side(Side side) {
    _side = side;
    return this;
  }

  /// Sets the quantity.
  OcoOrderBuilder quantity(Quantity quantity) {
    _quantity = quantity;
    return this;
  }

  /// Sets the price.
  OcoOrderBuilder price(Price price) {
    _price = price;
    return this;
  }

  /// Sets the stop price.
  OcoOrderBuilder stopPrice(Price stopPrice) {
    _stopPrice = stopPrice;
    return this;
  }

  /// Sets the list client order ID.
  OcoOrderBuilder listClientOrderId(String id) {
    _listClientOrderId = id;
    return this;
  }

  /// Sets the limit client order ID.
  OcoOrderBuilder limitClientOrderId(String id) {
    _limitClientOrderId = id;
    return this;
  }

  /// Sets the limit iceberg quantity.
  OcoOrderBuilder limitIcebergQty(Price qty) {
    _limitIcebergQty = qty;
    return this;
  }

  /// Sets the stop client order ID.
  OcoOrderBuilder stopClientOrderId(String id) {
    _stopClientOrderId = id;
    return this;
  }

  /// Sets the stop limit price.
  OcoOrderBuilder stopLimitPrice(Price price) {
    _stopLimitPrice = price;
    return this;
  }

  /// Sets the stop iceberg quantity.
  OcoOrderBuilder stopIcebergQty(Price qty) {
    _stopIcebergQty = qty;
    return this;
  }

  /// Sets the stop limit time in force.
  OcoOrderBuilder stopLimitTimeInForce(TimeInForce tif) {
    _stopLimitTimeInForce = tif;
    return this;
  }

  /// Sets the response type.
  OcoOrderBuilder responseType(NewOrderRespType type) {
    _newOrderRespType = type;
    return this;
  }

  /// Sets the receive window.
  OcoOrderBuilder recvWindow(int window) {
    _recvWindow = window;
    return this;
  }

  /// Builds the OCO order and validates it.
  Result<OcoOrderRequest, BinanceValidationError> build(SymbolInfo symbolInfo) {
    if (symbolInfo.symbol != _symbol) {
      return Result.failure(
        BinanceValidationError('Symbol mismatch for OCO'),
      );
    }
    if (!symbolInfo.ocoAllowed) {
      return Result.failure(
        BinanceValidationError(
          'OCO not allowed for symbol ${symbolInfo.symbol}',
        ),
      );
    }

    final q = _quantity;
    final p = _price;
    final sp = _stopPrice;

    if (q == null) {
      return const Result.failure(BinanceValidationError('quantity is required'));
    }
    if (p == null) {
      return const Result.failure(BinanceValidationError('price is required'));
    }
    if (sp == null) {
      return const Result.failure(BinanceValidationError('stopPrice is required'));
    }

    // Re-use validation logic for components
    final limitValidation = BinanceSpotValidator.validateOrder(
      symbolInfo: symbolInfo,
      side: _side,
      type: OrderType.limit,
      price: p,
      quantity: q,
    );

    return limitValidation.flatMap(
      (_) => Result.success(
        OcoOrderRequest(
          symbol: _symbol,
          side: _side,
          quantity: q,
          price: p,
          stopPrice: sp,
          listClientOrderId: _listClientOrderId,
          limitClientOrderId: _limitClientOrderId,
          limitIcebergQty: _limitIcebergQty,
          stopClientOrderId: _stopClientOrderId,
          stopLimitPrice: _stopLimitPrice,
          stopIcebergQty: _stopIcebergQty,
          stopLimitTimeInForce: _stopLimitTimeInForce,
          newOrderRespType: _newOrderRespType,
          recvWindow: _recvWindow,
        ),
      ),
    );
  }
}
