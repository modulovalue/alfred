// TODO centralize this dependency
import 'dart:io';

import 'package:queue/queue.dart';

import '../interface/alfred.dart';
import '../interface/logging_delegate.dart';
import 'alfred.dart';

Future<BuiltAlfredIOImpl> makeAlfredImpl({
  required final ServerConfig config,
  required final AlfredLoggingDelegate log,
  required final Future<void> Function(HttpRequest request) requestHandler,
  required final AlfredImpl alfred,
}) async {
  final requestQueue = Queue(
    parallel: config.simultaneousProcessing,
  );
  final server = await HttpServer.bind(
    config.bindIp,
    config.port,
    shared: config.shared,
  )
    ..idleTimeout = config.idleTimeout
    ..autoCompress = true;
  // ignore: cancel_subscriptions, unused_local_variable
  final serverSubscription = server.listen(
    (final request) => requestQueue.add(
      () => requestHandler(request),
    ),
  );
  log.onIsListening(
    arguments: config,
  );
  return BuiltAlfredIOImpl(
    requestQueue: requestQueue,
    server: server,
    args: config,
    alfred: alfred,
  );
}

class BuiltAlfredIOImpl implements BuiltAlfred {
  final HttpServer server;
  final Queue requestQueue;
  bool closed = false;
  @override
  final ServerConfig args;
  @override
  final Alfred alfred;

  BuiltAlfredIOImpl({
    required final this.server,
    required final this.requestQueue,
    required final this.args,
    required final this.alfred,
  });

  @override
  Future<dynamic> close({
    final bool force = true,
  }) async {
    if (!closed) {
      await server.close(
        force: force,
      );
      closed = true;
    } else {
      closed = false;
    }
  }
}
