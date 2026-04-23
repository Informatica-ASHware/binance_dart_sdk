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
  Future<Result<dynamic, BinanceError>> send(
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
        _retryPolicy = retryPolicy ?? const ExponentialBackoffRetryPolicy();

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
  Future<Result<dynamic, BinanceError>> send(
    BinanceRequest request,
  ) async {
    final chain = InterceptorChain(_interceptors);
    final currentRequest = await chain.interceptRequest(request);

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
      final ipBanEnd = _ipBanEndTime;
      if (_isIpBanned && ipBanEnd != null) {
        if (DateTime.now().isBefore(ipBanEnd)) {
          return const Result.failure(
            BinanceNetworkError(message: 'IP is currently banned by Binance'),
          );
        } else {
          _isIpBanned = false;
          _ipBanEndTime = null;
        }
      }

      Result<dynamic, BinanceError> result;
      http.Response? response;
      final startTime = DateTime.now();

      try {
        response = await _sendInternal(currentRequest);
        _rateLimitTracker.updateFromHeaders(response.headers);

        final interceptedResponse = await chain.interceptResponse(response);

        observability.telemetry.report(
          ResponseReceived(
            timestamp: DateTime.now(),
            statusCode: interceptedResponse.statusCode,
            url: interceptedResponse.request?.url ?? Uri.parse(''),
            duration: DateTime.now().difference(startTime),
          ),
        );

        if (interceptedResponse.statusCode == 200) {
          breaker.recordSuccess();
          final dynamic data = json.decode(interceptedResponse.body);
          return Result.success(data);
        }

        result = await _handleError(interceptedResponse);
      } catch (e, st) {
        await chain.interceptError(e, st);
        result = Result.failure(
          BinanceNetworkError(message: 'Network error: $e', cause: e),
        );
      }

      final error = result.fold(onSuccess: (_) => null, onFailure: (e) => e);
      if (error != null) {
        if (response?.statusCode == 418 ||
            !_retryPolicy.shouldRetry(
              attempt: attempt,
              response: response,
              error: error,
            )) {
          breaker.recordFailure();
          return result;
        }

        attempt++;
        final delay = _retryPolicy.getDelay(attempt);

        observability.telemetry.report(
          RetryAttempt(
            timestamp: DateTime.now(),
            attempt: attempt,
            url: Uri.parse(
                '${_getBaseUrl(currentRequest)}${currentRequest.path}'),
            reason: error.toString(),
          ),
        );

        await Future<void>.delayed(delay);
        continue;
      }

      return result;
    }
  }

  String _getBaseUrl(BinanceRequest request) {
    if (request.path.startsWith('/fapi') || request.path.startsWith('/dapi')) {
      return environment.futuresBaseUrl;
    } else {
      return environment.spotBaseUrl;
    }
  }

  Future<http.Response> _sendInternal(BinanceRequest request) async {
    final baseUrl = _getBaseUrl(request);
    var uri = Uri.parse('$baseUrl${request.path}');

    final queryParams = Map<String, String>.from(request.queryParams);

    if (request.securityType is SignedSecurityType) {
      final s = signer;
      if (s == null) {
        throw Exception('RequestSigner is required for signed requests');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      queryParams['timestamp'] = timestamp;

      final queryString = _buildQueryString(queryParams);

      observability.telemetry.report(
        SignatureComputed(
          timestamp: DateTime.now(),
          payload: queryString,
        ),
      );

      final signature = await s.sign(queryString);
      queryParams['signature'] = signature.value;
    }

    uri = uri.replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final headers = <String, String>{'Accept': 'application/json'};

    final creds = credentials;
    if (creds != null) {
      headers['X-MBX-APIKEY'] = creds.apiKey;
    }

    final httpRequest = http.Request(request.method.toString(), uri);
    httpRequest.headers.addAll(headers);
    if (request.body != null) {
      httpRequest.body = json.encode(request.body);
      httpRequest.headers['Content-Type'] = 'application/json';
    }

    observability.telemetry.report(
      RequestSent(
        timestamp: DateTime.now(),
        method: request.method.toString(),
        url: uri,
        weight: request.weight,
      ),
    );

    final streamedResponse = await _httpClient.send(httpRequest);
    return http.Response.fromStream(streamedResponse);
  }

  String _buildQueryString(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  Future<Result<dynamic, BinanceError>> _handleError(
    http.Response response,
  ) async {
    final statusCode = response.statusCode;

    if (statusCode == 429 || statusCode == 418) {
      final retryAfter = response.headers['retry-after'];
      final seconds = int.tryParse(retryAfter ?? '60') ?? 60;

      observability.telemetry.report(
        RateLimitHit(
          timestamp: DateTime.now(),
          limitType: statusCode == 418 ? 'IP_BAN' : 'REQUEST_WEIGHT',
          retryAfter: Duration(seconds: seconds),
        ),
      );

      if (statusCode == 418) {
        _isIpBanned = true;
        _ipBanEndTime = DateTime.now().add(Duration(seconds: seconds));
        return Result.failure(
          BinanceApiError.fromCode(
            code: -1003,
            message: 'IP Banned. Retry after $seconds seconds',
          ),
        );
      }

      return Result.failure(
        BinanceApiError.fromCode(
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
        return Result.failure(
            BinanceApiError.fromCode(code: code, message: msg));
      }
    } catch (_) {
      // Not a JSON error body
    }

    if (statusCode >= 500) {
      return Result.failure(
        BinanceHttpError(
          statusCode: statusCode,
          message: 'Server Error: ${response.body}',
        ),
      );
    }

    if (statusCode == 400 || statusCode == 401 || statusCode == 403) {
      return Result.failure(
        BinanceHttpError(
          statusCode: statusCode,
          message: 'HTTP Error $statusCode: ${response.body}',
        ),
      );
    }

    return Result.failure(
      BinanceNetworkError(message: 'HTTP error $statusCode: ${response.body}'),
    );
  }
}
