import 'dart:async';
import 'package:binance_core/src/auth.dart';
import 'package:binance_core/src/http/client.dart';
import 'package:binance_core/src/http/request.dart';
import 'package:binance_core/src/http/security.dart';
import 'package:binance_core/src/models.dart';
import 'package:binance_core/src/ws/api_client.dart';
import 'package:binance_core/src/ws/stream_client.dart';
import 'package:meta/meta.dart';

/// Status of the [UserDataFeed].
@immutable
sealed class UserDataFeedStatus {
  /// Base constructor for [UserDataFeedStatus].
  const UserDataFeedStatus();

  /// Connected to the stream and receiving events.
  const factory UserDataFeedStatus.connected() = UserDataFeedConnected;

  /// Connection lost, attempting to reconnect.
  const factory UserDataFeedStatus.reconnecting() = UserDataFeedReconnecting;

  /// Authentication failed (e.g., invalid credentials or session expired).
  const factory UserDataFeedStatus.authFailed([String? reason]) =
      UserDataFeedAuthFailed;

  /// The listenKey or session has expired.
  const factory UserDataFeedStatus.expired() = UserDataFeedExpired;

  /// Reconnected after a period of disconnection.
  ///
  /// Signals that the consumer should perform a snapshot reconciliation.
  const factory UserDataFeedStatus.reconnectedAfterGap(Duration gap) =
      UserDataFeedReconnectedAfterGap;
}

/// Feed is connected and active.
final class UserDataFeedConnected extends UserDataFeedStatus {
  /// Creates a [UserDataFeedConnected] status.
  const UserDataFeedConnected();
}

/// Feed is attempting to reconnect.
final class UserDataFeedReconnecting extends UserDataFeedStatus {
  /// Creates a [UserDataFeedReconnecting] status.
  const UserDataFeedReconnecting();
}

/// Authentication for the feed failed.
final class UserDataFeedAuthFailed extends UserDataFeedStatus {
  /// Creates a [UserDataFeedAuthFailed] status.
  const UserDataFeedAuthFailed([this.reason]);

  /// The reason for the authentication failure.
  final String? reason;
}

/// The feed has expired.
final class UserDataFeedExpired extends UserDataFeedStatus {
  /// Creates a [UserDataFeedExpired] status.
  const UserDataFeedExpired();
}

/// Feed reconnected after a gap in events.
final class UserDataFeedReconnectedAfterGap extends UserDataFeedStatus {
  /// Creates a [UserDataFeedReconnectedAfterGap] status.
  const UserDataFeedReconnectedAfterGap(this.gap);

  /// The duration of the gap.
  final Duration gap;
}

/// Unified event from the User Data Stream.
@immutable
sealed class UserDataEvent {
  /// Base constructor for [UserDataEvent].
  const UserDataEvent();
}

/// Event triggered when account information is updated.
final class AccountUpdate extends UserDataEvent {
  /// Creates an [AccountUpdate] event.
  const AccountUpdate({
    required this.updateTime,
    required this.balances,
  });

  /// The time the update occurred.
  final DateTime updateTime;

  /// The updated balances.
  final List<AccountBalance> balances;
}

/// Simplified balance update event.
final class BalanceUpdate extends UserDataEvent {
  /// Creates a [BalanceUpdate] event.
  const BalanceUpdate({
    required this.asset,
    required this.balanceDelta,
    required this.clearTime,
  });

  /// The asset that was updated.
  final Asset asset;

  /// The change in balance.
  final Decimal balanceDelta;

  /// The time the update was cleared.
  final DateTime clearTime;
}

/// Event triggered when an order status changes or a trade occurs.
final class OrderTradeUpdate extends UserDataEvent {
  /// Creates an [OrderTradeUpdate] event.
  const OrderTradeUpdate({
    required this.symbol,
    required this.orderId,
    required this.clientOrderId,
    required this.side,
    required this.orderType,
    required this.status,
    required this.price,
    required this.quantity,
    required this.lastFilledQuantity,
    required this.cumulativeFilledQuantity,
    required this.lastFilledPrice,
    required this.transactionTime,
    this.tradeId,
  });

  /// The symbol associated with the order.
  final Symbol symbol;

  /// The system-generated order ID.
  final OrderId orderId;

  /// The client-defined order ID.
  final ClientOrderId clientOrderId;

  /// The order side (e.g., BUY, SELL).
  final String side;

  /// The order type (e.g., LIMIT, MARKET).
  final String orderType;

  /// The current status of the order.
  final String status;

  /// The price of the order.
  final Decimal price;

  /// The original quantity of the order.
  final Decimal quantity;

