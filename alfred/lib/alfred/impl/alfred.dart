import 'dart:async';
// TODO centralize this dependency
import 'dart:io';

import '../../base/method.dart';
import '../../base/parse_method.dart';
import '../../base/unawaited.dart';
import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/logging_delegate.dart';
import '../interface/middleware.dart';
import 'built_alfred.dart';
import 'logging/print.dart';
import 'middleware/default_404.dart';
import 'middleware/default_500.dart';
import 'route_factory.dart';
import 'serve_context.dart';

Future<BuiltAlfred> helloAlfred({
  required final Iterable<HttpRoute> routes,
  final int? port,
}) {
  final _alfred = alfredWithRoutes(
    routes: [
      Routes(
        routes: routes,
      ),
    ],
  );
  return buildAlfred(
    alfred: _alfred,
    port: port,
  );
}

Future<BuiltAlfred> helloAlfred2({
  required final Iterable<Routed> routes,
  final int? port,
}) {
  final _alfred = alfredWithRoutes(
    routes: routes,
  );
  return buildAlfred(
    alfred: _alfred,
    port: port,
  );
}

AlfredImpl alfredWithRoutes({
  required final Iterable<Routed> routes,
}) {
  final alfred = makeSimpleAlfred();
  for (final route in routes) {
    alfred.add(
      routes: route,
    );
  }
  return alfred;
}

AlfredImpl makeSimpleAlfred({
  final Middleware? onNotFound,
  final Middleware Function(Object error)? onInternalError,
}) =>
    AlfredImpl.raw(
      routes: <HttpRoute>[],
      onNotFound: onNotFound ?? const NotFound404Middleware(),
      onInternalError: onInternalError ??
          (final a) => InternalError500Middleware(
                error: a,
              ),
    );

class AlfredImpl implements Alfred, HttpRouteFactory {
  @override
  final List<HttpRoute> routes;

  final Middleware onNotFound;

  final Middleware Function(Object error) onInternalError;

  AlfredImpl.raw({
    required final this.routes,
    required final this.onNotFound,
    required final this.onInternalError,
  });

  @override
  HttpRouteFactory get router => this;

  @override
  Future<BuiltAlfredImpl> build({
    final AlfredLoggingDelegate log = const AlfredLoggingDelegatePrintImpl(),
    final ServerConfig config = const ServerConfigDefault(),
  }) async =>
      makeAlfredImpl(
        config: config,
        log: log,
        alfred: this,
        requestHandler: (
          final HttpRequest request,
        ) async {
          // Variable to track the close of the response.
          var isDone = false;
          log.onIncomingRequest(
            method: request.method,
            uri: request.uri,
          );
          final c = ServeContextImpl(
            alfred: this,
            req: request,
            res: request.response,
          );
          // We track if the response has been resolved in order to exit out early
          // the list of routes (ie the middleware returned)
          unawaited(
            request.response.done.then(
              (final dynamic _) {
                isDone = true;
                log.onResponseSent();
              },
            ),
          );
          // Work out all the routes we need to process
          final matchedRoutes = matchRoute(
            input: request.uri.toString(),
            options: routes,
            method: parseHttpMethod(str: request.method) ?? Methods.get,
          );
          try {
            if (matchedRoutes.isEmpty) {
              log.onNoMatchingRouteFound();
              await onNotFound.process(c);
              await c.res.close();
            } else {
              // Tracks if one route is using a wildcard.
              var nonWildcardRouteMatch = false;
              // Loop through the routes in the order they are in the routes list
              for (final route in matchedRoutes) {
                c.route = route;
                if (!isDone) {
                  log.onMatchingRoute(
                    route: route.path,
                  );
                  nonWildcardRouteMatch = !route.usesWildcardMatcher || nonWildcardRouteMatch;
                  // If the request has already completed, exit early, otherwise process
                  // the primary route callback.
                  // ignore: invariant_booleans, <- false positive
                  if (isDone) {
                    break;
                  } else {
                    log.onExecuteRouteCallbackFunction();
                    await route.middleware.process(c);
                  }
                } else {
                  break;
                }
              }
              // If you got here and isDone is still false, you forgot to close
              // the response, or you didn't return anything. Either way its an error,
              // but instead of letting the whole server hang as most frameworks do,
              // lets at least close the connection out.
              if (!isDone) {
                if (request.response.contentLength == -1) {
                  if (nonWildcardRouteMatch == false) {
                    await onNotFound.process(c);
                    await c.res.close();
                  }
                }
                await request.response.close();
              }
            }
          } on AlfredException catch (e) {
            await e.match(
              notFound: (final e) async {
                await onNotFound.process(c);
                await c.res.close();
              },
            );
          } on Object catch (e, s) {
            log.onIncomingRequestException(
              e: e,
              s: s,
            );
            await onInternalError(e).process(c);
            await request.response.close();
          }
        },
      );

  @override
  HttpRouteFactoryImpl at({
    required final String path,
  }) =>
      HttpRouteFactoryImpl(
        alfred: this,
        basePath: path,
      );

  @override
  void add({
    required final Routed routes,
  }) =>
      routes.match(
        routes: (final a) => this.routes.addAll(a.routes),
        at: (final a) => at(path: a.prefix).add(routes: a.routes),
      );
}

Future<BuiltAlfred> buildAlfred({
  required final Alfred alfred,
  final int? port,
}) {
  if (port == null) {
    return alfred.build();
  } else {
    return alfred.build(
      config: ServerConfigDefaultWithPort(
        port: port,
      ),
    );
  }
}

List<HttpRoute> matchRoute({
  required final String input,
  required final List<HttpRoute> options,
  required final Method method,
}) {
  final output = <HttpRoute>[];
  final inputUri = Uri.parse(input);
  final inputPath = inputUri.path;
  final normalizedInputPath = _normalizePath(
    self: inputPath,
  );
  for (final option in options) {
    // Check if http method matches.
    if (option.method == method || option.method == Methods.all) {
      if (RegExp(
        [
          '^',
          ...() sync* {
            // Split route path into segments.
            final segments = Uri.parse(_normalizePath(self: option.path)).pathSegments;
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
      ).hasMatch(normalizedInputPath)) {
        output.add(option);
      }
    }
  }
  return output;
}

/// Trims all slashes at the start and end.
String _normalizePath({
  required final String self,
}) {
  if (self.startsWith('/')) {
    return _normalizePath(
      self: self.substring('/'.length),
    );
  } else if (self.endsWith('/')) {
    return _normalizePath(
      self: self.substring(0, self.length - '/'.length),
    );
  } else {
    return self;
  }
}
