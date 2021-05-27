import 'dart:async';
import 'dart:io';

import 'package:queue/queue.dart';

import '../../base/impl/methods.dart';
import '../../base/impl/parser.dart';
import '../../base/interface/exception.dart';
import '../../base/interface/method.dart';
import '../../base/unawaited.dart';
import '../../http_route/impl/http_route.dart';
import '../../http_route/interface/http_route.dart';
import '../../logging/impl/generalizing/log_type.dart';
import '../../logging/impl/generalizing/print.dart';
import '../../logging/interface/logging_delegate.dart';
import '../../middleware/interface/middleware.dart';
import '../../store/impl/store.dart';
import '../../type_handler/impl/directory.dart';
import '../../type_handler/impl/file.dart';
import '../../type_handler/impl/json_list.dart';
import '../../type_handler/impl/json_map.dart';
import '../../type_handler/impl/list_of_ints.dart';
import '../../type_handler/impl/serializable.dart';
import '../../type_handler/impl/stream_of_list_of_integers.dart';
import '../../type_handler/impl/string.dart';
import '../../type_handler/impl/websocket/impl.dart';
import '../../type_handler/interface/type_handler.dart';
import '../interface/alfred.dart';
import 'request.dart';

class AlfredImpl implements Alfred {
  @override
  final List<HttpRoute> routes;

  @override
  late final List<TypeHandler<dynamic>> typeHandlers = <TypeHandler<dynamic>>[
    const TypeHandlerStringImpl(),
    const TypeHandlerListOfIntegersImpl(),
    const TypeHandlerStreamOfListOfIntegersImpl(),
    const TypeHandlerJsonListImpl(),
    const TypeHandlerJsonMapImpl(),
    const TypeHandlerFileImpl(),
    TypeHandlerDirectoryImpl(this),
    const TypeHandlerWebsocketImpl(),
    const TypeHandlerSerializableImpl()
  ];

  @override
  final store = StorePluginDataImpl();

  late final List<void Function(HttpRequest req, HttpResponse res)> _onDoneListeners = [store.storePluginOnDoneHandler];

  @override
  final Queue requestQueue;

  @override
  HttpServer? server;

  @override
  final AlfredLoggingDelegate log;

  @override
  Middleware<Object?>? onNotFound;

  @override
  Middleware<Object?>? onInternalError;

  static const AlfredLoggingDelegate defaultLogger = AlfredLoggingDelegatePrintImpl(LogType.info);

  /// Creates a new Alfred application.
  ///
  /// [simultaneousProcessing] is the number of requests doing work at any one
  /// time. If the amount of unprocessed incoming requests exceed this number,
  /// the requests will be queued.
  AlfredImpl({
    this.onNotFound,
    this.onInternalError,
    this.log = defaultLogger,
    int simultaneousProcessing = 50,
  })  : routes = <HttpRoute>[],
        requestQueue = Queue(parallel: simultaneousProcessing);

  @override
  void registerOnDoneListener(
    void Function(HttpRequest, HttpResponse) listener,
  ) =>
      _onDoneListeners.add(listener);

  @override
  void removeOnDoneListener(
    void Function(HttpRequest req, HttpResponse res) listener,
  ) =>
      _onDoneListeners.remove(listener);

  @override
  void get(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.get, middleware);

  @override
  void post(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.post, middleware);

  @override
  void put(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.put, middleware);

  @override
  void delete(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.delete, middleware);

  @override
  void patch(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.patch, middleware);

  @override
  void options(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.options, middleware);