  /// The quantity of the last fill.
  final Decimal lastFilledQuantity;

  /// The cumulative filled quantity.
  final Decimal cumulativeFilledQuantity;

  /// The price of the last fill.
  final Decimal lastFilledPrice;

  /// The time of the transaction.
  final DateTime transactionTime;

  /// The ID of the trade, if applicable.
  final int? tradeId;
}

/// Event triggered when the listenKey expires.
final class ListenKeyExpired extends UserDataEvent {
  /// Creates a [ListenKeyExpired] event.
  const ListenKeyExpired();
}

/// Event triggered by a margin call (Futures only).
final class MarginCall extends UserDataEvent {
  /// Creates a [MarginCall] event.
  const MarginCall({
    required this.positions,
  });

  /// The positions affected by the margin call.
  final List<MarginCallPosition> positions;
}

/// Event triggered when account configuration changes.
final class AccountConfigUpdate extends UserDataEvent {
  /// Creates an [AccountConfigUpdate] event.
  const AccountConfigUpdate({
    required this.eventTime,
  });

  /// The time the event occurred.
  final DateTime eventTime;
}

/// Event triggered when leverage changes.
final class LeverageUpdate extends UserDataEvent {
  /// Creates a [LeverageUpdate] event.
  const LeverageUpdate({
    required this.symbol,
    required this.leverage,
  });

  /// The symbol whose leverage was updated.
  final Symbol symbol;

  /// The new leverage value.
  final int leverage;
}

/// Event triggered when isolated position status changes.
final class IsolatedPositionUpdate extends UserDataEvent {
  /// Creates an [IsolatedPositionUpdate] event.
  const IsolatedPositionUpdate();
}

/// Represents a balance in an account.
@immutable
final class AccountBalance {
  /// Creates an [AccountBalance].
  const AccountBalance({
    required this.asset,
    required this.free,
    required this.locked,
  });

  /// The asset associated with this balance.
  final Asset asset;

  /// The amount of free (available) asset.
  final Decimal free;

  /// The amount of locked asset.
  final Decimal locked;
}

/// Represents a position in a margin call.
@immutable
final class MarginCallPosition {
  /// Creates a [MarginCallPosition].
  const MarginCallPosition({
    required this.symbol,
    required this.positionSide,
    required this.markPrice,
    required this.isolatedWallet,
  });

  /// The symbol of the position.
  final Symbol symbol;

  /// The side of the position (e.g., LONG, SHORT).
  final String positionSide;

  /// The current mark price.
  final Decimal markPrice;

  /// The amount in the isolated wallet.
  final Decimal isolatedWallet;
}

/// Binance trading venues.
enum BinanceVenue {
  /// Spot trading.
  spot,

  /// Cross Margin trading.
  margin,

  /// Isolated Margin trading.
  isolatedMargin,

  /// USD-M Futures trading.
  usdMFutures,

  /// COIN-M Futures trading.
  coinMFutures;

  /// Whether this venue uses the WS API mechanism (post 2026-02-20).
  bool get usesWsApi =>
      this == BinanceVenue.spot ||
      this == BinanceVenue.margin ||
      this == BinanceVenue.isolatedMargin;

  /// Whether this venue uses the classic listenKey mechanism.
  bool get usesListenKey =>
      this == BinanceVenue.usdMFutures || this == BinanceVenue.coinMFutures;
}

/// Unified API for User Data Streams.
abstract interface class UserDataFeed {
  /// Stream of unified typed events.
  Stream<UserDataEvent> get events;

  /// Current status of the feed.
  Stream<UserDataFeedStatus> get status;

  /// Starts the feed, choosing the correct mechanism for the venue.
  Future<void> start();

  /// Stops the feed and releases resources.
  Future<void> stop();

  /// Factory method to create the appropriate [UserDataFeed] for the venue.
  factory UserDataFeed.create({
    required BinanceVenue venue,
    required BinanceHttpClient httpClient,
    required WebSocketApiClient apiClient,
    required WebSocketStreamClient streamClient,
    required BinanceCredentials credentials,
  }) {
    if (venue.usesWsApi) {
      return SpotUserDataFeed(
        apiClient: apiClient,
        credentials: credentials,
        venue: venue,
      );
    } else {
      return FuturesUserDataFeed(
        httpClient: httpClient,
        streamClient: streamClient,
        venue: venue,
      );
    }
  }
}

/// Base class for UserDataFeed implementations.
abstract class BaseUserDataFeed implements UserDataFeed {
  /// Base constructor for [BaseUserDataFeed].
  BaseUserDataFeed() {
    _statusController = StreamController<UserDataFeedStatus>.broadcast();
    _eventsController = StreamController<UserDataEvent>.broadcast();
  }

