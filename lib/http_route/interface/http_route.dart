import '../../base/impl/methods.dart';
import '../../middleware/interface/middleware.dart';

abstract class HttpRoute {
  String get route;

  Middleware<Object?> get callback;

  BuiltinMethod get method;

  List<Middleware<Object?>> get middleware;

  /// Returns `true` if route can match multiple routes due to usage of wildcards (`*`)
  bool get usesWildcardMatcher;
}

abstract class HttpRouteFactory {
  /// Create a get route
  HttpRoute get(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a post route
  HttpRoute post(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a put route
  HttpRoute put(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a delete route
  HttpRoute delete(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a patch route
  HttpRoute patch(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create an options route
  HttpRoute options(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a route that listens on all methods
  HttpRoute all(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying routes with [get], [post], etc.
  ///
  /// You can define middleware that effects all sub-routes.
  HttpRouteFactory route(
    String path, {
    List<Middleware<Object?>> middleware,
  });
}
