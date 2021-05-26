import 'package:alfred/base.dart';
import 'package:alfred/logging/interface/logging_delegate.dart';

extension AlfredTestExtension on Alfred {
  Future<int> listenForTest() async {
    await listen(0);
    return server!.port;
  }
}


Future<void> runTest({
  required Future<void> Function(Alfred app, int port) fn,
  AlfredLoggingDelegate? LOG,
}) async {
  final app = Alfred(LOG: LOG ?? Alfred.defaultLogger);
  final port = await app.listenForTest();
  await fn(app, port);
  await app.close();
}