  late final StreamController<UserDataFeedStatus> _statusController;
  late final StreamController<UserDataEvent> _eventsController;

  @override
  Stream<UserDataEvent> get events => _eventsController.stream;

  @override
  Stream<UserDataFeedStatus> get status => _statusController.stream;

  /// Emits a new status.
  @protected
  void emitStatus(UserDataFeedStatus status) {
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  /// Emits a new event.
  @protected
  void emitEvent(UserDataEvent event) {
    if (!_eventsController.isClosed) {
      _eventsController.add(event);
    }
  }

  @override
  @mustCallSuper
  Future<void> stop() async {
    await _statusController.close();
    await _eventsController.close();
  }
}

/// Implementation of [UserDataFeed] for Spot and Margin using the WS API.
class SpotUserDataFeed extends BaseUserDataFeed {
  /// Creates a [SpotUserDataFeed].
  SpotUserDataFeed({
    required WebSocketApiClient apiClient,
    required BinanceCredentials credentials,
    BinanceVenue venue = BinanceVenue.spot,
  })  : _apiClient = apiClient,
        _credentials = credentials,
        _venue = venue;

  final WebSocketApiClient _apiClient;
  final BinanceCredentials _credentials;
  final BinanceVenue _venue;
  bool _isStarted = false;
  StreamSubscription<dynamic>? _apiEventsSubscription;
  StreamSubscription<WebSocketApiClientStatus>? _statusSubscription;
  DateTime? _lastDisconnectTime;

  @override
  Future<void> start() async {
    if (_isStarted) return;
    _isStarted = true;

    _statusSubscription = _apiClient.status.listen(_handleApiClientStatus);

    try {
      await _apiClient.connect();
      await _apiClient.logon(_credentials);
      await _subscribe();
    } catch (e) {
      emitStatus(UserDataFeedStatus.authFailed(e.toString()));
      rethrow;
    }
  }

  Future<void> _subscribe() async {
    final method = switch (_venue) {
      BinanceVenue.spot => 'userDataStream.subscribe',
      BinanceVenue.margin => 'marginUserDataStream.subscribe',
      BinanceVenue.isolatedMargin => 'isolatedMarginUserDataStream.subscribe',
      _ =>
        throw ArgumentError('Unsupported venue for SpotUserDataFeed: $_venue'),
    };

    final response =
        await _apiClient.sendRequest(method) as Map<String, dynamic>;
    if (response['status'] == 200) {
      await _apiEventsSubscription?.cancel();
      _apiEventsSubscription = _apiClient.events.listen(_handleApiEvent);
      emitStatus(const UserDataFeedStatus.connected());

      if (_lastDisconnectTime != null) {
        final gap = DateTime.now().difference(_lastDisconnectTime!);
        emitStatus(UserDataFeedStatus.reconnectedAfterGap(gap));
        _lastDisconnectTime = null;
      }
    } else {
      emitStatus(UserDataFeedStatus.authFailed(response['error']?.toString()));
    }
  }

  void _handleApiClientStatus(WebSocketApiClientStatus apiClientStatus) {
    switch (apiClientStatus) {
      case WebSocketApiClientStatus.connecting:
      case WebSocketApiClientStatus.reconnecting:
        emitStatus(const UserDataFeedStatus.reconnecting());
        break;
      case WebSocketApiClientStatus.disconnected:
        _lastDisconnectTime ??= DateTime.now();
        emitStatus(const UserDataFeedStatus.reconnecting());
        break;
      case WebSocketApiClientStatus.authenticated:
        unawaited(_subscribe());
        break;
      case WebSocketApiClientStatus.connected:
        // Wait for authentication
        break;
    }
  }

  @override
  Future<void> stop() async {
    if (!_isStarted) return;
    _isStarted = false;
    await _statusSubscription?.cancel();
    await _apiEventsSubscription?.cancel();
    await _apiClient.logout();
    await super.stop();
  }

  void _handleApiEvent(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    if (map['e'] == 'eventStreamTerminated') {
      _handleTermination();
      return;
    }

    final eventType = map['e'] as String?;
    if (eventType == null) return;

    final event = _parseEvent(map);
    if (event != null) {
      emitEvent(event);
    }
  }

