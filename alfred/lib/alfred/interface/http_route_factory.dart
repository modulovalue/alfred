import '../../base/method.dart';
import 'middleware.dart';

abstract class Route {
  String get path;

  BuiltinMethod get method;

  // TODO find a better name for middleware
  Middleware get middleware;
}

class RouteImpl implements Route {
  @override
  final String path;
  @override
  final BuiltinMethod method;
  @override
  final Middleware middleware;

  const RouteImpl({
    required final this.path,
    required final this.method,
    required final this.middleware,
  });
}

class RouteGet implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RouteGet({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.get;
}

class RoutePut implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RoutePut({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.put;
}

class RouteDelete implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RouteDelete({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.delete;
}

class RouteOptions implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RouteOptions({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.options;
}

class RoutePatch implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RoutePatch({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.patch;
}

class RouteAll implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RouteAll({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.all;
}

class RoutePost implements Route {
  @override
  final String path;
  @override
  final Middleware middleware;

  const RoutePost({
    required final this.path,
    required final this.middleware,
  });

  @override
  BuiltinMethod get method => Methods.post;
}

abstract class HttpRouteFactory {
  void addRoutes(
    final Iterable<Route> route,
  );

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying further routes.
  HttpRouteFactory route(
    final String path,
  );
}

abstract class HttpRoute {
  String get route;

  Middleware get callback;

  BuiltinMethod get method;

  /// Returns `true` if route can match multiple
  /// routes due to usage of wildcards (`*`).
  bool get usesWildcardMatcher;
}
