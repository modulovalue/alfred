import 'dart:io';

import 'package:queue/queue.dart';

import '../interface/alfred.dart';
import '../interface/logging_delegate.dart';
import 'alfred.dart';

Future<BuiltAlfredImpl> makeAlfredImpl({
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
  return BuiltAlfredImpl(
    requestQueue: requestQueue,
    server: server,
    args: config,
    alfred: alfred,
  );
}

class BuiltAlfredImpl implements BuiltAlfred {
  final HttpServer server;
  final Queue requestQueue;
  bool closed = false;
  @override
  final ServerConfig args;
  @override
  final Alfred alfred;

  BuiltAlfredImpl({
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

class ServerConfigImpl implements ServerConfig {
  @override
  final String bindIp;
  @override
  final bool shared;
  @override
  final int port;
  @override
  final int simultaneousProcessing;
  @override
  final Duration idleTimeout;

  const ServerConfigImpl({
    required final this.bindIp,
    required final this.shared,
    required final this.port,
    required final this.simultaneousProcessing,
    required final this.idleTimeout,
  });
}

class ServerConfigDefault implements ServerConfig {
  static const String defaultBindIp = '0.0.0.0';
  static const int defaultPort = 80;
  static const int defaultSimultaneousProcessing = 50;
  static const bool defaultShared = true;
  static const Duration defaultIdleTimeout = Duration(seconds: 1);

  const ServerConfigDefault();

  @override
  String get bindIp => defaultBindIp;

  @override
  int get port => defaultPort;

  @override
  bool get shared => defaultShared;

  @override
  int get simultaneousProcessing => defaultSimultaneousProcessing;

  @override
  Duration get idleTimeout => defaultIdleTimeout;
}

class ServerConfigDefaultWithPort implements ServerConfig {
  @override
  final int port;

  const ServerConfigDefaultWithPort({
    required final this.port,
  });

  @override
  String get bindIp => ServerConfigDefault.defaultBindIp;

  @override
  bool get shared => ServerConfigDefault.defaultShared;

  @override
  int get simultaneousProcessing => ServerConfigDefault.defaultSimultaneousProcessing;

  @override
  Duration get idleTimeout => ServerConfigDefault.defaultIdleTimeout;
}
