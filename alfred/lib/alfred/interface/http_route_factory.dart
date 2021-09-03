import '../../base/method.dart';
import 'middleware.dart';

abstract class HttpRouteFactory {
  /// Adds a [Routed] route.
  void add({
    required final Routed routes,
  });

  /// As a common base for specifying further
  /// routes.
  HttpRouteFactory at({
    required final String path,
  });
}

abstract class HttpRouteDirections {
  String get path;

  BuiltinMethod get method;
}

abstract class HttpRoute implements HttpRouteDirections{
  Middleware get middleware;

  /// Returns `true` if route can match multiple
  /// routes due to usage of wildcards (`*`).
  bool get usesWildcardMatcher;
}

abstract class Routed {
  Z match<Z>({
    required final Z Function(Routes) routes,
    required final Z Function(RoutesAt) at,
  });
}

class Routes implements Routed {
  final Iterable<HttpRoute> routes;

  const Routes({
    required final this.routes,
  });

  @override
  Z match<Z>({
    required final Z Function(Routes p1) routes,
    required final Z Function(RoutesAt p1) at,
  }) =>
      routes(this);
}

class RoutesAt implements Routed {
  final String prefix;
  final Routed routes;

  const RoutesAt({
    required final this.prefix,
    required final this.routes,
  });

  @override
  Z match<Z>({
    required final Z Function(Routes p1) routes,
    required final Z Function(RoutesAt p1) at,
  }) =>
      at(this);
}

// TODO move back into separate subclasses.
const Route = RoutesMaker();

class RoutesMaker {
  const RoutesMaker();

  HttpRouteImpl post({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.post,
      );

  HttpRouteImpl get({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.get,
      );

  HttpRouteImpl put({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.put,
      );

  HttpRouteImpl delete({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.delete,
      );

  HttpRouteImpl options({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.options,
      );

  HttpRouteImpl patch({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.patch,
      );

  HttpRouteImpl all({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.all,
      );

  HttpRouteImpl head({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.head,
      );

  HttpRouteImpl connect({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.connect,
      );

  HttpRouteImpl trace({
    required final String path,
    required final Middleware middleware,
  }) =>
      HttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.trace,
      );
}

class HttpRouteImpl with HttpRouteMixin {
  @override
  final String path;
  @override
  final BuiltinMethod method;
  @override
  final Middleware middleware;

  const HttpRouteImpl({
    required final this.path,
    required final this.method,
    required final this.middleware,
  });
}

mixin HttpRouteMixin implements HttpRoute, HttpRouteDirections{
  @override
  bool get usesWildcardMatcher => path.contains('*');
}
