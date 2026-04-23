import 'dart:async';
import 'dart:convert';

import 'package:binance_core/src/auth.dart';
import 'package:binance_core/src/enums.dart';
import 'package:binance_core/src/error.dart';
import 'package:binance_core/src/http/circuit_breaker.dart';
import 'package:binance_core/src/http/interceptor.dart';
import 'package:binance_core/src/http/rate_limit.dart';
import 'package:binance_core/src/http/request.dart';
import 'package:binance_core/src/http/retry.dart';
import 'package:binance_core/src/http/security.dart';
import 'package:binance_core/src/observability.dart';
import 'package:binance_core/src/result.dart';
import 'package:http/http.dart' as http;

/// Abstract client for interacting with the Binance HTTP API.
abstract interface class BinanceHttpClient {
  /// Sends a [BinanceRequest] and returns a [Result].
  Future<Result<Map<String, dynamic>, BinanceError>> send(
    BinanceRequest request,
  );

  /// Adds an interceptor to the client.
  void addInterceptor(BinanceInterceptor interceptor);
}

/// Default implementation of [BinanceHttpClient].
class DefaultBinanceHttpClient implements BinanceHttpClient {
  /// Creates a [DefaultBinanceHttpClient].
  DefaultBinanceHttpClient({
    required this.environment,
    this.credentials,
    this.signer,
    this.observability = const BinanceObservabilityHooks(),
    http.Client? httpClient,
    RateLimitTracker? rateLimitTracker,
    CircuitBreakerRegistry? circuitBreakers,
    RetryPolicy? retryPolicy,
  })  : _httpClient = httpClient ?? http.Client(),
        _rateLimitTracker = rateLimitTracker ?? RateLimitTracker(),
        _circuitBreakers = circuitBreakers ?? CircuitBreakerRegistry(),
        _retryPolicy = retryPolicy ?? ExponentialBackoffRetryPolicy();

  /// The Binance environment.
  final BinanceEnvironment environment;

  /// The credentials for signing requests.
  final BinanceCredentials? credentials;

  /// The signer for requests.
  final RequestSigner? signer;

  /// Observability hooks.
  final BinanceObservabilityHooks observability;

  final http.Client _httpClient;
  final RateLimitTracker _rateLimitTracker;
  final CircuitBreakerRegistry _circuitBreakers;
  final RetryPolicy _retryPolicy;
  final List<BinanceInterceptor> _interceptors = [];

  bool _isIpBanned = false;
  DateTime? _ipBanEndTime;

  @override
  void addInterceptor(BinanceInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  @override
  Future<Result<Map<String, dynamic>, BinanceError>> send(
    BinanceRequest request,
  ) async {
    if (_isIpBanned && _ipBanEndTime != null) {
      if (DateTime.now().isBefore(_ipBanEndTime!)) {
        return const Result.failure(
          BinanceNetworkError(message: 'IP is currently banned by Binance'),
        );
      } else {
        _isIpBanned = false;
        _ipBanEndTime = null;
      }
    }

    final chain = InterceptorChain(_interceptors);
    var currentRequest = await chain.interceptRequest(request);

    final breaker = _circuitBreakers.getBreaker(currentRequest.path);
    if (breaker.isOpen) {
      return Result.failure(
        BinanceNetworkError(
          message: 'Circuit breaker open for ${currentRequest.path}',
        ),
      );
    }

    await _rateLimitTracker.waitIfNecessary(currentRequest.weight);

    var attempt = 0;
    while (true) {
      Result<Map<String, dynamic>, BinanceError>? result;
      http.Response? response;

      try {
        response = await _sendInternal(currentRequest);
        _rateLimitTracker.updateFromHeaders(response.headers);

        final interceptedResponse = await chain.interceptResponse(response);

        if (interceptedResponse.statusCode == 200) {
          breaker.recordSuccess();
          final data =
              json.decode(interceptedResponse.body) as Map<String, dynamic>;
          return Result.success(data);
        }

        // Handle errors
        result = await _handleError(interceptedResponse);
      } catch (e, st) {
        await chain.interceptError(e, st);
        result = Result.failure(
          BinanceNetworkError(message: 'Network error: $e', cause: e),
        );
      }

      if (result != null &&
          result is Failure<Map<String, dynamic>, BinanceError>) {
        final error = result.error;

        // Check if we should retry
        if (_retryPolicy.shouldRetry(
          response: response,
          error: error,
          attempt: attempt,
        )) {
          attempt++;
          final delay = _retryPolicy.getDelay(attempt);
          await Future<void>.delayed(delay);
          continue;
        }

        // Handle terminal errors
        breaker.recordFailure();
        return result;
      }

      if (result != null) return result;

      // Should not reach here
      return const Result.failure(
        BinanceNetworkError(message: 'Unknown error occurred'),
      );
    }
  }

  Future<http.Response> _sendInternal(BinanceRequest request) async {
    // More robust venue detection
    final String baseUrl;
    if (request.path.startsWith('/fapi') || request.path.startsWith('/dapi')) {
      baseUrl = environment.futuresBaseUrl;
    } else {
      baseUrl = environment.spotBaseUrl;
    }

    var uri = Uri.parse('$baseUrl${request.path}');

    final queryParams = Map<String, String>.from(request.queryParams);

    if (request.securityType is SignedSecurityType) {
      if (signer == null) {
        throw const BinanceAuthError(
            'RequestSigner is required for signed requests');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      queryParams['timestamp'] = timestamp;

      final queryString = _buildQueryString(queryParams);
      final signature = await signer!.sign(queryString);
      queryParams['signature'] = signature.value;
    }

    uri = uri.replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (credentials != null) {
      headers['X-MBX-APIKEY'] = credentials!.apiKey;
    }

    final httpRequest = http.Request(request.method.toString(), uri);
    httpRequest.headers.addAll(headers);
    if (request.body != null) {
      httpRequest.body = json.encode(request.body);
      httpRequest.headers['Content-Type'] = 'application/json';
    }

    final streamedResponse = await _httpClient.send(httpRequest);
    return http.Response.fromStream(streamedResponse);
  }

  String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  Future<Result<Map<String, dynamic>, BinanceError>> _handleError(
    http.Response response,
  ) async {
    final statusCode = response.statusCode;

    if (statusCode == 429 || statusCode == 418) {
      final retryAfter = response.headers['retry-after'];
      final seconds = int.tryParse(retryAfter ?? '60') ?? 60;

      if (statusCode == 418) {
        _isIpBanned = true;
        _ipBanEndTime = DateTime.now().add(Duration(seconds: seconds));
        return Result.failure(
          BinanceApiError(
            code: -1003,
            message: 'IP Banned. Retry after $seconds seconds',
          ),
        );
      }

      return Result.failure(
        BinanceApiError(
          code: -1003,
          message: 'Too many requests. Retry after $seconds seconds',
        ),
      );
    }

    try {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final code = data['code'] as int?;
      final msg = data['msg'] as String?;

      if (code != null && msg != null) {
        return Result.failure(BinanceApiError(code: code, message: msg));
      }
    } catch (_) {
      // Not a JSON error body
    }

    return Result.failure(
      BinanceNetworkError(
        message: 'HTTP error $statusCode: ${response.body}',
      ),
    );
  }
}
