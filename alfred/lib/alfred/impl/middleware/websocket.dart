import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class WebSocketFunctionMiddleware implements Middleware {
  final WebSocketSession Function() websocketSessionFactory;

  const WebSocketFunctionMiddleware(
    final this.websocketSessionFactory,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final websocket = await WebSocketTransformer.upgrade(c.req);
    websocketSessionFactory().start(websocket);
  }
}

class WebSocketValueMiddleware implements Middleware {
  final WebSocketSession websocketSession;

  const WebSocketValueMiddleware(
    final this.websocketSession,
  );

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final websocket = await WebSocketTransformer.upgrade(c.req);
    websocketSession.start(websocket);
  }
}

/// Convenience wrapper around Dart IO WebSocket implementation.
mixin WebSocketSessionStartMixin implements WebSocketSession {
  @override
  late WebSocket socket;

  @override
  void start(
    final WebSocket webSocket,
  ) {
    socket = webSocket;
    try {
      onOpen(socket);
      socket.listen(
        (final dynamic data) {
          try {
            if (data is String) {
              onMessage(socket, data);
            } else if (data is List<int>) {
              onMessage(socket, data);
            } else {
              throw Exception(
                "Unknown data type emitted by socket. " + data.runtimeType.toString(),
              );
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

  void start(
    final WebSocket webSocket,
  );

  void onOpen(
    final WebSocket webSocket,
  );

  void onMessage(
    final WebSocket webSocket,
    final dynamic data,
  );

  void onClose(
    final WebSocket webSocket,
  );

  void onError(
    final WebSocket webSocket,
    final dynamic error,
  );
}
