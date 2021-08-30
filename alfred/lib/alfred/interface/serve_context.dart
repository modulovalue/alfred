// TODO remove this dependency.
import 'dart:io';

import 'alfred.dart';
import 'http_route_factory.dart';

abstract class ServeContext {
  HttpRequest get req;

  HttpResponse get res;

  Alfred get alfred;

  /// Parse the body automatically and return the result.
  Future<Object?> get body;

  /// Get arguments.
  Map<String, String>? get arguments;

  /// Will not be available in 404 responses.
  HttpRoute get route;
}
