import 'base.dart';
import 'method.dart';
import 'middleware/interface/middleware.dart';

/// TODO interface and impl
class HttpRoute {
  final String route;
  final Middleware<Object?> callback;
  final Method method;
  final List<Middleware<Object?>> middleware;

  const HttpRoute(
    this.route,
    this.callback,
    this.method, {
    this.middleware = const [],
  });

  /// Returns `true` if route can match multiple routes due to usage of
  /// wildcards (`*`)
  bool get usesWildcardMatcher => route.contains('*');
}

/// TODO interface and impl
class NestedRoute {
  final Alfred _alfred;
  final String _basePath;
  final List<Middleware<Object?>> _baseMiddleware;

  const NestedRoute({
    required Alfred alfred,
    required String basePath,
    required List<Middleware<Object?>> baseMiddleware,
  })  : _alfred = alfred,
        _basePath = basePath,
        _baseMiddleware = baseMiddleware;

  /// Create a get route
  ///
  HttpRoute get(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.get, middleware);

  /// Create a post route
  ///
  HttpRoute post(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.post, middleware);

  /// Create a put route
  HttpRoute put(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.put, middleware);

  /// Create a delete route
  ///
  HttpRoute delete(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.delete, middleware);

  /// Create a patch route
  ///
  HttpRoute patch(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.patch, middleware);

  /// Create an options route
  ///
  HttpRoute options(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.options, middleware);

  /// Create a route that listens on all methods
  ///
  HttpRoute all(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.all, middleware);

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying routes with [get], [post], etc.
  ///
  /// You can define middleware that effects all sub-routes.
  NestedRoute route(
    String path, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      NestedRoute(alfred: _alfred, basePath: _composePath(_basePath, path), baseMiddleware: [..._baseMiddleware, ...middleware]);

  HttpRoute _createRoute(
    String path,
    Middleware<Object?> callback,
    Method method, [
    List<Middleware<Object?>> middleware = const [],
  ]) {
    final route = HttpRoute(_composePath(_basePath, path), callback, method, middleware: [..._baseMiddleware, ...middleware]);
    _alfred.routes.add(route);
    return route;
  }
}

String _composePath(String first, String second) {
  if (first.endsWith('/') && second.startsWith('/')) {
    return first + second.substring(1);
  } else if (!first.endsWith('/') && !second.startsWith('/')) {
    return first + '/' + second;
  }
  return first + second;
}

class RouteMatcher {
  static List<HttpRoute> match(String input, List<HttpRoute> options, Method method) {
    final output = <HttpRoute>[];
    final inputPath = _normalizePath(Uri.parse(input).path);
    for (final option in options) {
      // Check if http method matches.
      if (option.method == method || option.method == Method.all) {
        if (RegExp(
          [
            '^',
            ...() sync* {
              // Split route path into segments.
              final segments = Uri.parse(_normalizePath(option.route)).pathSegments;
              for (final segment in segments) {
                if (segment == '*' && segment != segments.first && segment == segments.last) {
                  // Generously match path if last segment is wildcard (*)
                  // Example: 'some/path/*' => should match 'some/path'.
                  yield '/?.*';
                } else if (segment != segments.first) {
                  // Add path separators.
                  yield '/';
                }
                yield segment
                    // Escape period character.
                    .replaceAll('.', r'\.')
                    // Parameter (':something') to anything but slash.
                    .replaceAll(RegExp(':.+'), '[^/]+?')
                    // Wildcard ('*') to anything.
                    .replaceAll('*', '.*?');
              }
            }(),
            '\$',
          ].join(""),
          caseSensitive: false,
        ).hasMatch(inputPath)) {
          output.add(option);
        }
      }
    }

    return output;
  }

  static Map<String, String> getParams(String route, String input) {
    final routeParts = route.split('/')..remove('');
    final inputParts = input.split('/')..remove('');
    if (inputParts.length != routeParts.length) {
      throw NotMatchingRouteException();
    } else {
      final output = <String, String>{};
      for (var i = 0; i < routeParts.length; i++) {
        final routePart = routeParts[i];
        final inputPart = inputParts[i];
        if (routePart.contains(':')) {
          final routeParams = routePart.split(':')..remove('');
          for (final item in routeParams) {
            output[item] = Uri.decodeComponent(inputPart);
          }
        }
      }
      return output;
    }
  }
}

/// Trims all slashes at the start and end
String _normalizePath(String self) {
  if (self.startsWith('/')) {
    return _normalizePath(self.substring('/'.length));
  } else if (self.endsWith('/')) {
    return _normalizePath(self.substring(0, self.length - '/'.length));
  } else {
    return self;
  }
}

/// Throws when trying to extract params and the route you are extracting from
/// does not match the supplied pattern
/// TODO interface and adt impl
class NotMatchingRouteException implements Exception {}
