import '../../base/method.dart';
import 'middleware.dart';

/// TODO have widget style routes.
abstract class HttpRouteFactory {
  /// Create a get route.
  void get(
    final String path,
    final Middleware callback,
  );

  /// Create a post route.
  void post(
    final String path,
    final Middleware callback,
  );

  /// Create a put route.
  void put(
    final String path,
    final Middleware callback,
  );

  /// Create afinal  delete route.
  void delete(
    final String path,
    final Middleware callback,
  );

  /// Create a patch route.
  void patch(
    final String path,
    final Middleware callback,
  );

  /// Create an options route.
  void options(
    final String path,
    final Middleware callback,
  );

  /// Create a route that listens on all methods.
  void all(
    final String path,
    final Middleware callback,
  );

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying routes with [get], [post], etc.
  ///
  /// You can define middleware that effects all sub-routes.
  HttpRouteFactory route(
    final String path,
  );
}

abstract class HttpRoute {
  String get route;

  Middleware get callback;

  BuiltinMethod get method;

  /// Returns `true` if route can match multiple routes due to usage of wildcards (`*`).
  bool get usesWildcardMatcher;
}
