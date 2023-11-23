import 'dart:async';

// TODO enum here.
import '../base/method.dart';

/// Server application class
///
/// This is the core of the server application. Generally you would create one
/// for each app.
abstract class Alfred {
  /// List of routes.
  ///
  /// Generally you don't want to manipulate this array directly, instead add
  /// routes by calling the [get,post,put,delete] methods.
  Iterable<AlfredHttpRoute> get routes;

  /// Methods to add new routes.
  AlfredHttpRouteFactory get router;

  /// Call this function to fire off the server.
  Future<BuiltAlfred> build({
    final AlfredLoggingDelegate log,
    final ServerConfig config,
  });
}

abstract class BuiltAlfred {
  /// The server settings that were used to configure
  /// this build.
  ServerConfig get args;

  // TODO alfred can be built, this is a built alfred it should not be able to build alfred again.
  // TODO have alfred properties in Alfred and expose them here?
  /// The Alfred configuration that lead to this build.
  Alfred get alfred;

  /// Close the server and clean up any resources.
  ///
  /// Call this if you are shutting down the server
  /// but continuing to run the app.
  Future<dynamic> close({
    final bool force,
  });
}

abstract class ServerConfig {
  /// The number of requests doing work at any one
  /// time. If the amount of unprocessed incoming
  /// requests exceed this number, the requests will
  /// be queued.
  int get simultaneous_processing;

  Duration get idle_timeout;

  int get port;

  // TODO replace with [InternetAddress]?
  String get bind_ip;

  bool get shared;
}

/// A base exception for this package.
abstract class AlfredException implements Exception {
  Z match<Z>({
    required final Z Function(AlfredNotFoundException) NotFound,
  });
}

/// Error used by middleware, utils or type handler to elevate
/// a NotFound response.
abstract class AlfredNotFoundException implements AlfredException {}

abstract class AlfredHttpRouteFactory {
  /// Adds a [AlfredRouted] route.
  void add({
    required final AlfredRouted routes,
  });

  /// As a common base for specifying further
  /// routes.
  AlfredHttpRouteFactory at({
    required final String path,
  });
}

abstract class AlfredHttpRouteDirections {
  String get path;

  BuiltinMethod get method;
}

abstract class AlfredHttpRoute implements AlfredHttpRouteDirections {
  AlfredMiddleware get middleware;

  /// Returns `true` if route can match multiple
  /// routes due to usage of wildcards (`*`).
  bool get uses_wildcard_matcher;
}

abstract class AlfredMiddleware {
  Future<void> process(
    final ServeContext c,
  );
}

abstract class ServeContext {
  AlfredRequest get req;

  AlfredResponse get res;

  Alfred get alfred;

  /// Parse the body automatically and return the result.
  Future<Object?> get body;

  /// Get arguments.
  Map<String, String>? get arguments;

  /// Will not be available in 404 responses.
  AlfredHttpRoute get route;
}

abstract class AlfredRequest {
  Future<AlfredWebSocket> upgrade_to_websocket();

  Stream<List<int>> get stream;

  AlfredResponse get response;

  Uri get uri;

  String get method;

  AlfredHttpHeaders get headers;

  String? get mime_type;
}

abstract class AlfredHttpHeaders {
  String? get content_type_mime_type;

  AlfredContentType? get content_type;

  String? get host;

  String? get_value(
    final String key,
  );
}

abstract class AlfredContentType {
  String get primary_type;

  String get sub_type;

  String? get charset;

  String get mime_type;

  String? get_parameter(
    final String key,
  );
}

abstract class AlfredWebSocket {
  StreamSubscription<dynamic> listen({
    required final void Function(dynamic event)? on_data,
    required final Function? on_error,
    required final void Function()? on_done,
    required final bool? cancel_on_error,
  });

  void add_string(
    final String string,
  );

  void add_bytes(
    final List<int> bytes,
  );

  Future<void> close({
    required final int? code,
    required final String? reason,
  });
}

abstract class AlfredResponse {
  void set_status_code(
    final int status_code,
  );

  void set_header_string(
    final String key,
    final String value,
  );

  void set_header_integer(
    final String key,
    final int value,
  );

  Future<void> close();

  String? get mime_type;

  void write_string(
    final String s,
  );

  void write_bytes(
    final List<int> bytes,
  );

  Future<void> write_byte_stream(
    final Stream<List<int>> stream,
  );

  Future<void> redirect(
    final Uri uri,
  );

  void set_content_type(
    final AlfredContentType? detected_content_type,
  );

  void set_content_type_binary();

  void set_content_type_json();

  void set_content_type_html();
}

abstract class AlfredRouted {
  Z match<Z>({
    required final Z Function(AlfredRoutedRoutes) Routes,
    required final Z Function(AlfredRoutesAt) At,
  });
}

class AlfredRoutedRoutes implements AlfredRouted {
  final Iterable<AlfredHttpRoute> routes;

  const AlfredRoutedRoutes({
    required this.routes,
  });

  @override
  Z match<Z>({
    required final Z Function(AlfredRoutedRoutes p1) Routes,
    required final Z Function(AlfredRoutesAt p1) At,
  }) =>
      Routes(this);
}

class AlfredRoutesAt implements AlfredRouted {
  final String prefix;
  final AlfredRouted routes;

  const AlfredRoutesAt({
    required this.prefix,
    required this.routes,
  });

  @override
  Z match<Z>({
    required final Z Function(AlfredRoutedRoutes p1) Routes,
    required final Z Function(AlfredRoutesAt p1) At,
  }) =>
      At(this);
}

