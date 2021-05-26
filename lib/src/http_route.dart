import 'dart:async';
import 'dart:io';

import '../alfred.dart';
import 'alfred.dart';

class HttpRoute {
  final String route;
  final FutureOr<dynamic> Function(HttpRequest req, HttpResponse res) callback;
  final Method method;
  final List<FutureOr<dynamic> Function(HttpRequest req, HttpResponse res)> middleware;

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
