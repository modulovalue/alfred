import '../../base/method.dart';
import '../interface/http_route_factory.dart';
import '../interface/middleware.dart';

mixin HttpRouteFactoryBoilerplateMixin implements HttpRouteFactory {
  @override
  void get(String path, Middleware callback) => //
      createRoute(path, callback, Methods.get);

  @override
  void post(String path, Middleware callback) => //
      createRoute(path, callback, Methods.post);

  @override
  void put(String path, Middleware callback) => //
      createRoute(path, callback, Methods.put);

  @override
  void delete(String path, Middleware callback) => //
      createRoute(path, callback, Methods.delete);

  @override
  void patch(String path, Middleware callback) => //
      createRoute(path, callback, Methods.patch);

  @override
  void options(String path, Middleware callback) => //
      createRoute(path, callback, Methods.options);

  @override
  void all(String path, Middleware callback) => //
      createRoute(path, callback, Methods.all);

  void createRoute(String path, Middleware callback, BuiltinMethod method);
}
