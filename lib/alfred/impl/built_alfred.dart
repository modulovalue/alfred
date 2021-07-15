import 'dart:io';

import 'package:queue/queue.dart';

import '../interface/alfred.dart';
import '../interface/logging_delegate.dart';

class BuiltAlfredImpl implements BuiltAlfred {
  @override
  final HttpServer server;
  final Queue requestQueue;
  bool closed = false;
  @override
  final ServerArguments args;

  static Future<BuiltAlfredImpl> make({
    required final ServerArguments args,
    required final AlfredLoggingDelegate log,
    required final Future<void> Function(HttpRequest request) requestHandler,
  }) async {
    final requestQueue = Queue(parallel: args.simultaneousProcessing);
    final server = await _buildHttpServer(args);
    // ignore: cancel_subscriptions, unused_local_variable
    final serverSubscription = server.listen(
      (final request) => requestQueue.add(() => requestHandler(request)),
    );
    log.onIsListening(args);
    return BuiltAlfredImpl._(
      requestQueue: requestQueue,
      server: server,
      args: args,
    );
  }

  BuiltAlfredImpl._({
    required final this.server,
    required final this.requestQueue,
    required final this.args,
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

Future<HttpServer> _buildHttpServer(
  final HttpServerArguments args,
) async =>
    await HttpServer.bind(
      args.bindIp,
      args.port,
      shared: args.shared,
    )
      ..idleTimeout = args.idleTimeout
      ..autoCompress = true;

class ServerArgumentsImpl implements ServerArguments {
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

  const ServerArgumentsImpl({
    required final this.bindIp,
    required final this.shared,
    required final this.port,
    required final this.simultaneousProcessing,
    required final this.idleTimeout,
  });
}

class ServerArgumentsDefault implements ServerArguments {
  static const String defaultBindIp = '0.0.0.0';
  static const int defaultPort = 80;
  static const int defaultSimultaneousProcessing = 50;
  static const bool defaultShared = true;
  static const Duration defaultIdleTimeout = Duration(seconds: 1);

  const ServerArgumentsDefault();

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

class ServerArgumentsDefaultWithPort implements ServerArguments {
  @override
  final int port;

  const ServerArgumentsDefaultWithPort(
    final this.port,
  );

  @override
  String get bindIp => ServerArgumentsDefault.defaultBindIp;

  @override
  bool get shared => ServerArgumentsDefault.defaultShared;

  @override
  int get simultaneousProcessing => ServerArgumentsDefault.defaultSimultaneousProcessing;

  @override
  Duration get idleTimeout => ServerArgumentsDefault.defaultIdleTimeout;
}
