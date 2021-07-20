import '../../base/method.dart';
import '../interface/http_route_factory.dart';
import '../interface/middleware.dart';

mixin HttpRouteFactoryBoilerplateMixin implements HttpRouteFactory {
  @override
  void addRoutes(
    Iterable<Route> routes,
  ) {
    for (final route in routes) {
      createRoute(
        route.path,
        route.middleware,
        route.method,
      );
    }
  }

  void createRoute(
    final String path,
    final Middleware callback,
    final BuiltinMethod method,
  );
}