  UserDataEvent? _parseEvent(Map<String, dynamic> data) {
    final eventType = data['e'] as String;

    return switch (eventType) {
      'outboundAccountPosition' => AccountUpdate(
          updateTime: DateTime.fromMillisecondsSinceEpoch(data['u'] as int),
          balances: (data['B'] as List)
              .map(
                (b) => AccountBalance(
                  asset: Asset((b as Map)['a'] as String),
                  free: Decimal.parse(b['f'] as String),
                  locked: Decimal.parse(b['l'] as String),
                ),
              )
              .toList(),
        ),
      'balanceUpdate' => BalanceUpdate(
          asset: Asset(data['a'] as String),
          balanceDelta: Decimal.parse(data['d'] as String),
          clearTime: DateTime.fromMillisecondsSinceEpoch(data['T'] as int),
        ),
      'executionReport' => OrderTradeUpdate(
          symbol: Symbol(data['s'] as String),
          orderId: OrderId(data['i'] as int),
          clientOrderId: ClientOrderId(data['c'] as String),
          side: data['S'] as String,
          orderType: data['o'] as String,
          status: data['X'] as String,
          price: Decimal.parse(data['p'] as String),
          quantity: Decimal.parse(data['q'] as String),
          lastFilledQuantity: Decimal.parse(data['l'] as String),
          cumulativeFilledQuantity: Decimal.parse(data['z'] as String),
          lastFilledPrice: Decimal.parse(data['L'] as String),
          transactionTime:
              DateTime.fromMillisecondsSinceEpoch(data['T'] as int),
          tradeId: data['t'] as int?,
        ),
      'listenKeyExpired' => const ListenKeyExpired(),
      _ => null,
    };
  }

  void _handleTermination() {
    emitStatus(const UserDataFeedStatus.authFailed('eventStreamTerminated'));
  }
}

/// Implementation of [UserDataFeed] for Futures using the classic listenKey
/// mechanism.
class FuturesUserDataFeed extends BaseUserDataFeed {
  /// Creates a [FuturesUserDataFeed].
  FuturesUserDataFeed({
    required BinanceHttpClient httpClient,
    required WebSocketStreamClient streamClient,
    BinanceVenue venue = BinanceVenue.usdMFutures,
    this.keepAliveInterval = const Duration(minutes: 30),
  })  : _httpClient = httpClient,
        _streamClient = streamClient,
        _venue = venue;

  final BinanceHttpClient _httpClient;
  final WebSocketStreamClient _streamClient;
  final BinanceVenue _venue;

  /// Interval for keeping the listenKey alive.
  final Duration keepAliveInterval;

  String? _listenKey;
  Timer? _keepAliveTimer;
  StreamSubscription<dynamic>? _streamSubscription;
  DateTime? _lastDisconnectTime;

  @override
  Future<void> start() async {
    if (_listenKey != null) return;

    try {
      emitStatus(const UserDataFeedStatus.reconnecting());
      _listenKey = await _obtainListenKey();
      _startKeepAlive();
      _connectToStream();
    } catch (e) {
      emitStatus(UserDataFeedStatus.authFailed(e.toString()));
      rethrow;
    }
  }

  Future<String> _obtainListenKey() async {
    final path = switch (_venue) {
      BinanceVenue.usdMFutures => '/fapi/v1/listenKey',
      BinanceVenue.coinMFutures => '/dapi/v1/listenKey',
      _ => throw ArgumentError(
          'Unsupported venue for FuturesUserDataFeed: $_venue',
        ),
    };

    final result = await _httpClient.send(
      BinanceRequest(
        method: HttpMethod.post,
        path: path,
        securityType: BinanceSecurityType.userData,
      ),
    );

    return result.fold(
      onSuccess: (data) => data['listenKey'] as String,
      onFailure: (error) =>
          throw Exception('Failed to obtain listenKey: $error'),
    );
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(keepAliveInterval, (_) async {
      if (_listenKey == null) return;

      final path = switch (_venue) {
        BinanceVenue.usdMFutures => '/fapi/v1/listenKey',
        BinanceVenue.coinMFutures => '/dapi/v1/listenKey',
        _ => throw ArgumentError('Unsupported venue for keep-alive: $_venue'),
      };

      await _httpClient.send(
        BinanceRequest(
          method: HttpMethod.put,
          path: path,
          queryParams: {'listenKey': _listenKey!},
          securityType: BinanceSecurityType.userData,
        ),
      );
    });
  }

  void _connectToStream() {
    _streamSubscription?.cancel();
    _streamSubscription = _streamClient.subscribe(_listenKey!).listen(
          _handleStreamData,
          onError: _handleStreamError,
          onDone: _handleStreamDone,
        );
    emitStatus(const UserDataFeedStatus.connected());

    if (_lastDisconnectTime != null) {
      final gap = DateTime.now().difference(_lastDisconnectTime!);
      emitStatus(UserDataFeedStatus.reconnectedAfterGap(gap));
      _lastDisconnectTime = null;
    }
  }

