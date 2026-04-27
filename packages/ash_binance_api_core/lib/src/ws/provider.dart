import 'package:ash_binance_api_core/src/ws/base.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Default implementation of [BinanceWebSocketProvider] using
/// `web_socket_channel`.
class DefaultBinanceWebSocketProvider implements BinanceWebSocketProvider {
  /// Creates a [DefaultBinanceWebSocketProvider].
  const DefaultBinanceWebSocketProvider();

  @override
  Future<BinanceWebSocketChannel> connect(Uri url) async {
    final channel = WebSocketChannel.connect(url);
    await channel.ready;
    return _BinanceWebSocketChannel(channel);
  }
}

class _BinanceWebSocketChannel implements BinanceWebSocketChannel {
  _BinanceWebSocketChannel(this._channel);

  final WebSocketChannel _channel;

  @override
  Stream<dynamic> get stream => _channel.stream;

  @override
  Sink<dynamic> get sink => _channel.sink;

  @override
  Future<void> close([int? closeCode, String? closeReason]) {
    return _channel.sink.close(closeCode, closeReason);
  }
}
