import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/logging/interface/logging_delegate.dart';
import 'package:alfred/middleware/interface/middleware.dart';

extension AlfredTestExtension on Alfred {
  Future<int> listenForTest() async {
    await listen(0);
    return server!.port;
  }
}

Future<void> runTest({
  required Future<void> Function(Alfred app, int port) fn,
  AlfredLoggingDelegate? LOG,
  Middleware<Object?>? notFound,
}) async {
  final app = AlfredImpl(
    log: LOG ?? AlfredImpl.defaultLogger,
    onNotFound: notFound,
  );
  final port = await app.listenForTest();
  await fn(app, port);
  await app.close();
}
