import 'dart:io';

import '../../interface/middleware.dart';
import '../../interface/serve_context.dart';

class ServeWebSocket implements Middleware {
  final WebSocketSession webSocketSession;

  const ServeWebSocket({
    required final this.webSocketSession,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final websocket = await WebSocketTransformer.upgrade(c.req);
    webSocketSession.start(websocket);
  }
}

class ServeWebSocketFactory implements Middleware {
  final Future<WebSocketSession> Function(ServeContext) webSocketSessionFactory;

  const ServeWebSocketFactory({
    required final this.webSocketSessionFactory,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    final websocket = await WebSocketTransformer.upgrade(c.req);
    (await webSocketSessionFactory(c)).start(websocket);
  }
}

class WebSocketSessionAnonymousImpl with WebSocketSessionStartMixin {
  final void Function(WebSocket webSocket)? open;
  final void Function(WebSocket webSocket, dynamic data)? message;
  final void Function(WebSocket webSocket, dynamic error)? error;
  final void Function(WebSocket webSocket)? close;

  WebSocketSessionAnonymousImpl({
    final this.open,
    final this.message,
    final this.error,
    final this.close,
  });

  @override
  void onOpen(
    final WebSocket webSocket,
  ) =>
      open?.call(webSocket);

  @override
  void onMessage(
    final WebSocket webSocket,
    final dynamic data,
  ) =>
      message?.call(webSocket, data);

  @override
  void onError(
    final WebSocket webSocket,
    final dynamic err,
  ) =>
      error?.call(webSocket, err);

  @override
  void onClose(
    final WebSocket webSocket,
  ) =>
      close?.call(webSocket);
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
      print('WebSocket Error: ' + e.toString());
      try {
        socket.close();
        // ignore: empty_catches
      } on Object catch (_) {}
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

  void onError(
    final WebSocket webSocket,
    final dynamic error,
  );

  void onClose(
    final WebSocket webSocket,
  );
}
