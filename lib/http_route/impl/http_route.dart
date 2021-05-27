import '../../alfred/interface/alfred.dart';
import '../../base/impl/methods.dart';
import '../../middleware/interface/middleware.dart';
import '../interface/http_route.dart';

class HttpRouteImpl implements HttpRoute {
  @override
  final String route;
  @override
  final Middleware<Object?> callback;
  @override
  final BuiltinMethod method;
  @override
  final List<Middleware<Object?>> middleware;

  const HttpRouteImpl(
    this.route,
    this.callback,
    this.method, {
    this.middleware = const [],
  });

  @override
  bool get usesWildcardMatcher => route.contains('*');
}

class HttpRouteFactoryImpl implements HttpRouteFactory {
  final Alfred alfred;
  final String basePath;
  final List<Middleware<Object?>> baseMiddleware;

  const HttpRouteFactoryImpl({
    required this.alfred,
    required this.basePath,
    required this.baseMiddleware,
  });

  @override
  HttpRoute get(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.get, middleware);

  @override
  HttpRoute post(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.post, middleware);

  @override
  HttpRoute put(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.put, middleware);

  @override
  HttpRoute delete(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.delete, middleware);

  @override
  HttpRoute patch(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.patch, middleware);

  @override
  HttpRoute options(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.options, middleware);

  @override
  HttpRoute all(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Methods.all, middleware);

  static String _composePath(String first, String second) {
    if (first.endsWith('/') && second.startsWith('/')) {
      return first + second.substring(1);
    } else if (!first.endsWith('/') && !second.startsWith('/')) {
      return first + '/' + second;
    }
    return first + second;
  }

  @override
  HttpRouteFactory route(
    String path, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      HttpRouteFactoryImpl(alfred: alfred, basePath: _composePath(basePath, path), baseMiddleware: [...baseMiddleware, ...middleware]);

  HttpRoute _createRoute(
    String path,
    Middleware<Object?> callback,
    BuiltinMethod method, [
    List<Middleware<Object?>> middleware = const [],
  ]) {
    final route = HttpRouteImpl(_composePath(basePath, path), callback, method, middleware: [...baseMiddleware, ...middleware]);
    alfred.routes.add(route);
    return route;
  }
}

/// Throws when trying to extract params and the route you are extracting from
/// does not match the supplied pattern
/// TODO interface and adt impl
class NotMatchingRouteException implements Exception {
  const NotMatchingRouteException();
}
