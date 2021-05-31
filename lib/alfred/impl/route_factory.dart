import '../../base/method.dart';
import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/middleware.dart';
import 'route_factory_mixin.dart';

class HttpRouteFactoryImpl with HttpRouteFactoryBoilerplateMixin {
  final Alfred alfred;
  final String basePath;

  const HttpRouteFactoryImpl({
    required this.alfred,
    required this.basePath,
  });

  static String _composePath(String first, String second) {
    if (first.endsWith('/') && second.startsWith('/')) {
      return first + second.substring(1);
    } else if (!first.endsWith('/') && !second.startsWith('/')) {
      return first + '/' + second;
    } else {
      return first + second;
    }
  }

  @override
  HttpRouteFactory route(String path, ) => //
      HttpRouteFactoryImpl(
        alfred: alfred,
        basePath: _composePath(basePath, path),
      );

  @override
  void createRoute(String path, Middleware callback, BuiltinMethod method) =>
      alfred.routes.add(HttpRouteImpl(_composePath(basePath, path), callback, method));
}

class HttpRouteImpl implements HttpRoute {
  @override
  final String route;
  @override
  final Middleware callback;
  @override
  final BuiltinMethod method;

  const HttpRouteImpl(this.route, this.callback, this.method);

  @override
  bool get usesWildcardMatcher => route.contains('*');
}
