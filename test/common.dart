import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/log_type.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/defaults.dart';
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/alfred/interface/built_alfred.dart';
import 'package:alfred/alfred/interface/logging_delegate.dart';
import 'package:alfred/alfred/interface/middleware.dart';

extension AlfredTestExtension on Alfred {
  Future<BuiltAlfred> listenForTest() => build(0);
}

Future<void> runTest({
  required Future<void> Function(Alfred app, BuiltAlfred built, int port) fn,
  AlfredLoggingDelegate LOG = const AlfredLoggingDelegatePrintImpl(LogType.info),
  Middleware notFound = const NotFound404Middleware(),
}) async {
  final app = AlfredImpl(log: LOG, onNotFound: notFound);
  final built = await app.listenForTest();
  await fn(app, built, built.server.port);
  await built.close();
}
