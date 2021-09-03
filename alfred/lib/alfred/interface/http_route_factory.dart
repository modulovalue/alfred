import '../../base/method.dart';
import 'middleware.dart';

abstract class AlfredHttpRouteFactory {
  /// Adds a [AlfredRouted] route.
  void add({
    required final AlfredRouted routes,
  });

  /// As a common base for specifying further
  /// routes.
  AlfredHttpRouteFactory at({
    required final String path,
  });
}

abstract class AlfredHttpRouteDirections {
  String get path;

  BuiltinMethod get method;
}

abstract class AlfredHttpRoute implements AlfredHttpRouteDirections{
  AlfredMiddleware get middleware;

  /// Returns `true` if route can match multiple
  /// routes due to usage of wildcards (`*`).
  bool get usesWildcardMatcher;
}

abstract class AlfredRouted {
  Z match<Z>({
    required final Z Function(AlfredRoutes) routes,
    required final Z Function(AlfredRoutesAt) at,
  });
}

class AlfredRoutes implements AlfredRouted {
  final Iterable<AlfredHttpRoute> routes;

  const AlfredRoutes({
    required final this.routes,
  });

  @override
  Z match<Z>({
    required final Z Function(AlfredRoutes p1) routes,
    required final Z Function(AlfredRoutesAt p1) at,
  }) =>
      routes(this);
}

class AlfredRoutesAt implements AlfredRouted {
  final String prefix;
  final AlfredRouted routes;

  const AlfredRoutesAt({
    required final this.prefix,
    required final this.routes,
  });

  @override
  Z match<Z>({
    required final Z Function(AlfredRoutes p1) routes,
    required final Z Function(AlfredRoutesAt p1) at,
  }) =>
      at(this);
}

// TODO move back into separate subclasses.
const AlfredRoute = AlfredRoutesMaker();

class AlfredRoutesMaker {
  const AlfredRoutesMaker();

  AlfredHttpRouteImpl post({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.post,
      );

  AlfredHttpRouteImpl get({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.get,
      );

  AlfredHttpRouteImpl put({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.put,
      );

  AlfredHttpRouteImpl delete({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.delete,
      );

  AlfredHttpRouteImpl options({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.options,
      );

  AlfredHttpRouteImpl patch({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.patch,
      );

  AlfredHttpRouteImpl all({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.all,
      );

  AlfredHttpRouteImpl head({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.head,
      );

  AlfredHttpRouteImpl connect({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.connect,
      );

  AlfredHttpRouteImpl trace({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.trace,
      );
}

class AlfredHttpRouteImpl with AlfredHttpRouteMixin {
  @override
  final String path;
  @override
  final BuiltinMethod method;
  @override
  final AlfredMiddleware middleware;

  const AlfredHttpRouteImpl({
    required final this.path,
    required final this.method,
    required final this.middleware,
  });
}

mixin AlfredHttpRouteMixin implements AlfredHttpRoute, AlfredHttpRouteDirections{
  @override
  bool get usesWildcardMatcher => path.contains('*');
}
