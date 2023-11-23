import 'dart:async';
import 'dart:convert';

// TODO centralize this dependency
import 'dart:io';
import 'dart:typed_data';

import 'package:mime/mime.dart' as m;

// TODO remove this dependency.
import 'package:queue/queue.dart';

import '../base/header.dart';
import '../base/http_status_code.dart';
import '../base/method.dart';
import '../base/mime.dart';
import '../base/parse_method.dart';
import '../util/compose_path.dart';

// TODO don't depend on io.
import 'alfred_io.dart';
import 'interface.dart';
import 'middleware/default_404.dart';
import 'middleware/default_500.dart';

// TODO • rename to children.
// TODO • warn about duplicate URLs
// TODO   - compile to DFA and find ambiguities
// TODO   - handle patterns properly.
Future<BuiltAlfred> helloAlfred({
  required final Iterable<AlfredHttpRoute> routes,
  final int? port,
}) {
  final _alfred = alfredWithRoutes(
    routes: [
      AlfredRoutedRoutes(
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
  required final Iterable<AlfredRouted> routes,
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

AlfredImpl alfredWithRoutes({
  required final Iterable<AlfredRouted> routes,
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
  final AlfredMiddleware? onNotFound,
  final AlfredMiddleware Function(Object error)? onInternalError,
}) =>
    AlfredImpl.raw(
      routes: <AlfredHttpRoute>[],
      // TODO delegate for onNotFound and onInternalError with a default implementation.
      onNotFound: onNotFound ?? const NotFound404Middleware(),
      onInternalError: onInternalError ??
          (final a) => InternalError500Middleware(
                error: a,
              ),
    );

Future<BuiltAlfredIOImpl> makeAlfredImpl({
  required final ServerConfig config,
  required final AlfredLoggingDelegate log,
  required final Future<void> Function(HttpRequest request) requestHandler,
  required final AlfredImpl alfred,
}) async {
  final requestQueue = Queue(
    parallel: config.simultaneous_processing,
  );
  final server = await HttpServer.bind(
    config.bind_ip,
    config.port,
    shared: config.shared,
  )
    ..idleTimeout = config.idle_timeout
    ..autoCompress = true;
  // ignore: cancel_subscriptions, unused_local_variable
  final serverSubscription = server.listen(
    (final request) => requestQueue.add(
      () => requestHandler(request),
    ),
  );
  log.on_is_listening(
    arguments: config,
  );
  return BuiltAlfredIOImpl(
    requestQueue: requestQueue,
    server: server,
    args: config,
    alfred: alfred,
  );
}

class BuiltAlfredIOImpl implements BuiltAlfred {
  final HttpServer server;
  final Queue requestQueue;
  bool closed = false;
  @override
  final ServerConfig args;
  @override
  final Alfred alfred;

  BuiltAlfredIOImpl({
    required this.server,
    required this.requestQueue,
    required this.args,
    required this.alfred,
  });

  @override
  Future<dynamic> close({
    final bool force = true,
  }) async {
    if (!closed) {
      await server.close(
        force: force,
      );
      closed = true;
    } else {
      closed = false;
    }
  }
}

class AlfredImpl implements Alfred, AlfredHttpRouteFactory {
  @override
  final List<AlfredHttpRoute> routes;

  final AlfredMiddleware onNotFound;

  final AlfredMiddleware Function(Object error) onInternalError;

  AlfredImpl.raw({
    required this.routes,
    required this.onNotFound,
    required this.onInternalError,
  });

  @override
  AlfredHttpRouteFactory get router => this;

  @override
  Future<BuiltAlfredIOImpl> build({
    final AlfredLoggingDelegate log = const AlfredLoggingDelegatePrintImpl(),
    final ServerConfig config = const ServerConfigDefault(),
  }) async =>
      makeAlfredImpl(
        config: config,
        log: log,
        alfred: this,
        requestHandler: (final HttpRequest request) async {
          // Variable to track the close of the response.
          var isDone = false;
          log.on_incoming_request(
            method: request.method,
            uri: request.uri,
          );
          final res = AlfredResponseImpl(
            res: request.response,
          );
          final c = ServeContextIOImpl(
            alfred: this,
            req: AlfredRequestImpl(
              req: request,
              response: res,
            ),
            res: res,
          );
          // We track if the response has been resolved in order to exit out early
          // the list of routes (ie the middleware returned)
          unawaited(
            request.response.done.then(
              (final dynamic _) {
                isDone = true;
                log.on_response_sent();
              },
            ),
          );
          // Work out all the routes we need to process
          final matchedRoutes = matchRoute<AlfredHttpRoute>(
            input: request.uri.toString(),
            options: routes,
            method: parseHttpMethod(str: request.method) ?? Methods.get,
          );
          try {
            if (matchedRoutes.isEmpty) {
              log.on_no_matching_route_found();
              await onNotFound.process(c);
              await c.res.res.close();
            } else {
              // Tracks if one route is using a wildcard.
              var nonWildcardRouteMatch = false;
              // Loop through the routes in the order they are in the routes list
              for (final route in matchedRoutes) {
                c.route = route;
                if (!isDone) {
                  log.on_matching_route(
                    route: route.path,
                  );
                  nonWildcardRouteMatch = !route.uses_wildcard_matcher || nonWildcardRouteMatch;
                  // If the request has already completed, exit early, otherwise process
                  // the primary route callback.
                  // ignore: invariant_booleans, <- false positive
                  if (isDone) {
                    break;
                  } else {
                    log.on_execute_route_callback_function();
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
                    await c.res.res.close();
                  }
                }
                await request.response.close();
              }
            }
          } on AlfredException catch (e) {
            await e.match(
              NotFound: (final e) async {
                await onNotFound.process(c);
                await c.res.res.close();
              },
            );
          } on Object catch (e, s) {
            log.on_incoming_request_exception(
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
    required final AlfredRouted routes,
  }) =>
      routes.match(
        Routes: (final a) => this.routes.addAll(a.routes),
        At: (final a) => at(path: a.prefix).add(routes: a.routes),
      );
}

List<T> matchRoute<T extends AlfredHttpRouteDirections>({
  required final String input,
  required final List<T> options,
  required final Method method,
}) {
  final output = <T>[];
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

// TODO move back into separate subclasses.
const AlfredRoute = AlfredRoutesMaker();

// TODO rename middleware to child.
class AlfredRoutesMaker {
  const AlfredRoutesMaker();

  AlfredHttpRouteImpl post({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.post,
      );

  AlfredHttpRouteImpl get({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.get,
      );

  AlfredHttpRouteImpl put({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.put,
      );

  AlfredHttpRouteImpl delete({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.delete,
      );

  AlfredHttpRouteImpl options({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.options,
      );

  AlfredHttpRouteImpl patch({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.patch,
      );

  AlfredHttpRouteImpl all({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.all,
      );

  AlfredHttpRouteImpl head({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.head,
      );

  AlfredHttpRouteImpl connect({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.connect,
      );

  AlfredHttpRouteImpl trace({
    required final String path,
    required final AlfredMiddleware middleware,
  }) =>
      AlfredHttpRouteImpl(
        path: path,
        middleware: middleware,
        method: Methods.trace,
      );
}

class AlfredHttpRouteImpl with AlfredHttpRouteMixin {
  @override
  final String path;
  @override
  final BuiltinMethod method;
  @override
  final AlfredMiddleware middleware;

  const AlfredHttpRouteImpl({
    required this.path,
    required this.method,
    required this.middleware,
  });
}

mixin AlfredHttpRouteMixin implements AlfredHttpRoute, AlfredHttpRouteDirections {
  @override
  bool get uses_wildcard_matcher => path.contains('*');
}

Map<String, String>? getParams({
  required final String route,
  required final String input,
}) {
  final routeParts = route.split('/')..remove('');
  final inputParts = input.split('/')..remove('');
  if (inputParts.length != routeParts.length) {
    // TODO expose the reason for the empty map.
    return null;
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

class AlfredContentTypeImpl implements AlfredContentType {
  @override
  final String primary_type;

  @override
  final String sub_type;

  @override
  final String mime_type;

  @override
  final String? charset;

  final String? Function(String) getParam;

  const AlfredContentTypeImpl({
    required this.primary_type,
    required this.sub_type,
    required this.charset,
    required this.mime_type,
    required this.getParam,
  });

  @override
  String? get_parameter(
    final String key,
  ) =>
      getParam(key);
}

class ServerConfigImpl implements ServerConfig {
  @override
  final String bind_ip;
  @override
  final bool shared;
  @override
  final int port;
  @override
  final int simultaneous_processing;
  @override
  final Duration idle_timeout;

  const ServerConfigImpl({
    required this.bind_ip,
    required this.shared,
    required this.port,
    required this.simultaneous_processing,
    required this.idle_timeout,
  });
}

class ServerConfigDefault implements ServerConfig {
  static const String defaultBindIp = '0.0.0.0';
  static const int defaultPort = 80;
  static const int defaultSimultaneousProcessing = 50;
  static const bool defaultShared = true;
  static const Duration defaultIdleTimeout = Duration(seconds: 1);

  const ServerConfigDefault();

  @override
  String get bind_ip => defaultBindIp;

  @override
  int get port => defaultPort;

  @override
  bool get shared => defaultShared;

  @override
  int get simultaneous_processing => defaultSimultaneousProcessing;

  @override
  Duration get idle_timeout => defaultIdleTimeout;
}

class ServerConfigDefaultWithPort implements ServerConfig {
  @override
  final int port;

  const ServerConfigDefaultWithPort({
    required this.port,
  });

  @override
  String get bind_ip => ServerConfigDefault.defaultBindIp;

  @override
  bool get shared => ServerConfigDefault.defaultShared;

  @override
  int get simultaneous_processing => ServerConfigDefault.defaultSimultaneousProcessing;

  @override
  Duration get idle_timeout => ServerConfigDefault.defaultIdleTimeout;
}

class HttpRouteFactoryImpl implements AlfredHttpRouteFactory {
  final Alfred alfred;
  final String basePath;

  const HttpRouteFactoryImpl({
    required this.alfred,
    required this.basePath,
  });

  @override
  void add({
    required final AlfredRouted routes,
  }) {
    routes.match(
      Routes: (final _routes) {
        for (final route in _routes.routes) {
          alfred.router.add(
            routes: AlfredRoutedRoutes(
              routes: [
                AlfredHttpRouteImpl(
                  method: route.method,
                  path: composePath(
                    first: basePath,
                    second: route.path,
                  ),
                  middleware: route.middleware,
                ),
              ],
            ),
          );
        }
      },
      At: (final _at) => at(
        path: _at.prefix,
      ).add(
        routes: _at.routes,
      ),
    );
  }

  @override
  AlfredHttpRouteFactory at({
    required final String path,
  }) =>
      HttpRouteFactoryImpl(
        alfred: alfred,
        basePath: composePath(
          first: basePath,
          second: path,
        ),
      );
}

/// Indicates the severity of logged messages.
abstract class LogType {
  int get index;

  String get description;
}

class LogTypeDebug implements LogType {
  const LogTypeDebug();

  @override
  int get index => 1;

  @override
  String get description => "debug";

  @override
  String toString() => 'DebugLogType{}';
}

class LogTypeInfo implements LogType {
  const LogTypeInfo();

  @override
  int get index => 2;

  @override
  String get description => "info";

  @override
  String toString() => 'InfoLogType{}';
}

class LogTypeWarn implements LogType {
  const LogTypeWarn();

  @override
  int get index => 3;

  @override
  String get description => "warn";

  @override
  String toString() => 'WarnLogType{}';
}

class LogTypeError implements LogType {
  const LogTypeError();

  @override
  int get index => 4;

  @override
  String get description => "error";

  @override
  String toString() => 'ErrorLogType{}';
}

/// Maps from notifications about certain events to a log method.
mixin AlfredLoggingDelegateGeneralizingMixin implements AlfredLoggingDelegate {
  LogType get logLevel;

  void log({
    required final String Function() messageFn,
    required final LogType type,
  });

  @override
  void on_is_listening({
    required final ServerConfig arguments,
  }) =>
      log(
        messageFn: () =>
            'HTTP Server listening on port: ' +
            arguments.port.toString() +
            " • boundIp: " +
            arguments.bind_ip +
            " • shared: " +
            arguments.shared.toString() +
            " • simultaneousProcessing: " +
            arguments.simultaneous_processing.toString(),
        type: const LogTypeInfo(),
      );

  @override
  void on_incoming_request({
    required final String method,
    required final Uri uri,
  }) =>
      log(
        messageFn: () => method + ' - ' + uri.toString(),
        type: const LogTypeInfo(),
      );

  @override
  void on_response_sent() => log(
        messageFn: () => 'Response sent to client',
        type: const LogTypeDebug(),
      );

  @override
  void on_no_matching_route_found() => log(
        messageFn: () => 'No matching route found.',
        type: const LogTypeDebug(),
      );

  @override
  void on_matching_route({
    required final String route,
  }) =>
      log(
        messageFn: () => 'Match route: ' + route,
        type: const LogTypeDebug(),
      );

  @override
  void on_execute_route_callback_function() => log(
        messageFn: () => 'Execute route callback function',
        type: const LogTypeDebug(),
      );

  @override
  void on_incoming_request_exception({
    required final Object e,
    required final StackTrace s,
  }) {
    log(
      messageFn: () => e.toString(),
      type: const LogTypeError(),
    );
    log(
      messageFn: () => s.toString(),
      type: const LogTypeError(),
    );
  }

  @override
  void log_type_handler({
    required final String Function() msgFn,
  }) =>
      log(
        messageFn: () => 'DirectoryTypeHandler: ' + msgFn(),
        type: const LogTypeDebug(),
      );
}

class AlfredLoggingDelegatePrintImpl with AlfredLoggingDelegateGeneralizingMixin {
  @override
  final LogType logLevel;

  const AlfredLoggingDelegatePrintImpl([
    this.logLevel = const LogTypeDebug(),
  ]);

  @override
  void log({
    required final String Function() messageFn,
    required final LogType type,
  }) {
    if (type.index >= logLevel.index) {
      print(
        DateTime.now().toString() + ' - ' + type.description + ' - ' + messageFn(),
      );
    }
  }
}

/// Process and parse an incoming [HttpRequest].
///
/// The returned [AlfredHttpRequestBody] contains a `response` field for accessing the [HttpResponse].
///
/// See [AlfredHttpBodyHandler] for more info on [defaultEncoding].
Future<AlfredHttpRequestBody<dynamic>> processRequest(
  final AlfredRequest request,
  final AlfredResponse response, {
  final Encoding defaultEncoding = utf8,
}) async {
  try {
    final body = await _process(
      stream: request.stream,
      headers: request.headers,
      defaultEncoding: defaultEncoding,
    );
    return HttpRequestBodyImpl<dynamic>._(
      request,
      body,
    );
  } on Object catch (_) {
    // Try to send BAD_REQUEST response.
    response.set_status_code(httpStatusBadRequest400);
    await response.close();
    rethrow;
  }
}

/// Process and parse an incoming [HttpClientResponse].
///
/// See [AlfredHttpBodyHandler] for more info on [defaultEncoding].
Future<AlfredHttpClientResponseBody<dynamic>> processResponse(
  final HttpClientResponse response, {
  final Encoding defaultEncoding = utf8,
}) async {
  final body = await _process(
    stream: response,
    headers: AlfredHttpHeadersImpl(
      headers: response.headers,
    ),
    defaultEncoding: defaultEncoding,
  );
  return HttpClientResponseBodyImpl<dynamic>(
    response: response,
    httpBody: body,
  );
}

class HttpBodyHandlerImpl extends StreamTransformerBase<AlfredRequest, AlfredHttpRequestBody<dynamic>>
    implements AlfredHttpBodyHandler<dynamic> {
  final Encoding defaultEncoding;

  @override
  StreamTransformerBase<AlfredRequest, AlfredHttpRequestBody<dynamic>> get handler => this;

  /// Create a new [AlfredHttpBodyHandler] to be used with a [Stream]<[HttpRequest]>,
  /// e.g. a [HttpServer].
  ///
  /// If the page is served using different encoding than UTF-8, set
  /// [defaultEncoding] accordingly. This is required for parsing
  /// `multipart/form-data` content correctly. See the class comment
  /// for more information on `multipart/form-data`.
  const HttpBodyHandlerImpl(
    this.defaultEncoding,
  );

  @override
  Stream<AlfredHttpRequestBody<dynamic>> bind(
    final Stream<AlfredRequest> stream,
  ) {
    var pending = 0;
    var closed = false;
    return stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (final request, final sink) async {
          pending++;
          try {
            final body = await processRequest(
              request,
              request.response,
              defaultEncoding: defaultEncoding,
            );
            sink.add(body);
          } on Object catch (e, st) {
            sink.addError(e, st);
          } finally {
            pending--;
            if (closed && pending == 0) {
              sink.close();
            }
          }
        },
        handleDone: (final sink) {
          closed = true;
          if (pending == 0) {
            sink.close();
          }
        },
      ),
    );
  }
}

class HttpBodyImpl<T> implements AlfredHttpBody<T> {
  @override
  final String type;

  @override
  final T body;

  const HttpBodyImpl({
    required this.type,
    required this.body,
  });
}

class HttpClientResponseBodyImpl<T> implements AlfredHttpClientResponseBody<T> {
  @override
  final HttpClientResponse response;

  @override
  final AlfredHttpBody<T> httpBody;

  const HttpClientResponseBodyImpl({
    required this.response,
    required this.httpBody,
  });
}

class HttpRequestBodyImpl<T> implements AlfredHttpRequestBody<T> {
  @override
  final AlfredRequest request;
  @override
  final AlfredHttpBody<T> httpBody;

  const HttpRequestBodyImpl._(
    this.request,
    this.httpBody,
  );
}

class HttpBodyFileUploadImpl<T> implements AlfredHttpBodyFileUpload<T> {
  @override
  final String filename;
  @override
  final AlfredContentType? content_type;
  @override
  final T content;

  const HttpBodyFileUploadImpl._({
    required this.content_type,
    required this.filename,
    required this.content,
  });
}

Future<AlfredHttpBody<Object?>> _process({
  required final Stream<List<int>> stream,
  required final AlfredHttpHeaders headers,
  required final Encoding defaultEncoding,
}) async {
  Future<AlfredHttpBody<Uint8List>> asBinary() async {
    final builder = await stream.fold<BytesBuilder>(
      BytesBuilder(),
      (final builder, final data) => builder..add(data),
    );
    return HttpBodyImpl(
      type: 'binary',
      body: builder.takeBytes(),
    );
  }

  final contentType = headers.content_type;
  if (contentType == null) {
    return asBinary();
  } else {
    Future<AlfredHttpBody<String>> asText(
      final Encoding defaultEncoding,
    ) async {
      Encoding? encoding;
      final charset = contentType.charset;
      if (charset != null) {
        encoding = Encoding.getByName(charset);
      }
      encoding ??= defaultEncoding;
      final dynamic buffer = await encoding.decoder.bind(stream).fold<dynamic>(
            // ignore: avoid_dynamic_calls
            StringBuffer(), (final dynamic buffer, final data) => buffer..write(data),
          );
      return HttpBodyImpl(
        type: 'text',
        body: buffer.toString(),
      );
    }

    Future<AlfredHttpBody<Map<String, dynamic>>> asFormData() async {
      final values = await m.MimeMultipartTransformer(contentType.get_parameter('boundary')!).bind(stream).map(
        (final part) async {
          final multipart = parseHttpMultipartFormData(
            part,
            defaultEncoding: defaultEncoding,
          );
          Future<dynamic> make() async {
            if (multipart.isText) {
              final buffer = StringBuffer();
              // ignore: prefer_foreach
              await for (final dynamic val in multipart) {
                buffer.write(val);
              }
              return buffer.toString();
            } else {
              final builder = BytesBuilder();
              await for (final val in multipart) {
                if (val is List<int>) {
                  return builder.add(val);
                } else {
                  throw Exception("Expected d to be a list of integers.");
                }
              }
              return builder.takeBytes();
            }
          }

          final dynamic dataFirst = await make();
          final filename = multipart.contentDisposition.parameters['filename'];
          if (filename != null) {
            final _contentType = multipart.contentType;
            return <dynamic>[
              multipart.contentDisposition.parameters['name'],
              HttpBodyFileUploadImpl<dynamic>._(
                content_type: () {
                  if (_contentType != null) {
                    return AlfredContentTypeFromContentTypeImpl(
                      contentType: _contentType,
                    );
                  } else {
                    return null;
                  }
                }(),
                filename: filename,
                content: dataFirst,
              ),
            ];
          } else {
            return <dynamic>[
              multipart.contentDisposition.parameters['name'],
              dataFirst,
            ];
          }
        },
      ).toList();
      final parts = await Future.wait<List<dynamic>>(values);
      final body = <String, dynamic>{
        for (final part in parts) //
          () {
            final dynamic firstPart = part[0];
            if (firstPart is String) {
              return firstPart;
            } else {
              throw Exception("Expected first part to be of type String.");
            }
          }(): part[1], // Override existing entries.
      };
      return HttpBodyImpl(
        type: 'form',
        body: body,
      );
    }

    // TODO centralize primary type constants.
    switch (contentType.primary_type) {
      case 'text':
        return asText(defaultEncoding);
      case 'application':
        switch (contentType.sub_type) {
          case 'json':
            final body = await asText(utf8);
            return HttpBodyImpl(
              type: 'json',
              body: jsonDecode(body.body),
            );
          case 'x-www-form-urlencoded':
            final body = await asText(ascii);
            final map = Uri.splitQueryString(
              body.body,
              encoding: defaultEncoding,
            );
            final result = <dynamic, dynamic>{};
            for (final key in map.keys) {
              result[key] = map[key];
            }
            return HttpBodyImpl(
              type: 'form',
              body: result,
            );
          default:
            break;
        }
        break;
      case 'multipart':
        switch (contentType.sub_type) {
          case 'form-data':
            return asFormData();
          default:
            break;
        }
        break;
      default:
        break;
    }
    return asBinary();
  }
}

/// The data in a `multipart/form-data` part.
///
/// ## Example
///
/// ```dart
/// HttpServer server = ...;
/// server.listen((request) {
///   var boundary = request.headers.contentType.parameters['boundary'];
///   request
///       .transform(MimeMultipartTransformer(boundary))
///       .map(HttpMultipartFormData.parse)
///       .map((HttpMultipartFormData formData) {
///         // form data object available here.
///       });
/// ```
///
/// [HttpMultipartFormData] is a Stream, serving either bytes or decoded
/// Strings. Use [isText] or [isBinary] to see what type of data is provided.
class HttpMultipartFormData extends Stream<dynamic> {
  /// The parsed `Content-Type` header value.
  ///
  /// `null` if not present.
  final ContentType? contentType;

  /// The parsed `Content-Disposition` header value.
  ///
  /// This field is always present. Use this to extract e.g. name (form field
  /// name) and filename (client provided name of uploaded file) parameters.
  final HeaderValue contentDisposition;

  /// The parsed `Content-Transfer-Encoding` header value.
  ///
  /// This field is used to determine how to decode the data. Returns `null`
  /// if not present.
  final HeaderValue? contentTransferEncoding;

  /// Whether the data is decoded as [String].
  final bool isText;

  /// Whether the data is raw bytes.
  bool get isBinary => !isText;

  final m.MimeMultipart mimeMultipart;

  final Stream<dynamic> stream;

  HttpMultipartFormData({
    required this.contentType,
    required this.contentDisposition,
    required this.contentTransferEncoding,
    required this.mimeMultipart,
    required this.stream,
    required this.isText,
  });

  @override
  StreamSubscription<dynamic> listen(
    final void Function(dynamic)? onData, {
    final void Function()? onDone,
    final Function? onError,
    final bool? cancelOnError,
  }) =>
      stream.listen(
        onData,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError,
      );

  /// Returns the value for the header named [name].
  ///
  /// If there is no header with the provided name, `null` will be returned.
  ///
  /// Use this method to index other headers available in the original
  /// MimeMultipart.
  String? value(
    final String name,
  ) =>
      mimeMultipart.headers[name];
}

/// Parse a MimeMultipart and return a [HttpMultipartFormData].
///
/// If the `Content-Disposition` header is missing or invalid, an
/// [HttpException] is thrown.
///
/// If the MimeMultipart is identified as text, and the `Content-Type`
/// header is missing, the data is decoded using [defaultEncoding]. See more
/// information in the
/// [HTML5 spec](http://dev.w3.org/html5/spec-preview/
/// constraints.html#multipart-form-data).
HttpMultipartFormData parseHttpMultipartFormData(
  final m.MimeMultipart multipart, {
  final Encoding defaultEncoding = utf8,
}) {
  // The values which indicate that no encoding was performed.
  //
  // https://www.w3.org/Protocols/rfc1341/5_Content-Transfer-Encoding.html
  const _transparentEncodings = ['7bit', '8bit', 'binary'];

  ContentType? contentType;
  HeaderValue? encoding;
  HeaderValue? disposition;
  for (final key in multipart.headers.keys) {
    switch (key) {
      case httpHeaderContentType:
        contentType = ContentType.parse(
          multipart.headers[key]!,
        );
        break;
      case 'content-transfer-encoding':
        encoding = HeaderValue.parse(
          multipart.headers[key]!,
        );
        break;
      case 'content-disposition':
        disposition = HeaderValue.parse(
          multipart.headers[key]!,
          preserveBackslash: true,
        );
        break;
      default:
        break;
    }
  }
  if (disposition == null) {
    throw const HttpException("Mime Multipart doesn't contain a Content-Disposition header value");
  } else {
    if (encoding != null && !_transparentEncodings.contains(encoding.value.toLowerCase())) {
      // TODO(ajohnsen): Support BASE64, etc.
      throw HttpException('Unsupported contentTransferEncoding: ' + encoding.value);
    } else {
      Stream<dynamic> stream = multipart;
      final isText = contentType == null ||
          contentType.primaryType == 'text' ||
          contentType.mimeType == 'application/json';
      if (isText) {
        Encoding? encoding;
        if (contentType?.charset != null) {
          encoding = Encoding.getByName(contentType!.charset);
        }
        encoding ??= defaultEncoding;
        stream = stream.transform<dynamic>(encoding.decoder);
      }
      return HttpMultipartFormData(
        contentType: contentType,
        contentDisposition: disposition,
        contentTransferEncoding: encoding,
        mimeMultipart: multipart,
        stream: stream,
        isText: isText,
      );
    }
  }
}

/// Get the contentType header from the given file.
AlfredContentType? fileContentType({
  required final String filePath,
}) {
  // Get the mimeType as a string from the name of the given file.
  final mimeType = mime(filePath);
  if (mimeType != null) {
    final split = mimeType.split('/');
    return AlfredContentTypeImpl(
      mime_type: mimeType,
      primary_type: split[0],
      sub_type: split[1],
      charset: null,
      getParam: (final _) => null,
    );
  } else {
    return null;
  }
}
