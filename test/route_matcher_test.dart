import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';
import 'package:alfred/alfred/impl/route_factory.dart';
import 'package:alfred/alfred/impl/serve_context.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/base/method.dart';
import 'package:test/test.dart';

void main() {
  test('it should match routes correctly', () {
    const testRoutes = [
      HttpRouteImpl('/a/:id/go', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/a', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/b/a/:input/another', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/b/a/:input', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/b/B/:input', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/[a-z]/yep', ClosingMiddleware(), Methods.get),
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
      HttpRouteImpl('*', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/a', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/b', ClosingMiddleware(), Methods.get),
    ];
    expect(match('/a', testRoutes), ['*', '/a']);
  });
  test('it should generously match wildcards for sub-paths', () {
    const testRoutes = [HttpRouteImpl('path/*', ClosingMiddleware(), Methods.get)];
    expect(match('/path/to', testRoutes), ['path/*']);
    expect(match('/path/', testRoutes), ['path/*']);
    expect(match('/path', testRoutes), ['path/*']);
  });
  test('it should respect the route method', () {
    const testRoutes = [
      HttpRouteImpl('*', ClosingMiddleware(), Methods.post),
      HttpRouteImpl('/a', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/b', ClosingMiddleware(), Methods.get),
    ];
    expect(match('/a', testRoutes), ['/a']);
  });
  test('it should extract the route params correctly', () {
    expect(getParams('/a/:value/:value2', '/a/input/Item%20inventory%20summary'), {
      'value': 'input',
      'value2': 'Item inventory summary',
    });
  });
  test('it should correctly match routes that have a partial match', () {
    const testRoutes = [
      HttpRouteImpl('/image', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/imageSource', ClosingMiddleware(), Methods.get)
    ];
    expect(matchRoute('/imagesource', testRoutes, Methods.get).map((e) => e.route).toList(), ['/imageSource']);
  });
  test('it handles a dodgy getParams request', () {
    expect(getParams('/id/:id/abc', '/id/10') == null, true);
  });
  test('it should ignore a trailing slash', () {
    const testRoutes = [HttpRouteImpl('/b/', ClosingMiddleware(), Methods.get)];
    expect(match('/b?qs=true', testRoutes), ['/b/']);
  });
  test('it should ignore a trailing slash in reverse', () {
    const testRoutes = [HttpRouteImpl('/b', ClosingMiddleware(), Methods.get)];
    expect(match('/b/?qs=true', testRoutes), ['/b']);
  });
  test('it should hit a wildcard route halfway through the uri', () {
    const testRoutes = [
      HttpRouteImpl('/route/*', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/route/route2', ClosingMiddleware(), Methods.get),
    ];
    expect(match('/route/route2', testRoutes), ['/route/*', '/route/route2']);
  });
  test('it should hit a wildcard route halfway through the uri - sibling', () {
    const testRoutes = [
      HttpRouteImpl('/route*', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/route', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/route/test', ClosingMiddleware(), Methods.get),
    ];
    expect(match('/route', testRoutes), ['/route*', '/route']);
    expect(match('/route/test', testRoutes), ['/route*', '/route/test']);
  });
  test('it should match wildcards in the middle', () {
    const testRoutes = [
      HttpRouteImpl('/a/*/b', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('/a/*/*/b', ClosingMiddleware(), Methods.get),
    ];
    expect(match('/a', testRoutes), <String>[]);
    expect(match('/a/x/b', testRoutes), ['/a/*/b']);
    expect(match('/a/x/y/b', testRoutes), ['/a/*/b', '/a/*/*/b']);
  });
  test('it should match wildcards at the beginning', () {
    const testRoutes = [HttpRouteImpl('*.jpg', ClosingMiddleware(), Methods.get)];
    expect(match('xjpg', testRoutes), <String>[]);
    expect(match('.jpg', testRoutes), <String>['*.jpg']);
    expect(match('path/to/picture.jpg', testRoutes), <String>['*.jpg']);
  });
  test('it should match regex expressions within segments', () {
    const testRoutes = [
      HttpRouteImpl('[a-z]+/[0-9]+', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('[a-z]{5}', ClosingMiddleware(), Methods.get),
      HttpRouteImpl('(a|b)/c', ClosingMiddleware(), Methods.get),
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
  final String input,
  final List<HttpRoute> routes,
) {
  final matchedRoute = matchRoute(input, routes, Methods.get);
  return matchedRoute.map((e) => e.route).toList();
}
