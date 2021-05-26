import '../alfred.dart';
import 'alfred.dart';
import 'http_route.dart';

class RouteMatcher {
  static List<HttpRoute> match(String input, List<HttpRoute> options, Method method) {
    final output = <HttpRoute>[];
    final inputPath = Uri.parse(input).path.normalizePath;
    for (final option in options) {
      // Check if http method matches.
      if (option.method == method || option.method == Method.all) {
        if (RegExp(
          [
            '^',
            ...() sync* {
              // Split route path into segments.
              final segments = Uri.parse(option.route.normalizePath).pathSegments;
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

extension _PathNormalizer on String {
  /// Trims all slashes at the start and end
  String get normalizePath {
    if (startsWith('/')) {
      return substring('/'.length).normalizePath;
    } else if (endsWith('/')) {
      return substring(0, length - '/'.length).normalizePath;
    } else {
      return this;
    }
  }
}

/// Throws when trying to extract params and the route you are extracting from
/// does not match the supplied pattern
class NotMatchingRouteException implements Exception {}
