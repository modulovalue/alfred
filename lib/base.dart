import 'dart:async';
import 'dart:io';

import 'package:queue/queue.dart';

import 'extensions.dart';
import 'http_route.dart';
import 'logging/impl/generalizing/log_type.dart';
import 'logging/impl/generalizing/print.dart';
import 'logging/interface/logging_delegate.dart';
import 'method.dart';
import 'middleware/interface/middleware.dart';
import 'plugin_store.dart';
import 'type_handler/impl/directory.dart';
import 'type_handler/impl/file.dart';
import 'type_handler/impl/json_list.dart';
import 'type_handler/impl/json_map.dart';
import 'type_handler/impl/list_of_ints.dart';
import 'type_handler/impl/serializable.dart';
import 'type_handler/impl/stream_of_list_of_integers.dart';
import 'type_handler/impl/string.dart';
import 'type_handler/impl/websocket/impl.dart';
import 'type_handler/interface/type_handler.dart';

/// Server application class
///
/// This is the core of the server application. Generally you would create one
/// for each app.
/// TODO split into interface and impl.
class Alfred {
  /// List of routes
  ///
  /// Generally you don't want to manipulate this array directly, instead add
  /// routes by calling the [get,post,put,delete] methods.
  final List<HttpRoute> routes;

  /// An array of [TypeHandler] that Alfred walks through in order to determine
  /// if it can handle a value returned from a route.
  final List<TypeHandler<dynamic>> typeHandlers;

  final List<void Function(HttpRequest req, HttpResponse res)> _onDoneListeners;

  /// Incoming request queue
  ///
  /// Set the number of simultaneous connections being processed at any one time
  /// in the [simultaneousProcessing] param in the constructor
  final Queue requestQueue;

  /// HttpServer instance from the dart:io library
  ///
  /// If there is anything the app can't do, you can do it through here.
  HttpServer? server;

  /// Writer to handle internal logging.
  final AlfredLoggingDelegate LOG;

  /// Optional handler for when a route is not found
  /// TODO put into a delegate.
  Middleware<Object?>? onNotFound;

  /// Optional handler for when the server throws an unhandled error
  /// TODO put into a delegate.
  Middleware<Object?>? onInternalError;

  static const AlfredLoggingDelegate defaultLogger = AlfredLoggingDelegatePrintImpl(LogType.info);

  /// Creates a new Alfred application.
  ///
  /// The default [logWriter] can be tuned by changing the [logLevel]:
  /// - [LogType.error]: prints errors
  /// - [LogType.warn]: prints errors and warning
  /// - [LogType.info]: prints errors, warning and requests
  /// - [LogType.debug]: prints errors, warning, requests and further details
  ///
  /// *Note: Changing the [logLevel] only effects the default [logWriter].*
  ///
  /// [simultaneousProcessing] is the number of requests doing work at any one
  /// time. If the amount of unprocessed incoming requests exceed this number,
  /// the requests will be queued.
  Alfred({
    this.onNotFound,
    this.onInternalError,
    this.LOG = defaultLogger,
    int simultaneousProcessing = 50,
  })  : routes = <HttpRoute>[],
        requestQueue = Queue(parallel: simultaneousProcessing),
        _onDoneListeners = [StorePluginData.singleton.storePluginOnDoneHandler],

        /// TODO collect default type handler list somewhere.
        typeHandlers = <TypeHandler<dynamic>>[
          const TypeHandlerStringImpl(),
          const TypeHandlerListOfIntegersImpl(),
          const TypeHandlerStreamOfListOfIntegersImpl(),
          const TypeHandlerJsonListImpl(),
          const TypeHandlerJsonMapImpl(),
          const TypeHandlerFileImpl(),
          const TypeHandlerDirectoryImpl(),
          const TypeHandlerWebsocketImpl(),
          const TypeHandlerSerializableImpl()
        ];

  /// Register a listener when a request is complete
  ///
  /// Typically would be used for logging, benchmarking or cleaning up data
  /// used when writing a plugin.
  void registerOnDoneListener(
    void Function(HttpRequest, HttpResponse) listener,
  ) =>
      _onDoneListeners.add(listener);

  /// Dispose of any on done listeners when you are done with them.
  void removeOnDoneListener(
    Function listener,
  ) =>
      _onDoneListeners.remove(listener);

  /// Create a get route
  HttpRoute get(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.get, middleware);

  /// Create a post route
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
  HttpRoute delete(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.delete, middleware);

  /// Create a patch route
  HttpRoute patch(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.patch, middleware);

  /// Create an options route
  HttpRoute options(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.options, middleware);

