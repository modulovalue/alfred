import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:alfred/alfred/impl/serve_context.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/base/method.dart';
import 'package:test/test.dart';

void main() {
  test('it should match routes correctly', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/a/:id/go',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/a',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/b/a/:input/another',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/b/a/:input',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/b/B/:input',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/[a-z]/yep',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
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
      HttpRouteImpl(
        path: '*',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/a',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/b',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(match('/a', testRoutes), ['*', '/a']);
  });
  test('it should generously match wildcards for sub-paths', () {
    const testRoutes = [
      HttpRouteImpl(
        path: 'path/*',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(match('/path/to', testRoutes), ['path/*']);
    expect(match('/path/', testRoutes), ['path/*']);
    expect(match('/path', testRoutes), ['path/*']);
  });
  test('it should respect the route method', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '*',
        middleware: ClosingMiddleware(),
        method: Methods.post,
      ),
      HttpRouteImpl(
        path: '/a',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/b',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(match('/a', testRoutes), ['/a']);
  });
  test('it should extract the route params correctly', () {
    expect(
      getParams(
        route: '/a/:value/:value2',
        input: '/a/input/Item%20inventory%20summary',
      ),
      {
        'value': 'input',
        'value2': 'Item inventory summary',
      },
    );
  });
  test('it should correctly match routes that have a partial match', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/image',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/imageSource',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(
      matchRoute(
        input: '/imagesource',
        options: testRoutes,
        method: Methods.get,
      ).map((final e) => e.path).toList(),
      ['/imageSource'],
    );
  });
  test('it handles a dodgy getParams request', () {
    expect(
      getParams(
            route: '/id/:id/abc',
            input: '/id/10',
          ) ==
          null,
      true,
    );
  });
  test('it should ignore a trailing slash', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/b/',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(match('/b?qs=true', testRoutes), ['/b/']);
  });
  test('it should ignore a trailing slash in reverse', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/b',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(
      match('/b/?qs=true', testRoutes),
      ['/b'],
    );
  });
  test('it should hit a wildcard route halfway through the uri', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/route/*',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/route/route2',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(
      match('/route/route2', testRoutes),
      ['/route/*', '/route/route2'],
    );
  });
  test('it should hit a wildcard route halfway through the uri - sibling', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/route*',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/route',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/route/test',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(
      match('/route', testRoutes),
      ['/route*', '/route'],
    );
    expect(
      match('/route/test', testRoutes),
      ['/route*', '/route/test'],
    );
  });
  test('it should match wildcards in the middle', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '/a/*/b',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '/a/*/*/b',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(match('/a', testRoutes), <String>[]);
    expect(match('/a/x/b', testRoutes), ['/a/*/b']);
    expect(match('/a/x/y/b', testRoutes), ['/a/*/b', '/a/*/*/b']);
  });
  test('it should match wildcards at the beginning', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '*.jpg',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
    ];
    expect(match('xjpg', testRoutes), <String>[]);
    expect(match('.jpg', testRoutes), <String>['*.jpg']);
    expect(match('path/to/picture.jpg', testRoutes), <String>['*.jpg']);
  });
  test('it should match regex expressions within segments', () {
    const testRoutes = [
      HttpRouteImpl(
        path: '[a-z]+/[0-9]+',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '[a-z]{5}',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
      HttpRouteImpl(
        path: '(a|b)/c',
        middleware: ClosingMiddleware(),
        method: Methods.get,
      ),
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
  final matchedRoute = matchRoute(
    input: input,
    options: routes,
    method: Methods.get,
  );
  return matchedRoute.map((e) => e.path).toList();
}
