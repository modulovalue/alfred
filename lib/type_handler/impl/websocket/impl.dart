import 'dart:async';
import 'dart:io';

import '../mixin.dart';
import 'session.dart';

class TypeHandlerWebsocketImpl with TypeHandlerShouldHandleMixin<WebSocketSession> {
  const TypeHandlerWebsocketImpl();

  @override
  FutureOr<dynamic> handler(
    HttpRequest req,
    HttpResponse res,
    WebSocketSession value,
  ) async => //
      value.start(await WebSocketTransformer.upgrade(req));
}

/// Convenience wrapper around Dart IO WebSocket implementation
mixin WebSocketSessionMixin implements WebSocketSession {
  @override
  late WebSocket socket;

  @override
  void start(WebSocket webSocket) {
    socket = webSocket;
    try {
      onOpen(socket);
      socket.listen(
        (dynamic data) {
          try {
            onMessage(socket, data);
            // ignore: avoid_catches_without_on_clauses
          } catch (e) {
            onError(socket, e);
          }
        },
        onDone: () => onClose(socket),
        onError: (dynamic error) => onError(socket, error),
      );
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
