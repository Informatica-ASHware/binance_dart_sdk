/// Timeframe intervals aligned with Binance.
enum Interval {
  /// 1 second
  s1('1s'),

  /// 1 minute
  m1('1m'),

  /// 3 minutes
  m3('3m'),

  /// 5 minutes
  m5('5m'),

  /// 15 minutes
  m15('15m'),

  /// 30 minutes
  m30('30m'),

  /// 1 hour
  h1('1h'),

  /// 2 hours
  h2('2h'),

  /// 4 hours
  h4('4h'),

  /// 6 hours
  h6('6h'),

  /// 8 hours
  h8('8h'),

  /// 12 hours
  h12('12h'),

  /// 1 day
  d1('1d'),

  /// 3 days
  d3('3d'),

  /// 1 week
  w1('1w'),

  /// 1 month
  mo1('1M');

  const Interval(this.value);

  /// The string representation of the interval used by Binance API.
  final String value;

  @override
  String toString() => value;
}

/// Binance API environments and their base URLs.
enum BinanceEnvironment {
  /// Production environment.
  mainnet(
    spotBaseUrl: 'https://api.binance.com',
    futuresBaseUrl: 'https://fapi.binance.com',
  ),

  /// Testnet for Spot trading.
  spotTestnet(
    spotBaseUrl: 'https://testnet.binance.vision',
    futuresBaseUrl: '',
  ),

  /// Testnet for Futures trading.
  futuresTestnet(
    spotBaseUrl: '',
    futuresBaseUrl: 'https://testnet.binancefuture.com',
  );

  const BinanceEnvironment({
    required this.spotBaseUrl,
    required this.futuresBaseUrl,
  });

  /// Base URL for Spot API.
  final String spotBaseUrl;

  /// Base URL for Futures API.
  final String futuresBaseUrl;

  /// WebSocket base URL for Spot streams.
  String get spotStreamBaseUrl => switch (this) {
        BinanceEnvironment.mainnet => 'wss://stream.binance.com:9443',
        BinanceEnvironment.spotTestnet => 'wss://testnet.binance.vision',
        BinanceEnvironment.futuresTestnet => '',
      };

  /// WebSocket base URL for Futures streams.
  String get futuresStreamBaseUrl => switch (this) {
        BinanceEnvironment.mainnet => 'wss://fstream.binance.com',
        BinanceEnvironment.spotTestnet => '',
        BinanceEnvironment.futuresTestnet => 'wss://fstream.binancefuture.com',
      };

  /// WebSocket base URL for Spot API.
  String get spotWsApiBaseUrl => switch (this) {
        BinanceEnvironment.mainnet => 'wss://ws-api.binance.com/ws-api/v3',
        BinanceEnvironment.spotTestnet =>
          'wss://testnet.binance.vision/ws-api/v3',
        BinanceEnvironment.futuresTestnet => '',
      };

  /// WebSocket base URL for Futures API.
  String get futuresWsApiBaseUrl => switch (this) {
        BinanceEnvironment.mainnet => 'wss://ws-fapi.binance.com/ws-fapi/v1',
        BinanceEnvironment.spotTestnet => '',
        BinanceEnvironment.futuresTestnet =>
          'wss://testnet.binancefuture.com/ws-fapi/v1',
      };
}
