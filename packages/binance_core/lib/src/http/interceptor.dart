import 'package:binance_core/src/http/request.dart';
import 'package:http/http.dart' as http;

/// Interface for intercepting Binance API requests and responses.
abstract interface class BinanceInterceptor {
  /// Intercepts a request before it is sent.
  Future<BinanceRequest> onRequest(BinanceRequest request) async => request;

  /// Intercepts a response after it is received.
  Future<http.Response> onResponse(http.Response response) async => response;

  /// Intercepts an error.
  Future<void> onError(Object error, StackTrace stackTrace) async {}
}

/// A chain of interceptors.
class InterceptorChain {
  /// Creates an [InterceptorChain].
  InterceptorChain(this.interceptors);

  /// The list of interceptors in the chain.
  final List<BinanceInterceptor> interceptors;

  /// Executes the [onRequest] method of all interceptors in order.
  Future<BinanceRequest> interceptRequest(BinanceRequest request) async {
    var currentRequest = request;
    for (final interceptor in interceptors) {
      currentRequest = await interceptor.onRequest(currentRequest);
    }
    return currentRequest;
  }

  /// Executes the [onResponse] method of all interceptors in reverse order.
  Future<http.Response> interceptResponse(http.Response response) async {
    var currentResponse = response;
    for (final interceptor in interceptors.reversed) {
      currentResponse = await interceptor.onResponse(currentResponse);
    }
    return currentResponse;
  }

  /// Executes the [onError] method of all interceptors.
  Future<void> interceptError(Object error, StackTrace stackTrace) async {
    for (final interceptor in interceptors) {
      await interceptor.onError(error, stackTrace);
    }
  }
}
