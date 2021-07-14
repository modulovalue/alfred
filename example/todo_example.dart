import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/defaults.dart';
import 'package:alfred/alfred/impl/middleware/html.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';
import 'package:alfred/alfred/interface/middleware.dart';

Future<void> main() async {
  /// TODO flatten and add as routes.
  final _ = RootRouteTree(
    const NotFound404Middleware(),
    [
      "text".get(const ServeString(
        'Text response',
      )),
      "json".get(const ServeJson.map({
        'json_response': true,
      })),
      "jsonExpressStyle".get(const ServeJson.map({
        'type': 'traditional_json_response',
      })),
      "file".get(ServeFile.at(
        'test/files/image.jpg',
      )),
      "html".get(const ServeHtml(
        '<html><body><h1>Test HTML</h1></body></html>',
      )),
    ],
  );
  final app = AlfredImpl();
  await app.build(6565); // Listening on port 6565.
}

class RootRouteTree {
  final Middleware slash;
  final List<RouteTree> routes;

  const RootRouteTree(this.slash, this.routes);
}

extension RouteAsStringExtension on String {
  MiddlewareRouteTree get(
    Middleware middleware,
  ) =>
      MiddlewareRouteTree(this, middleware);
}

abstract class RouteTree {
  Z matchRouteTree<Z>({
    required Z Function(PathRouteTree) path,
    required Z Function(MiddlewareRouteTree) middleware,
  });
}

class PathRouteTree implements RouteTree {
  final String at;
  final List<RouteTree> children;

  const PathRouteTree(this.at, this.children);

  @override
  Z matchRouteTree<Z>({
    required Z Function(PathRouteTree p1) path,
    required Z Function(MiddlewareRouteTree p1) middleware,
  }) =>
      path(this);
}

class MiddlewareRouteTree implements RouteTree {
  final String route;
  final Middleware middleware;

  const MiddlewareRouteTree(this.route, this.middleware);

  @override
  Z matchRouteTree<Z>({
    required Z Function(PathRouteTree p1) path,
    required Z Function(MiddlewareRouteTree p1) middleware,
  }) =>
      middleware(this);
}