  @override
  void all(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _addRoute(path, callback, Methods.all, middleware);

  @override
  Future<HttpServer> listen([
    /// TODO make use provide defaults explicitly via a custom model and a default implementation.
    int port = 3000,
    dynamic bindIp = '0.0.0.0',
    bool shared = true,
  ]) async {
    final _server = await HttpServer.bind(bindIp, port, shared: shared);
    _server.idleTimeout = const Duration(seconds: 1);
    _server.listen((request) => requestQueue.add(() => _incomingRequest(request)));
    log.onIsListening(_server.port);
    return server = _server;
  }

  @override
  Future<dynamic> close({bool force = true}) async {
    if (server != null) {
      await server!.close(force: force);
    }
  }

  /// Print out the registered routes to the console.
  ///
  /// Helpful to see whats available.
  @override
  void printRoutes() {
    for (final route in routes) {
      print(
        '${route.route} - ' +
            route.method.matchBuiltinMethods(
              get: (_) => '\x1B[33m' + _.description + '\x1B[0m',
              post: (_) => '\x1B[31m' + _.description + '\x1B[0m',
              put: (_) => '\x1B[32m' + _.description + '\x1B[0m',
              delete: (_) => '\x1B[34m' + _.description + '\x1B[0m',
              options: (_) => '\x1B[36m' + _.description + '\x1B[0m',
              all: (_) => '\x1B[37m' + _.description + '\x1B[0m',
              patch: (_) => '\x1B[35m' + _.description + '\x1B[0m',
            ) +
            ' String',
      );
    }
  }

  @override
  HttpRouteFactory route(
    String path, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      HttpRouteFactoryImpl(alfred: this, basePath: path, baseMiddleware: middleware);

  /// Handles and routes an incoming request
  Future<void> _incomingRequest(HttpRequest request) async {
    /// Variable to track the close of the response
    var isDone = false;
    log.onIncomingRequest(request.method, request.uri);
    // We track if the response has been resolved in order to exit out early
    // the list of routes (ie the middleware returned)
    unawaited(request.response.done.then((dynamic _) {
      isDone = true;
      for (final listener in _onDoneListeners) {
        listener(request, request.response);
      }
      log.onResponseSent();
    }));
    // Work out all the routes we need to process
    final effectiveRoutes = RouteMatcher.match(
      request.uri.toString(),
      routes,
      tryParseMethod(request.method) ?? Methods.get,
    );
    try {
      // If there are no effective routes, that means we need to throw a 404
      // or see if there are any static routes to fall back to, otherwise
      // continue and process the routes
      if (effectiveRoutes.isEmpty) {
        log.onNoMatchingRouteFound();
        await _respondNotFound(request, isDone);
      } else {
        // Tracks if one route is using a wildcard.
        var nonWildcardRouteMatch = false;
        // Loop through the routes in the order they are in the routes list
        for (final route in effectiveRoutes) {
          if (isDone) {
            break;
          } else {
            log.onMatchingRoute(route.route);
            AlfredHttpRequestImpl(request, this).store.set('_internal_route', route.route);
            nonWildcardRouteMatch = !route.usesWildcardMatcher || nonWildcardRouteMatch;
            // Loop through any middleware.
            for (final middleware in route.middleware) {
              // If the request has already completed, exit early.
              // ignore: invariant_booleans, <- false positive
              if (isDone) {
                break;
              } else {
                log.onApplyMiddleware();
                await _handleResponse(await middleware.process(request, request.response), request);
              }
            }
            // If the request has already completed, exit early, otherwise process
            // the primary route callback.
            // ignore: invariant_booleans, <- false positive
            if (isDone) {
              break;
            } else {
              log.onExecuteRouteCallbackFunction();
              await _handleResponse(await route.callback.process(request, request.response), request);
            }
          }
        }
        // If you got here and isDone is still false, you forgot to close
        // the response, or you didn't return anything. Either way its an error,
        // but instead of letting the whole server hang as most frameworks do,
        // lets at least close the connection out.
        if (!isDone) {
          if (request.response.contentLength == -1) {
            if (nonWildcardRouteMatch == false) {
              await _respondNotFound(request, isDone);
            }
          }
          await request.response.close();
        }
      }
    } on AlfredException catch (e) {
      // The user threw a handle HTTP Exception
      request.response.statusCode = e.statusCode;
      await _handleResponse(e.response, request);
      // ignore: avoid_catching_errors
    } on NotFoundError catch (_) {
      await _respondNotFound(request, isDone);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, s) {
      // Its all broken, bail (but don't crash)
      log.onIncomingRequestException(e, s);
      final _onInternalError = onInternalError;
      if (_onInternalError != null) {
        // Handle the error with a custom response
        final dynamic result = await _onInternalError.process(request, request.response);
        if (result != null && !isDone) {
          await _handleResponse(result, request);
        }
        await request.response.close();
      } else {
        // Otherwise fall back to a generic 500 error.
        try {
          request.response.statusCode = 500;
          request.response.write(e);
          await request.response.close();
          // ignore: avoid_catches_without_on_clauses
        } catch (_) {}
      }
    }
  }

  /// Responds request with a NotFound response
  Future<dynamic> _respondNotFound(HttpRequest request, bool isDone) async {
    final _onNotFound = onNotFound;
    if (_onNotFound != null) {
      // Otherwise check if a custom 404 handler has been provided
      final result = await _onNotFound.process(request, request.response);
      if (result != null && !isDone) {
        await _handleResponse(result, request);
      }
      await request.response.close();
    } else {
      /// TODO this should be an injectable default.
      // Otherwise throw a generic 404;
      request.response.statusCode = 404;
      request.response.write('404 not found');
      await request.response.close();
    }
  }

  /// Handle a response by response type
  ///
  /// This is the logic that will handle the response based on what you return.
  Future<void> _handleResponse(dynamic result, HttpRequest request) async {
    if (result != null) {
      var handled = false;
      for (final handler in typeHandlers) {
        if (handler.shouldHandle(result)) {
          log.onApplyingTypeHandlerTo(handler, result.runtimeType);
          final dynamic handlerResult = await handler.handler(request, request.response, result);
          if (handlerResult != false) {
            handled = true;
            break;
          }
        }
      }
      if (!handled) {
        throw NoTypeHandlerError(result, request, this);
      }
    }
  }

  void _addRoute(
    String path,
    Middleware<Object?> callback,
    BuiltinMethod method, [
    List<Middleware<Object?>> middleware = const [],
  ]) =>
      routes.add(HttpRouteImpl(path, callback, method, middleware: middleware));
}

/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
/// Error thrown when a type handler cannot be found for a returned item
class NoTypeHandlerError implements Error {
  final dynamic object;
  final HttpRequest request;
  @override
  final StackTrace? stackTrace;
  final Alfred alfred;

  NoTypeHandlerError(this.object, this.request, this.alfred) : stackTrace = StackTrace.current;

  @override
  String toString() =>
      'No type handler found for ${object.runtimeType} / ${object.toString()} \nRoute: ${AlfredHttpRequestImpl(request, alfred).route}\nIf the app is running in production mode, the type name may be minified. Run it in debug mode to resolve';
}

/// Error used by middleware, utils or type handler to elevate
/// a NotFound response.
/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
class NotFoundError extends Error {}

class RouteMatcher {
  /// Trims all slashes at the start and end.
  static String _normalizePath(String self) {
    if (self.startsWith('/')) {
      return _normalizePath(self.substring('/'.length));
    } else if (self.endsWith('/')) {
      return _normalizePath(self.substring(0, self.length - '/'.length));
    } else {
      return self;
    }
  }

  static List<HttpRoute> match(String input, List<HttpRoute> options, Method method) {
    final output = <HttpRoute>[];
    final inputPath = _normalizePath(Uri.parse(input).path);
    for (final option in options) {
      // Check if http method matches.
      if (option.method == method || option.method == Methods.all) {
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
      throw const NotMatchingRouteException();
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
