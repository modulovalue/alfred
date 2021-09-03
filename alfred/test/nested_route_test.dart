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
        routes: AlfredRoutes(
          routes: [
            AlfredRoute.get(
              path: 'a',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.post(
              path: 'b',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.put(
              path: 'c',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.patch(
              path: 'd',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.delete(
              path: 'e',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.options(
              path: 'f',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.all(
              path: 'g',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.trace(
              path: 'h',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.head(
              path: 'i',
              middleware: const ClosingMiddleware(),
            ),
            AlfredRoute.connect(
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
            routes: AlfredRoutes(
              routes: [
                AlfredRoute.get(path: 'third', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      expect(app.routes.first.path, 'first/and/second/and/third');
    });
  });
  test('it can handle slashes when composing', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.at(path: 'first/').add(
            routes: AlfredRoutes(
              routes: [
                AlfredRoute.get(path: '/second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      app.router.at(path: 'first').add(
            routes: AlfredRoutes(
              routes: [
                AlfredRoute.get(path: '/second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      app.router.at(path: 'first/').add(
            routes: AlfredRoutes(
              routes: [
                AlfredRoute.get(path: 'second', middleware: const ClosingMiddleware()),
              ],
            ),
          );
      app.router.at(path: 'first').add(
            routes: AlfredRoutes(
              routes: [
                AlfredRoute.get(path: 'second', middleware: const ClosingMiddleware()),
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
        routes: AlfredRoutes(
          routes: [
            AlfredRoute.get(
              path: 'a',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      first.add(
        routes: AlfredRoutes(
          routes: [
            AlfredRoute.get(
              path: 'b',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      final second = first.at(path: 'second');
      second.add(
        routes: AlfredRoutes(
          routes: [
            AlfredRoute.get(
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
