import 'dart:io';

import 'package:queue/queue.dart';

import '../interface/built_alfred.dart';
import '../interface/logging_delegate.dart';

class BuiltAlfredImpl implements BuiltAlfred {
  @override
  final HttpServer server;
  @override
  final int port;
  @override
  final String boundIp;
  final bool shared;
  final Queue requestQueue;
  bool closed = false;

  static Future<BuiltAlfredImpl> make({
    required final int port,
    required final String bindIp,
    required final bool shared,
    required final int simultaneousProcessing,
    required final AlfredLoggingDelegate log,
    required final Future<void> Function(HttpRequest request) requestHandler,
  }) async {
    final requestQueue = Queue(parallel: simultaneousProcessing);
    final _server = await HttpServer.bind(bindIp, port, shared: shared);
    _server.idleTimeout = const Duration(seconds: 1);
    _server.listen((request) => requestQueue.add(() => requestHandler(request)));
    log.onIsListening(_server.port);
    return BuiltAlfredImpl._(
      requestQueue: requestQueue,
      server: _server,
      port: port,
      boundIp: bindIp,
      shared: shared,
    );
  }

  BuiltAlfredImpl._({
    required final this.server,
    required final this.port,
    required final this.boundIp,
    required final this.requestQueue,
    required final this.shared,
  });

  @override
  Future<dynamic> close({
    final bool force = true,
  }) async {
    if (!closed) {
      await server.close(force: force);
      closed = true;
    } else {
      closed = false;
    }
  }
}
