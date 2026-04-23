import 'package:binance_core/src/http/security.dart';
import 'package:meta/meta.dart';

/// Represents an HTTP method.
enum HttpMethod {
  /// GET method.
  get,

  /// POST method.
  post,

  /// PUT method.
  put,

  /// DELETE method.
  delete;

  @override
  String toString() => name.toUpperCase();
}

/// Represents a request to the Binance API.
@immutable
final class BinanceRequest {
  /// Creates a [BinanceRequest].
  const BinanceRequest({
    required this.method,
    required this.path,
    this.queryParams = const {},
    this.body,
    this.securityType = BinanceSecurityType.public,
    this.weight = 1,
  });

  /// The HTTP method.
  final HttpMethod method;

  /// The endpoint path (e.g., /api/v3/order).
  final String path;

  /// The query parameters.
  final Map<String, String> queryParams;

  /// The request body (typically JSON).
  final dynamic body;

  /// The security type required for this request.
  final BinanceSecurityType securityType;

  /// The estimated weight (cost) of this request.
  final int weight;

  /// Creates a builder for [BinanceRequest].
  static BinanceRequestBuilder builder() => BinanceRequestBuilder();
}

/// Builder for [BinanceRequest].
class BinanceRequestBuilder {
  HttpMethod _method = HttpMethod.get;
  String _path = '';
  final Map<String, String> _queryParams = {};
  dynamic _body;
  BinanceSecurityType _securityType = BinanceSecurityType.public;
  int _weight = 1;

  /// Sets the HTTP method.
  BinanceRequestBuilder method(HttpMethod method) {
    _method = method;
    return this;
  }

  /// Sets the endpoint path.
  BinanceRequestBuilder path(String path) {
    _path = path;
    return this;
  }

  /// Sets a query parameter.
  BinanceRequestBuilder queryParam(String key, String value) {
    _queryParams[key] = value;
    return this;
  }

  /// Sets multiple query parameters.
  BinanceRequestBuilder queryParams(Map<String, String> params) {
    _queryParams.addAll(params);
    return this;
  }

  /// Sets the request body.
  BinanceRequestBuilder body(dynamic body) {
    _body = body;
    return this;
  }

  /// Sets the security type.
  BinanceRequestBuilder securityType(BinanceSecurityType securityType) {
    _securityType = securityType;
    return this;
  }

  /// Sets the estimated weight.
  BinanceRequestBuilder weight(int weight) {
    _weight = weight;
    return this;
  }

  /// Builds the [BinanceRequest].
  BinanceRequest build() {
    return BinanceRequest(
      method: _method,
      path: _path,
      queryParams: Map.from(_queryParams),
      body: _body,
      securityType: _securityType,
      weight: _weight,
    );
  }
}
