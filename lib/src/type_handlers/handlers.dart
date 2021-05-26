import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:alfred/alfred.dart';
import 'package:alfred/src/type_handlers/type_handler.dart';

import '../alfred.dart';
import '../extensions/request_helpers.dart';
import '../extensions/response_helpers.dart';
import 'type_handler.dart';

class TypeHandlerListOfIntegersImpl with TypeHandlerShouldHandleMixin<List<int>> {
  const TypeHandlerListOfIntegersImpl();

  @override
  FutureOr handler(HttpRequest req, HttpResponse res, List<int> value) async {
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
  FutureOr handler(HttpRequest req, HttpResponse res, Stream<List<int>> val) async {
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
  FutureOr handler(HttpRequest req, HttpResponse res, Directory directory) async {
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
      var match = fileCandidates.firstWhere((file) => file.existsSync());
      _log(req, () => 'Respond with file: ${match.path}');
      res.setContentTypeFromFile(match);
      await res.addStream(match.openRead());
      await res.close();
    } on StateError {
      _log(req, () => 'Could not match with any file. Expected file at: $filePath');
    }
  }
}

class TypeHandlerFileImpl with TypeHandlerShouldHandleMixin<File> {
  const TypeHandlerFileImpl();

  @override
  FutureOr handler(HttpRequest req, HttpResponse res, File file) async {
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
  FutureOr handler(HttpRequest req, HttpResponse res, dynamic value) {
    try {
      if (value.toJson != null) {
        res.write(jsonEncode(value.toJson()));
        return res.close();
      }
    } catch (e) {
      if (!e.toString().contains('has no instance getter')) {
        rethrow;
      }
    }
    try {
      if (value.toJSON != null) {
        res.write(jsonEncode(value.toJSON()));
        return res.close();
      }
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
  FutureOr handler(
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
  FutureOr handler(
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
  FutureOr handler(HttpRequest req, HttpResponse res, String value) {
    res.write(value);
    return res.close();
  }
}

class TypeHandlerWebsocketImpl with TypeHandlerShouldHandleMixin<WebSocketSession> {
  const TypeHandlerWebsocketImpl();

  @override
  FutureOr handler(HttpRequest req, HttpResponse res, WebSocketSession value) async => //
      value._start(await WebSocketTransformer.upgrade(req));
}

/// Convenience wrapper around Dart IO WebSocket implementation
class WebSocketSession {
  late WebSocket socket;

  FutureOr<void> Function(WebSocket webSocket)? onOpen;
  FutureOr<void> Function(WebSocket webSocket, dynamic data)? onMessage;
  FutureOr<void> Function(WebSocket webSocket)? onClose;
  FutureOr<void> Function(WebSocket webSocket, dynamic error)? onError;

  WebSocketSession({this.onOpen, this.onMessage, this.onClose, this.onError});

  void _start(WebSocket webSocket) {
    socket = webSocket;
    try {
      if (onOpen != null) {
        onOpen!(socket);
      }
      socket.listen((dynamic data) {
        if (onMessage != null) {
          onMessage!(socket, data);
        }
      }, onDone: () {
        if (onClose != null) {
          onClose!(socket);
        }
      }, onError: (dynamic error) {
        if (onError != null) {
          onError!(socket, error);
        }
      });
    } catch (e) {
      print('WebSocket Error: $e');
      try {
        socket.close();
        // ignore: empty_catches
      } catch (e) {}
    }
  }
}

extension WebSocketHelper on WebSocket {
  void send(String data) => add(data);
}
