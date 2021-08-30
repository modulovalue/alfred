import '../../util/compose_path.dart';
import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';

class HttpRouteFactoryImpl implements HttpRouteFactory {
  final Alfred alfred;
  final String basePath;

  const HttpRouteFactoryImpl({
    required final this.alfred,
    required final this.basePath,
  });

  @override
  void add({
    required final Routed routes,
  }) {
    routes.match(
      routes: (final _routes) {
        for (final route in _routes.routes) {
          alfred.router.add(
            routes: Routes(
              routes: [
                HttpRouteImpl(
                  method: route.method,
                  path: composePath(
                    first: basePath,
                    second: route.path,
                  ),
                  middleware: route.middleware,
                ),
              ],
            ),
          );
        }
      },
      at: (final _at) => at(path: _at.prefix).add(routes: _at.routes),
    );
  }

  @override
  HttpRouteFactory at({
    required final String path,
  }) =>
      HttpRouteFactoryImpl(
        alfred: alfred,
        basePath: composePath(
          first: basePath,
          second: path,
        ),
      );
}
