import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'base.dart';
import 'extensions.dart';

abstract class TypeHandler<T> {
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    T value,
  );

  bool shouldHandle(dynamic item);
}

mixin TypeHandlerShouldHandleMixin<T> implements TypeHandler<T> {
  @override
  bool shouldHandle(dynamic item) => item is T;
}

class TypeHandlerListOfIntegersImpl with TypeHandlerShouldHandleMixin<List<int>> {
  const TypeHandlerListOfIntegersImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    List<int> value,
  ) async {
    if (res.headers.contentType == null || res.headers.contentType!.value == 'text/plain') {
      res.headers.contentType = ContentType.binary;
    }
    res.add(value);
    await res.close();
  }
}

class TypeHandlerStreamOfListOfIntegersImpl with TypeHandlerShouldHandleMixin<Stream<List<int>>> {
  const TypeHandlerStreamOfListOfIntegersImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Stream<List<int>> val,
  ) async {
    if (res.headers.contentType == null || res.headers.contentType!.value == 'text/plain') {
      res.headers.contentType = ContentType.binary;
    }
    await res.addStream(val);
    await res.close();
  }
}

class TypeHandlerDirectoryImpl with TypeHandlerShouldHandleMixin<Directory> {
  static void _log(HttpRequest req, String Function() msgFn) =>
      req.alfred.logWriter(() => 'DirectoryTypeHandler: ${msgFn()}', LogType.debug);

  const TypeHandlerDirectoryImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Directory directory,
  ) async {
    final usedRoute = req.route;
    assert(
      usedRoute.contains('*'),
      'TypeHandler of type Directory needs a route declaration that contains a wildcard (*). Found: $usedRoute',
    );
    final virtualPath = req.uri.path.substring(min(req.uri.path.length, usedRoute.indexOf('*')));
    final filePath = '${directory.path}/$virtualPath';
    _log(req, () => 'Resolve virtual path: $virtualPath');
    final fileCandidates = <File>[
      File(filePath),
      File('$filePath/index.html'),
      File('$filePath/index.htm'),
    ];
    try {
      final match = fileCandidates.firstWhere((file) => file.existsSync());
      _log(req, () => 'Respond with file: ${match.path}');
      res.setContentTypeFromFile(match);
      await res.addStream(match.openRead());
      await res.close();
      // ignore: avoid_catching_errors
    } on StateError {
      _log(req, () => 'Could not match with any file. Expected file at: $filePath');
    }
  }
}

class TypeHandlerFileImpl with TypeHandlerShouldHandleMixin<File> {
  const TypeHandlerFileImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    File file,
  ) async {
    if (file.existsSync()) {
      res.setContentTypeFromFile(file);
      await res.addStream(file.openRead());
      return res.close();
    } else {
      throw NotFoundError();
    }
  }
}

class TypeHandlerSerializableImpl with TypeHandlerShouldHandleMixin<dynamic> {
  const TypeHandlerSerializableImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    dynamic value,
  ) {
    try {
      // ignore: avoid_dynamic_calls
      final dynamic toJsonCall = value.toJson;
      if (toJsonCall != null) {
        // ignore: avoid_dynamic_calls
        res.write(jsonEncode(toJsonCall()));
        return res.close();
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!e.toString().contains('has no instance getter')) {
        rethrow;
      }
    }
    try {
      // ignore: avoid_dynamic_calls
      final dynamic toJSONCall = value.toJSON;
      if (toJSONCall != null) {
        // ignore: avoid_dynamic_calls
        res.write(jsonEncode(toJSONCall()));
        return res.close();
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (!e.toString().contains('has no instance getter')) {
        rethrow;
      }
    }
    return false;
  }
}

class TypeHandlerJsonMapImpl with TypeHandlerShouldHandleMixin<Map<String, dynamic>> {
  const TypeHandlerJsonMapImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    Map<String, dynamic> value,
  ) {
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(value));
    return res.close();
  }
}

class TypeHandlerJsonListImpl with TypeHandlerShouldHandleMixin<List<dynamic>> {
  const TypeHandlerJsonListImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    List<dynamic> value,
  ) {
    res.headers.contentType = ContentType.json;
    res.write(jsonEncode(value));
    return res.close();
  }
}

class TypeHandlerStringImpl with TypeHandlerShouldHandleMixin<String> {
  const TypeHandlerStringImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    String value,
  ) {
    res.write(value);
    return res.close();
  }
}

class TypeHandlerWebsocketImpl with TypeHandlerShouldHandleMixin<WebSocketSession> {
  const TypeHandlerWebsocketImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    WebSocketSession value,
  ) async => //
      value._start(await WebSocketTransformer.upgrade(req));
}

/// Convenience wrapper around Dart IO WebSocket implementation
/// TODO move send implementation here
/// TODO interface and impl
/// TODO make everybody use this wrapper and not WebSocket itself.
class WebSocketSession {
  late WebSocket socket;

  /// TODO method not member
  FutureOr<void> Function(WebSocket webSocket)? onOpen;

  /// TODO method not member
  FutureOr<void> Function(WebSocket webSocket, dynamic data)? onMessage;

  /// TODO method not member
  FutureOr<void> Function(WebSocket webSocket)? onClose;

  /// TODO method not member
  FutureOr<void> Function(WebSocket webSocket, dynamic error)? onError;

  WebSocketSession({this.onOpen, this.onMessage, this.onClose, this.onError});

  void _start(WebSocket webSocket) {
    socket = webSocket;
    try {
      onOpen?.call(socket);
      socket.listen((dynamic data) {
        onMessage?.call(socket, data);
      }, onDone: () {
        onClose?.call(socket);
      }, onError: (dynamic error) {
        onError?.call(socket, error);
      });
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('WebSocket Error: $e');
      try {
        socket.close();
        // ignore: empty_catches, avoid_catches_without_on_clauses
      } catch (e) {}
    }
  }
}
