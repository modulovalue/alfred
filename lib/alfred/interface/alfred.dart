import 'dart:async';
import 'dart:io';

import 'package:queue/queue.dart';

import '../../http_route/interface/http_route.dart';
import '../../logging/interface/logging_delegate.dart';
import '../../middleware/interface/middleware.dart';
import '../../store/interface/store.dart';
import '../../type_handler/interface/type_handler.dart';

/// Server application class
///
/// This is the core of the server application. Generally you would create one
/// for each app.
/// TODO error delegate on not found and on internal error
abstract class Alfred {
  /// List of routes
  ///
  /// Generally you don't want to manipulate this array directly, instead add
  /// routes by calling the [get,post,put,delete] methods.
  List<HttpRoute> get routes;

  StorePluginData get store;

  /// An array of [TypeHandler] that Alfred walks through in order to determine
  /// if it can handle a value returned from a route.
  List<TypeHandler<dynamic>> get typeHandlers;

  /// Incoming request queue
  ///
  /// Set the number of simultaneous connections being processed at any one time
  /// in the [simultaneousProcessing] param in the constructor
  Queue get requestQueue;

  /// HttpServer instance from the dart:io library
  ///
  /// If there is anything the app can't do, you can do it through here.
  HttpServer? get server;

  /// Writer to handle internal logging.
  AlfredLoggingDelegate get log;

  /// Optional handler for when a route is not found
  Middleware<Object?>? get onNotFound;

  /// Optional handler for when the server throws an unhandled error
  Middleware<Object?>? get onInternalError;

  /// Register a listener when a request is complete
  ///
  /// Typically would be used for logging, benchmarking or cleaning up data
  /// used when writing a plugin.
  void registerOnDoneListener(void Function(HttpRequest, HttpResponse) listener);

  /// Dispose of any on done listeners when you are done with them.
  void removeOnDoneListener(void Function(HttpRequest req, HttpResponse res) listener);

  /// Create a get route
  void get(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a post route
  void post(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a put route
  void put(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a delete route
  void delete(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a patch route
  void patch(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create an options route
  void options(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Create a route that listens on all methods
  void all(
    String path,
    Middleware<Object?> callback, {
    List<Middleware<Object?>> middleware,
  });

  /// Call this function to fire off the server.
  Future<HttpServer> listen([int port, dynamic bindIp, bool shared]);

  /// Close the server and clean up any resources.
  ///
  /// Call this if you are shutting down the server
  /// but continuing to run the app.
  Future<dynamic> close({bool force});

  /// Print out the registered routes to the console.
  ///
  /// Helpful to see whats available.
  void printRoutes();

  /// Creates one or multiple route segments that can be used
  /// as a common base for specifying routes with [get], [post], etc.
  ///
  /// You can define middleware that effects all sub-routes.
  HttpRouteFactory route(
    String path, {
    List<Middleware<Object?>> middleware,
  });
}
