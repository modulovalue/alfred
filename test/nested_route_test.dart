import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  test('it can compose requests', () async {
    await runTest(fn: (final app, final built, final port) async {
      final path = app.route('path');
      path.addRoutes([
        const RouteGet(
          path: 'a',
          middleware: ClosingMiddleware(),
        ),
        const RoutePost(
          path: 'b',
          middleware: ClosingMiddleware(),
        ),
        const RoutePut(
          path: 'c',
          middleware: ClosingMiddleware(),
        ),
        const RoutePatch(
          path: 'd',
          middleware: ClosingMiddleware(),
        ),
        const RouteDelete(
          path: 'e',
          middleware: ClosingMiddleware(),
        ),
        const RouteOptions(
          path: 'f',
          middleware: ClosingMiddleware(),
        ),
        const RouteAll(
          path: 'g',
          middleware: ClosingMiddleware(),
        ),
      ]);
      expect(app.routes.map((final r) => r.route + ':' + r.method.description).toList(), [
        'path/a:GET',
        'path/b:POST',
        'path/c:PUT',
        'path/d:PATCH',
        'path/e:DELETE',
        'path/f:OPTIONS',
        'path/g:ALL',
      ]);
    });
  });
  test('it can compose multiple times', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.route('first/and').route('second/and').addRoutes([const RouteGet(path: 'third', middleware: ClosingMiddleware())]);
      expect(app.routes.first.route, 'first/and/second/and/third');
    });
  });
  test('it can handle slashes when composing', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.route('first/').addRoutes([const RouteGet(path: '/second', middleware: ClosingMiddleware())]);
      app.route('first').addRoutes([const RouteGet(path: '/second', middleware: ClosingMiddleware())]);
      app.route('first/').addRoutes([const RouteGet(path: 'second', middleware: ClosingMiddleware())]);
      app.route('first').addRoutes([const RouteGet(path: 'second', middleware: ClosingMiddleware())]);
      expect(app.routes.length, 4);
      for (final route in app.routes) {
        expect(route.route, 'first/second');
      }
    });
  });
  test('it can correctly inherit middleware', () async {
    await runTest(fn: (final app, final built, final port) async {
      final first = app.route('first');
      first.addRoutes([const RouteGet(path: 'a', middleware: ClosingMiddleware())]);
      first.addRoutes([const RouteGet(path: 'b', middleware: ClosingMiddleware())]);
      final second = first.route('second');
      second.addRoutes([const RouteGet(path: 'c', middleware: ClosingMiddleware())]);
      expect(app.routes.length, 3);
      expect(app.routes[0].route, 'first/a');
      expect(app.routes[1].route, 'first/b');
      expect(app.routes[2].route, 'first/second/c');
    });
  });
}
