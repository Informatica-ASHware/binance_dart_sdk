import 'dart:io';
import 'package:binance_mock_server/mock_server.dart';

void main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8080 : 8080;
  final server = BinanceMockServer(port: port);

  await server.start();

  ProcessSignal.sigint.watch().listen((_) async {
    await server.stop();
    exit(0);
  });

  ProcessSignal.sigterm.watch().listen((_) async {
    await server.stop();
    exit(0);
  });
}
