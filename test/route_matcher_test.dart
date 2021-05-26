import 'package:alfred/base.dart';
import 'package:alfred/http_route.dart';
import 'package:alfred/middleware/impl/empty.dart';
import 'package:test/test.dart';

void main() {
  test('it should match routes correctly', () {
    const testRoutes = [
      HttpRoute('/a/:id/go', EmptyMiddleware(), Method.get),
      HttpRoute('/a', EmptyMiddleware(), Method.get),
      HttpRoute('/b/a/:input/another', EmptyMiddleware(), Method.get),
      HttpRoute('/b/a/:input', EmptyMiddleware(), Method.get),
      HttpRoute('/b/B/:input', EmptyMiddleware(), Method.get),
      HttpRoute('/[a-z]/yep', EmptyMiddleware(), Method.get),
    ];
    expect(match('/a', testRoutes), ['/a']);
    expect(match('/a?query=true', testRoutes), ['/a']);
    expect(match('/a/123/go', testRoutes), ['/a/:id/go']);
    expect(match('/a/123/go/a', testRoutes), <String>[]);
    expect(match('/b/a/adskfjasjklf/another', testRoutes), ['/b/a/:input/another']);
    expect(match('/b/a/adskfjasj', testRoutes), ['/b/a/:input']);
    expect(match('/d/yep', testRoutes), ['/[a-z]/yep']);
    expect(match('/b/B/yep', testRoutes), ['/b/B/:input']);
  });
  test('it should match wildcards', () {
    const testRoutes = [
      HttpRoute('*', EmptyMiddleware(), Method.get),
      HttpRoute('/a', EmptyMiddleware(), Method.get),
      HttpRoute('/b', EmptyMiddleware(), Method.get),
    ];
    expect(match('/a', testRoutes), ['*', '/a']);
  });
  test('it should generously match wildcards for sub-paths', () {
    const testRoutes = [HttpRoute('path/*', EmptyMiddleware(), Method.get)];
    expect(match('/path/to', testRoutes), ['path/*']);
    expect(match('/path/', testRoutes), ['path/*']);
    expect(match('/path', testRoutes), ['path/*']);
  });
  test('it should respect the route method', () {
    const testRoutes = [
      HttpRoute('*', EmptyMiddleware(), Method.post),
      HttpRoute('/a', EmptyMiddleware(), Method.get),
      HttpRoute('/b', EmptyMiddleware(), Method.get),
    ];
    expect(match('/a', testRoutes), ['/a']);
  });
  test('it should extract the route params correctly', () {
    expect(RouteMatcher.getParams('/a/:value/:value2', '/a/input/Item%20inventory%20summary'), {
      'value': 'input',
      'value2': 'Item inventory summary',
    });
  });
  test('it should correctly match routes that have a partial match', () {
    const testRoutes = [HttpRoute('/image', EmptyMiddleware(), Method.get), HttpRoute('/imageSource', EmptyMiddleware(), Method.get)];
    expect(RouteMatcher.match('/imagesource', testRoutes, Method.get).map((e) => e.route).toList(), ['/imageSource']);
  });
  test('it handles a dodgy getParams request', () {
    var hitError = false;
    try {
      RouteMatcher.getParams('/id/:id/abc', '/id/10');
    } on NotMatchingRouteException catch (_) {
      hitError = true;
    }
    expect(hitError, true);
  });
  test('it should ignore a trailing slash', () {
    const testRoutes = [HttpRoute('/b/', EmptyMiddleware(), Method.get)];
    expect(match('/b?qs=true', testRoutes), ['/b/']);
  });
  test('it should ignore a trailing slash in reverse', () {
    const testRoutes = [HttpRoute('/b', EmptyMiddleware(), Method.get)];
    expect(match('/b/?qs=true', testRoutes), ['/b']);
  });
  test('it should hit a wildcard route halfway through the uri', () {
    const testRoutes = [
      HttpRoute('/route/*', EmptyMiddleware(), Method.get),
      HttpRoute('/route/route2', EmptyMiddleware(), Method.get),
    ];
    expect(match('/route/route2', testRoutes), ['/route/*', '/route/route2']);
  });
  test('it should hit a wildcard route halfway through the uri - sibling', () {
    const testRoutes = [
      HttpRoute('/route*', EmptyMiddleware(), Method.get),
      HttpRoute('/route', EmptyMiddleware(), Method.get),
      HttpRoute('/route/test', EmptyMiddleware(), Method.get),
    ];
    expect(match('/route', testRoutes), ['/route*', '/route']);
    expect(match('/route/test', testRoutes), ['/route*', '/route/test']);
  });
  test('it should match wildcards in the middle', () {
    const testRoutes = [
      HttpRoute('/a/*/b', EmptyMiddleware(), Method.get),
      HttpRoute('/a/*/*/b', EmptyMiddleware(), Method.get),
    ];
    expect(match('/a', testRoutes), <String>[]);
    expect(match('/a/x/b', testRoutes), ['/a/*/b']);
    expect(match('/a/x/y/b', testRoutes), ['/a/*/b', '/a/*/*/b']);
  });
  test('it should match wildcards at the beginning', () {
    const testRoutes = [HttpRoute('*.jpg', EmptyMiddleware(), Method.get)];
    expect(match('xjpg', testRoutes), <String>[]);
    expect(match('.jpg', testRoutes), <String>['*.jpg']);
    expect(match('path/to/picture.jpg', testRoutes), <String>['*.jpg']);
  });
  test('it should match regex expressions within segments', () {
    const testRoutes = [
      HttpRoute('[a-z]+/[0-9]+', EmptyMiddleware(), Method.get),
      HttpRoute('[a-z]{5}', EmptyMiddleware(), Method.get),
      HttpRoute('(a|b)/c', EmptyMiddleware(), Method.get),
    ];
    expect(match('a/b', testRoutes), <String>[]);
    expect(match('3/a', testRoutes), <String>[]);
    expect(match('x/323', testRoutes), <String>['[a-z]+/[0-9]+']);
    expect(match('answer/42', testRoutes), <String>['[a-z]+/[0-9]+']);
    expect(match('abc', testRoutes), <String>[]);
    expect(match('abc42', testRoutes), <String>[]);
    expect(match('abcde', testRoutes), <String>['[a-z]{5}']);
    expect(match('final', testRoutes), <String>['[a-z]{5}']);
    expect(match('a/c', testRoutes), <String>['(a|b)/c']);
    expect(match('b/c', testRoutes), <String>['(a|b)/c']);
  });
}

List<String> match(
  String input,
  List<HttpRoute> routes,
) =>
    RouteMatcher.match(input, routes, Method.get).map((e) => e.route).toList();
