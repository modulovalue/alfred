import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  test('it can compose requests', () async {
    await runTest(fn: (final app, final built, final port) async {
      final path = app.route('path');
      path.get('a', const ClosingMiddleware());
      path.post('b', const ClosingMiddleware());
      path.put('c', const ClosingMiddleware());
      path.patch('d', const ClosingMiddleware());
      path.delete('e', const ClosingMiddleware());
      path.options('f', const ClosingMiddleware());
      path.all('g', const ClosingMiddleware());
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
      app.route('first/and').route('second/and').get('third', const ClosingMiddleware());
      expect(app.routes.first.route, 'first/and/second/and/third');
    });
  });
  test('it can handle slashes when composing', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.route('first/').get('/second', const ClosingMiddleware());
      app.route('first').get('/second', const ClosingMiddleware());
      app.route('first/').get('second', const ClosingMiddleware());
      app.route('first').get('second', const ClosingMiddleware());
      expect(app.routes.length, 4);
      for (final route in app.routes) {
        expect(route.route, 'first/second');
      }
    });
  });
  test('it can correctly inherit middleware', () async {
    await runTest(fn: (final app, final built, final port) async {
      final first = app.route('first');
      first.get('a', const ClosingMiddleware());
      first.get('b', const ClosingMiddleware());
      final second = first.route('second');
      second.get('c', const ClosingMiddleware());
      expect(app.routes.length, 3);
      expect(app.routes[0].route, 'first/a');
      expect(app.routes[1].route, 'first/b');
      expect(app.routes[2].route, 'first/second/c');
    });
  });
}
