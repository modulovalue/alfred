import 'dart:async';

import 'built_alfred.dart';
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
  Future<BuiltAlfred> build([
    final int port,
    final String bindIp,
    final bool shared,
    final int simultaneousProcessing,
  ]);

  /// Writer to handle internal logging.
  AlfredLoggingDelegate get log;
}

/// A base exception for this package.
abstract class AlfredException implements Exception {
  /// The response to send to the client
  Object? get response;

  /// The statusCode to send to the client
  int get statusCode;
}

/// Error used by middleware, utils or type handler to elevate
/// a NotFound response.
abstract class NotFoundException implements Exception {}