/// A handler for processing and collecting HTTP message data in to an
/// [AlfredHttpBody].
///
/// The content body is parsed, depending on the `Content-Type` header field.
/// When the full body is read and parsed the body content is made available.
/// The class can be used to process both server requests and client responses.
///
/// The following content types are recognized:
///
/// - text/*
/// - application/json
/// - application/x-www-form-urlencoded
/// - multipart/form-data
///
/// For content type `text/*` the body is decoded into a string. The
/// 'charset' parameter of the content type specifies the encoding
/// used for decoding. If no 'charset' is present the default encoding
/// of ISO-8859-1 is used.
///
/// For content type `application/json` the body is decoded into a
/// string which is then parsed as JSON. The resulting body is a
/// [Map].  The 'charset' parameter of the content type specifies the
/// encoding used for decoding. If no 'charset' is present the default
/// encoding of UTF-8 is used.
///
/// For content type `application/x-www-form-urlencoded` the body is a
/// query string which is then split according to the rules for
/// splitting a query string. The resulting body is a `Map<String,
/// String>`.  If the same name is present several times in the query
/// string, then the last value seen for this name will be in the
/// resulting map. The encoding US-ASCII is always used for decoding
/// the body.
///
/// For content type `multipart/form-data` the body is parsed into
/// it's different fields. The resulting body is a `Map<String,
/// dynamic>`, where the value is a [String] for normal fields and a
/// [AlfredHttpBodyFileUpload] instance for file upload fields. If the same
/// name is present several times, then the last value seen for this
/// name will be in the resulting map.
///
/// When using content type `multipart/form-data` the encoding of
/// fields with [String] values is determined by the browser sending
/// the HTTP request with the form data. The encoding is specified
/// either by the attribute `accept-charset` on the HTML form, or by
/// the content type of the web page containing the form. If the HTML
/// form has an `accept-charset` attribute the browser will use the
/// encoding specified there. If the HTML form has no `accept-charset`
/// attribute the browser determines the encoding from the content
/// type of the web page containing the form. Using a content type of
/// `text/html; charset=utf-8` for the page and setting
/// `accept-charset` on the HTML form to `utf-8` is recommended as the
/// default for [AlfredHttpBodyHandler] is UTF-8. It is important to get
/// these encoding values right, as the actual `multipart/form-data`
/// HTTP request sent by the browser does _not_ contain any
/// information on the encoding. If something else than UTF-8 is used
/// `defaultEncoding` needs to be set in the [AlfredHttpBodyHandler]
/// constructor and calls to processRequest and processResponse.
///
/// For all other content types the body will be treated as
/// uninterpreted binary data. The resulting body will be of type
/// `List<int>`.
///
/// To use with the HttpServer for request messages, [AlfredHttpBodyHandler] can be
/// used as either a [StreamTransformer] or as a per-request handler (see
/// processRequest).
///
/// ```dart
/// HttpServer server = ...
/// server.transform(HttpBodyHandler())
///     .listen((HttpRequestBody body) {
///       ...
///     });
/// ```
///
/// To use with the HttpClient for response messages, [AlfredHttpBodyHandler] can be
/// used as a per-request handler (see processResponse).
///
/// ```dart
/// HttpClient client = ...
/// var request = await client.get(...);
/// var response = await request.close();
/// var body = HttpBodyHandler.processResponse(response);
/// ```
abstract class AlfredHttpBodyHandler<T> {
  StreamTransformer<AlfredRequest, AlfredHttpRequestBody<T>> get handler;
}

/// A HTTP content body produced by [AlfredHttpBodyHandler] for either HttpRequest
/// or HttpClientResponse.
abstract class AlfredHttpBody<T> {
  /// A high-level type value, that reflects how the body was parsed, e.g.
  /// "text", "binary" and "json".
  String get type;

  /// The content of the body with a type depending on [type].
  T get body;
}

/// The body of a HttpClientResponse.
///
/// Headers can be read through the original [response].
abstract class AlfredHttpClientResponseBody<T> {
  /// The wrapped response.
  Stream<List<int>> get response;

  AlfredHttpBody<T> get httpBody;
}

/// The body of a HttpRequest.
///
/// Headers can be read, and a response can be sent, through [request].
abstract class AlfredHttpRequestBody<T> {
  /// The wrapped request.
  ///
  /// Note that the HttpRequest is already drained, so the
  /// `Stream` methods cannot be used.
  AlfredRequest get request;

  AlfredHttpBody<T> get httpBody;
}

/// A wrapper around a file upload.
abstract class AlfredHttpBodyFileUpload<T> {
  /// The filename of the uploaded file.
  String get filename;

  /// The [AlfredContentType] of the uploaded file.
  ///
  /// For `text/*` and `application/json` the [content] field will a String.
  AlfredContentType? get content_type;

  /// The content of the file.
  ///
  /// Either a [String] or a [List<int>].
  T get content;
}

abstract class AlfredLoggingDelegate {
  void on_is_listening({
    required final ServerConfig arguments,
  });

  void on_incoming_request({
    required final String method,
    required final Uri uri,
  });

  void on_matching_route({
    required final String route,
  });


  void on_incoming_request_exception({
    required final Object e,
    required final StackTrace s,
  });

  void log_type_handler({
    required final String Function() msgFn,
  });

  void on_response_sent();

  void on_no_matching_route_found();

  void on_execute_route_callback_function();
}
