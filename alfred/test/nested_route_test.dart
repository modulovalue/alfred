import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  test('it can compose requests', () async {
    await runTest(fn: (final app, final built, final port) async {
      final path = app.router.at(
        path: 'path',
      );
      path.add(
        routes: Routes(
          routes: [
            Route.get(
              path: 'a',
              middleware: const ClosingMiddleware(),
            ),
            Route.post(
              path: 'b',
              middleware: const ClosingMiddleware(),
            ),
            Route.put(
              path: 'c',
              middleware: const ClosingMiddleware(),
            ),
            Route.patch(
              path: 'd',
              middleware: const ClosingMiddleware(),
            ),
            Route.delete(
              path: 'e',
              middleware: const ClosingMiddleware(),
            ),
            Route.options(
              path: 'f',
              middleware: const ClosingMiddleware(),
            ),
            Route.all(
              path: 'g',
              middleware: const ClosingMiddleware(),
            ),
            Route.trace(
              path: 'h',
              middleware: const ClosingMiddleware(),
            ),
            Route.head(
              path: 'i',
              middleware: const ClosingMiddleware(),
            ),
            Route.connect(
              path: 'j',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      expect(app.routes.map((final r) => r.path + ':' + r.method.description).toList(), [
        'path/a:GET',
        'path/b:POST',
        'path/c:PUT',
        'path/d:PATCH',
        'path/e:DELETE',
        'path/f:OPTIONS',
        'path/g:ALL',
        'path/h:TRACE',
        'path/i:HEAD',
        'path/j:CONNECT',
      ]);
    });
  });
  test('it can compose multiple times', () async {
    await runTest(fn: (final app, final built, final port) async {
      app //
          .router
          .at(path: 'first/and')
          .at(path: 'second/and')
          .add(
            routes: Routes(
              routes: [
                Route.get(path: 'third', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      expect(app.routes.first.path, 'first/and/second/and/third');
    });
  });
  test('it can handle slashes when composing', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.at(path: 'first/').add(
            routes: Routes(
              routes: [
                Route.get(path: '/second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      app.router.at(path: 'first').add(
            routes: Routes(
              routes: [
                Route.get(path: '/second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      app.router.at(path: 'first/').add(
            routes: Routes(
              routes: [
                Route.get(path: 'second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      app.router.at(path: 'first').add(
            routes: Routes(
              routes: [
                Route.get(path: 'second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      expect(app.routes.length, 4);
      for (final route in app.routes) {
        expect(route.path, 'first/second');
      }
    });
  });
  test('it can correctly inherit middleware', () async {
    await runTest(fn: (final app, final built, final port) async {
      final first = app.router.at(
        path: 'first',
      );
      first.add(
        routes: Routes(
          routes: [
            Route.get(
              path: 'a',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      first.add(
        routes: Routes(
          routes: [
            Route.get(
              path: 'b',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      final second = first.at(path: 'second');
      second.add(
        routes: Routes(
          routes: [
            Route.get(
              path: 'c',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      expect(app.routes.length, 3);
      expect(app.routes.toList()[0].path, 'first/a');
      expect(app.routes.toList()[1].path, 'first/b');
      expect(app.routes.toList()[2].path, 'first/second/c');
    });
  });
}
