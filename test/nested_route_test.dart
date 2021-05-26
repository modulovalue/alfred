import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:test/test.dart';

void main() {
  late Alfred app;
  setUp(() {
    app = Alfred();
  });
  test('it can compose requests', () async {
    final path = app.route('path');
    path.get('a', _callback);
    path.post('b', _callback);
    path.put('c', _callback);
    path.patch('d', _callback);
    path.delete('e', _callback);
    path.options('f', _callback);
    path.all('g', _callback);
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
    app.route('first/and').route('second/and').get('third', _callback);
    expect(app.routes.first.route, 'first/and/second/and/third');
  });
  test('it can handle slashes when composing', () async {
    app.route('first/').get('/second', _callback);
    app.route('first').get('/second', _callback);
    app.route('first/').get('second', _callback);
    app.route('first').get('second', _callback);
    expect(app.routes.length, 4);
    for (final route in app.routes) {
      expect(route.route, 'first/second');
    }
  });
  test('it can correctly inherit middleware', () async {
    final mw1 = _callback;
    final mw2 = _callback;
    final first = app.route('first', middleware: [mw1]);
    first.get('a', _callback);
    first.get('b', _callback);
    final second = first.route('second', middleware: [mw2]);
    second.get('c', _callback);
    expect(app.routes.length, 3);
    expect(app.routes[0].route, 'first/a');
    expect(app.routes[0].middleware, [mw1]);
    expect(app.routes[1].route, 'first/b');
    expect(app.routes[1].middleware, [mw1]);
    expect(app.routes[2].route, 'first/second/c');
    expect(app.routes[2].middleware, [mw1, mw2]);
  });
}

FutureOr<dynamic> Function(HttpRequest, HttpResponse) get _callback => (req, res) {};
