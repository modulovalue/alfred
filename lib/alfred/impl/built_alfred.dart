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
    required int port,
    required String bindIp,
    required bool shared,
    required int simultaneousProcessing,
    required AlfredLoggingDelegate log,
    required Future<void> Function(HttpRequest request) requestHandler,
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
    required this.server,
    required this.port,
    required this.boundIp,
    required this.requestQueue,
    required this.shared,
  });

  @override
  Future<dynamic> close({bool force = true}) async {
    if (!closed) {
      await server.close(force: force);
      closed = true;
    } else {
      closed = false;
    }
  }
}
