import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class WebSocketFunctionMiddleware implements Middleware {
  final WebSocketSession Function() websocketSessionFactory;

  const WebSocketFunctionMiddleware(this.websocketSessionFactory);

  @override
  Future<void> process(ServeContext c) async => //
      websocketSessionFactory().start(await WebSocketTransformer.upgrade(c.req));
}

class WebSocketValueMiddleware implements Middleware {
  final WebSocketSession websocketSession;

  const WebSocketValueMiddleware(this.websocketSession);

  @override
  Future<void> process(ServeContext c) async => //
      websocketSession.start(await WebSocketTransformer.upgrade(c.req));
}

/// Convenience wrapper around Dart IO WebSocket implementation.
mixin WebSocketSessionStartMixin implements WebSocketSession {
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
            if (data is String) {
              onMessage(socket, data);
            } else if (data is List<int>) {
              onMessage(socket, data);
            } else {
              throw Exception("Unknown data type emitted by socket. ${data.runtimeType}");
            }
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

/// Convenience wrapper around Dart IO WebSocket implementation
abstract class WebSocketSession {
  WebSocket get socket;

  void start(WebSocket webSocket);

  void onOpen(WebSocket webSocket);

  void onMessage(WebSocket webSocket, dynamic data);

  void onClose(WebSocket webSocket);

  void onError(WebSocket webSocket, dynamic error);
}
