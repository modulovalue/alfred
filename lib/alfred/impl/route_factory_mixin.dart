import '../../base/method.dart';
import '../interface/http_route_factory.dart';
import '../interface/middleware.dart';

mixin HttpRouteFactoryBoilerplateMixin implements HttpRouteFactory {
  @override
  void get(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.get);

  @override
  void post(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.post);

  @override
  void put(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.put);

  @override
  void delete(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.delete);

  @override
  void patch(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.patch);

  @override
  void options(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.options);

  @override
  void all(
    final String path,
    final Middleware callback,
  ) =>
      createRoute(path, callback, Methods.all);

  void createRoute(
    final String path,
    final Middleware callback,
    final BuiltinMethod method,
  );
}
