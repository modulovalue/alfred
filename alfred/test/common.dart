import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/config.dart';
import 'package:alfred/alfred/impl/logging/log_type.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/default_404.dart';
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/alfred/interface/logging_delegate.dart';
import 'package:alfred/alfred/interface/middleware.dart';

Future<void> runTest({
  required final Future<void> Function(Alfred app, BuiltAlfred built, int port) fn,
  final AlfredLoggingDelegate LOG = const AlfredLoggingDelegatePrintImpl(LogTypeInfo()),
  final AlfredMiddleware notFound = const NotFound404Middleware(),
}) async {
  final app = makeSimpleAlfred(
    onNotFound: notFound,
  );
  final built = await app.build(
    config: const ServerConfigDefaultWithPort(
      port: 0,
    ),
    log: LOG,
  );
  await fn(app, built, built.server.port);
  await built.close();
}