  /// Create a route that listens on all methods
  HttpRoute all(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      _createRoute(path, callback, Method.all, middleware);

  HttpRoute _createRoute(
    String path,
    Middleware<Object?> callback,
    Method method, [
    List<Middleware<Object?>> middleware = const [],
  ]) {
    final route = HttpRoute(path, callback, method, middleware: middleware);
    routes.add(route);
    return route;
  }

  /// Call this function to fire off the server.
  Future<HttpServer> listen([
    /// TODO make use provide defaults explicitly via a custom model and a default implementation.
    int port = 3000,
    dynamic bindIp = '0.0.0.0',
    bool shared = true,
  ]) async {
    final _server = await HttpServer.bind(bindIp, port, shared: shared);
    _server.idleTimeout = const Duration(seconds: 1);
    _server.listen((HttpRequest request) {
      requestQueue.add(() => _incomingRequest(request));
    });
    LOG.onIsListening(_server.port);
    return server = _server;
  }

  /// Handles and routes an incoming request
  Future<void> _incomingRequest(HttpRequest request) async {
    /// Expose this Alfred instance for middleware or other utility functions
    request.store.set('_internal_alfred', this);

    /// Variable to track the close of the response
    var isDone = false;
    LOG.onIncomingRequest(request.method, request.uri);
    // We track if the response has been resolved in order to exit out early
    // the list of routes (ie the middleware returned)
    _unawaited(request.response.done.then((dynamic _) {
      isDone = true;
      for (final listener in _onDoneListeners) {
        listener(request, request.response);
      }
      LOG.onResponseSent();
    }));
    // Work out all the routes we need to process
    final effectiveRoutes = RouteMatcher.match(
      request.uri.toString(),
      routes,
      Method.tryParse(request.method) ?? Method.get,
    );
    try {
      // If there are no effective routes, that means we need to throw a 404
      // or see if there are any static routes to fall back to, otherwise
      // continue and process the routes
      if (effectiveRoutes.isEmpty) {
        LOG.onNoMatchingRouteFound();
        await _respondNotFound(request, isDone);
      } else {
        // Tracks if one route is using a wildcard.
        var nonWildcardRouteMatch = false;
        // Loop through the routes in the order they are in the routes list
        for (final route in effectiveRoutes) {
          if (isDone) {
            break;
          } else {
            LOG.onMatchingRoute(route.route);
            request.store.set('_internal_route', route.route);
            nonWildcardRouteMatch = !route.usesWildcardMatcher || nonWildcardRouteMatch;
            // Loop through any middleware.
            for (final middleware in route.middleware) {
              // If the request has already completed, exit early.
              // ignore: invariant_booleans, <- false positive
              if (isDone) {
                break;
              } else {
                LOG.onApplyMiddleware();
                await _handleResponse(await middleware.process(request, request.response), request);
              }
            }
            // If the request has already completed, exit early, otherwise process
            // the primary route callback.
            // ignore: invariant_booleans, <- false positive
            if (isDone) {
              break;
            } else {
              LOG.onExecuteRouteCallbackFunction();
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
      LOG.onIncomingRequestException(e, s);
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
      final dynamic result = await _onNotFound.process(request, request.response);
      if (result != null && !isDone) {
        await _handleResponse(result, request);
      }
      await request.response.close();
    } else {
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
          LOG.onApplyingTypeHandlerTo(handler, result.runtimeType);
          final dynamic handlerResult = await handler.handler(request, request.response, result);
          if (handlerResult != false) {
            handled = true;
            break;
          }
        }
      }
      if (!handled) {
        throw NoTypeHandlerError(result, request);
      }
    }
  }

  /// Close the server and clean up any resources.
  ///
  /// Call this if you are shutting down the server
  /// but continuing to run the app.
  Future<dynamic> close({bool force = true}) async {
    if (server != null) {
      await server!.close(force: force);
    }
  }

  /// Print out the registered routes to the console.
  ///
  /// Helpful to see whats available.
  void printRoutes() {
    for (final route in routes) {
      late String methodString;
      switch (route.method) {
        case Method.get:
          methodString = '\x1B[33mGET\x1B[0m';
          break;
        case Method.post:
          methodString = '\x1B[31mPOST\x1B[0m';
          break;
        case Method.put:
          methodString = '\x1B[32mPUT\x1B[0m';
          break;
        case Method.delete:
          methodString = '\x1B[34mDELETE\x1B[0m';
          break;
        case Method.patch:
          methodString = '\x1B[35mPATCH\x1B[0m';
          break;
        case Method.options:
          methodString = '\x1B[36mOPTIONS\x1B[0m';
          break;
        case Method.all:
          methodString = '\x1B[37mALL\x1B[0m';
          break;
      }
      print('${route.route} - $methodString');
    }
  }

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying routes with [get], [post], etc.
  ///
  /// You can define middleware that effects all sub-routes.
  NestedRoute route(
    String path, {
    List<Middleware<Object?>> middleware = const [],
  }) =>
      NestedRoute(alfred: this, basePath: path, baseMiddleware: middleware);
}

/// TODO move to its own file.
/// Function to prevent linting errors.
void _unawaited(Future<Null> then) {}

/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
/// Error thrown when a type handler cannot be found for a returned item
class NoTypeHandlerError implements Error {
  final dynamic object;
  final HttpRequest request;
  @override
  final StackTrace? stackTrace;

  NoTypeHandlerError(this.object, this.request) : stackTrace = StackTrace.current;

  @override
  String toString() =>
      'No type handler found for ${object.runtimeType} / ${object.toString()} \nRoute: ${request.route}\nIf the app is running in production mode, the type name may be minified. Run it in debug mode to resolve';
}

/// Error used by middleware, utils or type handler to elevate
/// a NotFound response.
/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
class NotFoundError extends Error {}

/// Throw these exceptions to bubble up an error from sub functions and have them
/// handled automatically for the client
/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
class AlfredException implements Exception {
  /// The response to send to the client
  final Object? response;

  /// The statusCode to send to the client
  final int statusCode;

  const AlfredException(this.statusCode, this.response);
}
