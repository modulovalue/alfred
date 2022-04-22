import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:alfred/alfred/middleware/default_404.dart';

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
