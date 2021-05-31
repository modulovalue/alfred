import '../../base/method.dart';
import 'middleware.dart';

/// TODO have widget style routes.
abstract class HttpRouteFactory {
  /// Create a get route.
  void get(String path, Middleware callback);

  /// Create a post route.
  void post(String path, Middleware callback);

  /// Create a put route.
  void put(String path, Middleware callback);

  /// Create a delete route.
  void delete(String path, Middleware callback);

  /// Create a patch route.
  void patch(String path, Middleware callback);

  /// Create an options route.
  void options(String path, Middleware callback);

  /// Create a route that listens on all methods.
  void all(String path, Middleware callback);

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying routes with [get], [post], etc.
  ///
  /// You can define middleware that effects all sub-routes.
  HttpRouteFactory route(String path);
}

abstract class HttpRoute {
  String get route;

  Middleware get callback;

  BuiltinMethod get method;

  /// Returns `true` if route can match multiple routes due to usage of wildcards (`*`)
  bool get usesWildcardMatcher;
}
