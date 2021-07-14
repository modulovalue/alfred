import 'dart:async';
import 'dart:io';

import '../../base/method.dart';
import '../../base/parse_method.dart';
import '../../base/unawaited.dart';
import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/logging_delegate.dart';
import '../interface/middleware.dart';
import 'built_alfred.dart';
import 'logging/log_type.dart';
import 'logging/print.dart';
import 'middleware/defaults.dart';
import 'route_factory.dart';
import 'route_factory_mixin.dart';
import 'serve_context.dart';

class AlfredImpl with HttpRouteFactoryBoilerplateMixin implements Alfred {
  @override
  final List<HttpRoute> routes;

  @override
  final AlfredLoggingDelegate log;

  final Middleware onNotFound;

  final Middleware Function(dynamic error) onInternalError;

  /// Creates a new Alfred application.
  ///
  /// simultaneousProcessing is the number of requests doing work at any one
  /// time. If the amount of unprocessed incoming requests exceed this number,
  /// the requests will be queued.
  factory AlfredImpl({
    final Middleware? onNotFound,
    final AlfredLoggingDelegate? log,
    final Middleware Function(dynamic error)? onInternalError,
  }) =>
      AlfredImpl.raw(
        routes: <HttpRoute>[],
        log: log ?? const AlfredLoggingDelegatePrintImpl(LogType.debug),
        onNotFound: onNotFound ?? const NotFound404Middleware(),
        onInternalError: onInternalError ?? InternalError500Middleware.make,
      );

  AlfredImpl.raw({
    required final this.routes,
    required final this.log,
    required final this.onNotFound,
    required final this.onInternalError,
  });

  @override
  Future<BuiltAlfredImpl> build([
    final int port = 80,
    final String bindIp = '0.0.0.0',
    final bool shared = true,
    final int simultaneousProcessing = 50,
  ]) async =>
      BuiltAlfredImpl.make(
        port: port,
        bindIp: bindIp,
        shared: shared,
        log: log,
        simultaneousProcessing: simultaneousProcessing,
        requestHandler: _incomingRequest,
      );

  @override
  HttpRouteFactoryImpl route(
    final String path,
  ) =>
      HttpRouteFactoryImpl(
        alfred: this,
        basePath: path,
      );

  /// Handles and routes an incoming request.
  Future<void> _incomingRequest(
    final HttpRequest request,
  ) async {
    // Variable to track the close of the response.
    var isDone = false;
    log.onIncomingRequest(request.method, request.uri);
    final c = ServeContextImpl(
      alfred: this,
      req: request,
      res: request.response,
    );
    // We track if the response has been resolved in order to exit out early
    // the list of routes (ie the middleware returned)
    unawaited(request.response.done.then((final dynamic _) {
      isDone = true;
      log.onResponseSent();
    }));
    // Work out all the routes we need to process
    final matchedRoutes = matchRoute(
      request.uri.toString(),
      routes,
      parseHttpMethod(request.method) ?? Methods.get,
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
            log.onMatchingRoute(route.route);
            nonWildcardRouteMatch = !route.usesWildcardMatcher || nonWildcardRouteMatch;
            // If the request has already completed, exit early, otherwise process
            // the primary route callback.
            // ignore: invariant_booleans, <- false positive
            if (isDone) {
              break;
            } else {
              log.onExecuteRouteCallbackFunction();
              await route.callback.process(c);
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
      // The user threw a 'handle HTTP' Exception
      request.response.statusCode = e.statusCode;
      await request.response.close();
      // ignore: avoid_catching_errors
    } on NotFoundException catch (_) {
      await onNotFound.process(c);
      await c.res.close();
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      log.onIncomingRequestException(e, s);
      await onInternalError(e).process(c);
      await request.response.close();
    }
  }

  @override
  void createRoute(
    final String path,
    final Middleware callback,
    final BuiltinMethod method,
  ) {
    final route = HttpRouteImpl(path, callback, method);
    routes.add(route);
  }
}

List<HttpRoute> matchRoute(
  final String input,
  final List<HttpRoute> options,
  final Method method,
) {
  final output = <HttpRoute>[];
  final inputPath = normalizePath(Uri.parse(input).path);
  for (final option in options) {
    // Check if http method matches.
    if (option.method == method || option.method == Methods.all) {
      if (RegExp(
        [
          '^',
          ...() sync* {
            // Split route path into segments.
            final segments = Uri.parse(normalizePath(option.route)).pathSegments;
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

/// Trims all slashes at the start and end.
String normalizePath(
  final String self,
) {
  if (self.startsWith('/')) {
    return normalizePath(self.substring('/'.length));
  } else if (self.endsWith('/')) {
    return normalizePath(self.substring(0, self.length - '/'.length));
  } else {
    return self;
  }
}
