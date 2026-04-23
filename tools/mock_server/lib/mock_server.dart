import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// A mock server that emulates the Binance API for testing purposes.
///
/// It supports both HTTP REST and WebSocket connections, loading
/// response data from local JSON fixtures.
class BinanceMockServer {
  /// Creates a [BinanceMockServer].
  BinanceMockServer({
    this.host = 'localhost',
    this.port = 8080,
    this.fixturesPath = 'test/fixtures',
  });

  /// The host to bind the server to.
  final String host;

  /// The port to bind the server to.
  final int port;

  /// The root path where JSON fixtures are stored.
  final String fixturesPath;

  HttpServer? _server;

  Router get _router {
    final router = Router();

    // Health check
    router.get('/ping', (Request request) {
      return Response.ok(jsonEncode({'result': 'pong'}),
          headers: {'content-type': 'application/json'});
    });

    // Mock REST API handler
    router.all('/api/<path|.*>', _handleRest);
    router.all('/fapi/<path|.*>', _handleRest);
    router.all('/sapi/<path|.*>', _handleRest);

    // Mock WebSocket handler
    router.get('/ws/<path|.*>', webSocketHandler(_handleWebSocket));
    router.get('/stream', webSocketHandler(_handleWebSocket));

    return router;
  }

  /// Starts the mock server.
  Future<void> start() async {
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_latencyMiddleware())
        .addMiddleware(_rateLimitMiddleware())
        .addHandler(_router.call);

    _server = await io.serve(handler, host, port);
    print('Binance Mock Server running on http://$host:$port');
  }

  /// Stops the mock server.
  Future<void> stop() async {
    await _server?.close();
    print('Binance Mock Server stopped');
  }

  Future<Response> _handleRest(Request request) async {
    final path = request.url.path;
    final method = request.method.toLowerCase();

    // Try to find a fixture file
    // Example: GET /api/v3/exchangeInfo -> test/fixtures/api/v3/exchangeInfo_get.json
    final fixtureFile = File('$fixturesPath/$path\_$method.json');

    if (await fixtureFile.exists()) {
      final content = await fixtureFile.readAsString();
      return Response.ok(content,
          headers: {'content-type': 'application/json'});
    }

    return Response.notFound(
        jsonEncode({
          'code': -1000,
          'msg': 'Mock not found for path: $path [$method]. '
              'Expected file: ${fixtureFile.path}'
        }),
        headers: {'content-type': 'application/json'});
  }

  void _handleWebSocket(WebSocketChannel channel) {
    channel.stream.listen((message) {
      try {
        final data = jsonDecode(message as String);
        final method = data['method'] as String?;

        if (method != null) {
          // Handle WS API methods if needed
          channel.sink.add(jsonEncode({
            'id': data['id'],
            'status': 200,
            'result': {},
          }));
        }
      } catch (_) {
        // Silently ignore malformed WS messages in mock
      }
    });
  }

  Middleware _latencyMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final latencyStr = request.url.queryParameters['simulate_latency'];
        if (latencyStr != null) {
          final ms = int.tryParse(latencyStr) ?? 0;
          await Future.delayed(Duration(milliseconds: ms));
        }
        return handler(request);
      };
    };
  }

  Middleware _rateLimitMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        final response = await handler(request);
        return response.change(headers: {
          'X-MBX-USED-WEIGHT-1M': '1',
          'X-MBX-ORDER-COUNT-1S': '0',
          'X-MBX-ORDER-COUNT-1D': '0',
        });
      };
    };
  }
}