  void _handleStreamData(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    if (map['e'] == 'eventStreamTerminated') {
      _handleTermination();
      return;
    }

    final eventType = map['e'] as String?;
    if (eventType == null) return;

    final event = _parseEvent(map);
    if (event != null) {
      emitEvent(event);
      if (event is ListenKeyExpired) {
        _handleListenKeyExpired();
      }
    }
  }

  void _handleTermination() {
    emitStatus(const UserDataFeedStatus.authFailed('eventStreamTerminated'));
  }

  void _handleStreamError(dynamic error) {
    _lastDisconnectTime = DateTime.now();
    emitStatus(const UserDataFeedStatus.reconnecting());
  }

  void _handleStreamDone() {
    _lastDisconnectTime = DateTime.now();
    emitStatus(const UserDataFeedStatus.reconnecting());
  }

  Future<void> _handleListenKeyExpired() async {
    emitStatus(const UserDataFeedStatus.expired());
    _listenKey = null;
    await start();
  }

  UserDataEvent? _parseEvent(Map<String, dynamic> data) {
    final eventType = data['e'] as String;

    return switch (eventType) {
      'ACCOUNT_UPDATE' => AccountUpdate(
          updateTime: DateTime.fromMillisecondsSinceEpoch(data['E'] as int),
          balances: ((data['a'] as Map)['B'] as List)
              .map(
                (b) => AccountBalance(
                  asset: Asset((b as Map)['a'] as String),
                  free: Decimal.parse(b['wb'] as String),
                  locked: Decimal.zero, // Futures doesn't have locked per se here
                ),
              )
              .toList(),
        ),
      'ORDER_TRADE_UPDATE' => OrderTradeUpdate(
          symbol: Symbol((data['o'] as Map)['s'] as String),
          orderId: OrderId((data['o'] as Map)['i'] as int),
          clientOrderId: ClientOrderId((data['o'] as Map)['c'] as String),
          side: (data['o'] as Map)['S'] as String,
          orderType: (data['o'] as Map)['o'] as String,
          status: (data['o'] as Map)['X'] as String,
          price: Decimal.parse((data['o'] as Map)['p'] as String),
          quantity: Decimal.parse((data['o'] as Map)['q'] as String),
          lastFilledQuantity: Decimal.parse((data['o'] as Map)['l'] as String),
          cumulativeFilledQuantity:
              Decimal.parse((data['o'] as Map)['z'] as String),
          lastFilledPrice: Decimal.parse((data['o'] as Map)['L'] as String),
          transactionTime:
              DateTime.fromMillisecondsSinceEpoch(data['T'] as int),
          tradeId: (data['o'] as Map)['t'] as int?,
        ),
      'listenKeyExpired' => const ListenKeyExpired(),
      'LEVERAGE_UPDATE' => LeverageUpdate(
          symbol: Symbol((data['ac'] as Map<dynamic, dynamic>)['s'] as String),
          leverage: (data['ac'] as Map<dynamic, dynamic>)['l'] as int,
        ),
      'MARGIN_CALL' => MarginCall(
          positions: (data['p'] as List)
              .map(
                (p) => MarginCallPosition(
                  symbol: Symbol((p as Map)['s'] as String),
                  positionSide: p['ps'] as String,
                  markPrice: Decimal.parse(p['mp'] as String),
                  isolatedWallet: Decimal.parse(p['iw'] as String),
                ),
              )
              .toList(),
        ),
      'ACCOUNT_CONFIG_UPDATE' => AccountConfigUpdate(
          eventTime: DateTime.fromMillisecondsSinceEpoch(data['E'] as int),
        ),
      'CONDITIONAL_ORDER_TRIGGER_REJECT' => const IsolatedPositionUpdate(),
      _ => null,
    };
  }

  @override
  Future<void> stop() async {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;

    if (_listenKey != null) {
      final path = switch (_venue) {
        BinanceVenue.usdMFutures => '/fapi/v1/listenKey',
        BinanceVenue.coinMFutures => '/dapi/v1/listenKey',
        _ => null,
      };

      if (path != null) {
        unawaited(
          _httpClient.send(
            BinanceRequest(
              method: HttpMethod.delete,
              path: path,
              queryParams: {'listenKey': _listenKey!},
              securityType: BinanceSecurityType.userData,
            ),
          ),
        );
      }
      _listenKey = null;
    }

    await _streamSubscription?.cancel();
    await super.stop();
  }
}
