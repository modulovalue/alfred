import 'dart:async';
import 'dart:io';

import 'http_route_factory.dart';
import 'logging_delegate.dart';

/// Server application class
///
/// This is the core of the server application. Generally you would create one
/// for each app.
abstract class Alfred implements HttpRouteFactory {
  /// List of routes.
  ///
  /// Generally you don't want to manipulate this array directly, instead add
  /// routes by calling the [get,post,put,delete] methods.
  List<HttpRoute> get routes;

  /// Call this function to fire off the server.
  /// TODO replace args with [ServerArguments].
  Future<BuiltAlfred> build({
    final AlfredLoggingDelegate log,
    final int port,
    final String bindIp,
    final bool shared,
    final int simultaneousProcessing,
  });
}

abstract class BuiltAlfred {
  /// HttpServer instance from the dart:io library
  ///
  /// If there is anything the app can't do, you can do it through here.
  HttpServer get server;

  /// Close the server and clean up any resources.
  ///
  /// Call this if you are shutting down the server
  /// but continuing to run the app.
  Future<dynamic> close({
    final bool force,
  });

  ServerArguments get args;
}

abstract class HttpServerArguments {
  Duration get idleTimeout;

  int get port;

  /// TODO consider replacing with [InternetAddress].
  String get bindIp;

  bool get shared;
}

abstract class ServerArguments implements HttpServerArguments {
  int get simultaneousProcessing;
}

/// A base exception for this package.
abstract class AlfredException implements Exception {}

abstract class AlfredResponseException implements AlfredException {
  /// The response to send to the client
  Object? get response;

  /// The statusCode to send to the client
  int get statusCode;
}

/// Error used by middleware, utils or type handler to elevate
/// a NotFound response.
abstract class AlfredNotFoundException implements AlfredException {}
