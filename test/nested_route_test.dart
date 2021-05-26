import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/empty.dart';
import 'package:test/test.dart';

void main() {
  late Alfred app;
  setUp(() {
    app = Alfred();
  });
  test('it can compose requests', () async {
    final path = app.route('path');
    path.get('a', const EmptyMiddleware());
    path.post('b', const EmptyMiddleware());
    path.put('c', const EmptyMiddleware());
    path.patch('d', const EmptyMiddleware());
    path.delete('e', const EmptyMiddleware());
    path.options('f', const EmptyMiddleware());
    path.all('g', const EmptyMiddleware());
    expect(app.routes.map((r) => '${r.route}:${r.method}').toList(), [
      'path/a:Method.get',
      'path/b:Method.post',
      'path/c:Method.put',
      'path/d:Method.patch',
      'path/e:Method.delete',
      'path/f:Method.options',
      'path/g:Method.all',
    ]);
  });
  test('it can compose multiple times', () async {
    app.route('first/and').route('second/and').get('third', const EmptyMiddleware());
    expect(app.routes.first.route, 'first/and/second/and/third');
  });
  test('it can handle slashes when composing', () async {
    app.route('first/').get('/second', const EmptyMiddleware());
    app.route('first').get('/second', const EmptyMiddleware());
    app.route('first/').get('second', const EmptyMiddleware());
    app.route('first').get('second', const EmptyMiddleware());
    expect(app.routes.length, 4);
    for (final route in app.routes) {
      expect(route.route, 'first/second');
    }
  });
  test('it can correctly inherit middleware', () async {
    const mw1 = EmptyMiddleware();
    const mw2 = EmptyMiddleware();
    final first = app.route('first', middleware: [mw1]);
    first.get('a', const EmptyMiddleware());
    first.get('b', const EmptyMiddleware());
    final second = first.route('second', middleware: [mw2]);
    second.get('c', const EmptyMiddleware());
    expect(app.routes.length, 3);
    expect(app.routes[0].route, 'first/a');
    expect(app.routes[0].middleware, [mw1]);
    expect(app.routes[1].route, 'first/b');
    expect(app.routes[1].middleware, [mw1]);
    expect(app.routes[2].route, 'first/second/c');
    expect(app.routes[2].middleware, [mw1, mw2]);
  });
}
