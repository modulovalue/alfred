// TODO centralize this dependency
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
    webSocketSession.start(
      await c.req.upgradeToWebsocket(),
    );
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
    (await webSocketSessionFactory(c)).start(
      await c.req.upgradeToWebsocket(),
    );
  }
}

class WebSocketSessionAnonymousImpl with WebSocketSessionStartMixin {
  final InitiatedWebSocketSession Function(WebSocket webSocket) open;

  WebSocketSessionAnonymousImpl({
    required final this.open,
  });

  @override
  InitiatedWebSocketSession onOpen(
    final WebSocket webSocket,
  ) =>
      open.call(webSocket);
}

/// Convenience wrapper around Dart IO WebSocket implementation.
mixin WebSocketSessionStartMixin implements WebSocketSession {
  @override
  void start(
    final WebSocket webSocket,
  ) {
    final socket = webSocket;
    try {
      final delegate = onOpen(socket);
      socket.listen(
        (final dynamic data) {
          try {
            if (data is String) {
              delegate.onMessage(socket, data);
            } else if (data is List<int>) {
              delegate.onMessage(socket, data);
            } else {
              throw Exception(
                "Unknown data type emitted by socket. " + data.runtimeType.toString(),
              );
            }
          } on Object catch (e) {
            delegate.onError(socket, e);
          }
        },
        onDone: () => delegate.onClose(socket),
        onError: (dynamic error) => delegate.onError(socket, error),
      );
    } on Object catch (e) {
      print('WebSocket Error: ' + e.toString());
      try {
        socket.close();
        // TODO handle properly.
        // ignore: empty_catches
      } on Object catch (_) {}
    }
  }
}

/// Convenience wrapper around Dart IO WebSocket implementation
abstract class WebSocketSession {
  InitiatedWebSocketSession onOpen(
    final WebSocket webSocket,
  );

  void start(
    final WebSocket webSocket,
  );
}

class InitiatedWebSocketSessionAnonymousImpl implements InitiatedWebSocketSession {
  final void Function(WebSocket webSocket, dynamic data)? message;
  final void Function(WebSocket webSocket, dynamic error)? error;
  final void Function(WebSocket webSocket)? close;

  const InitiatedWebSocketSessionAnonymousImpl({
    final this.message,
    final this.error,
    final this.close,
  });

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

abstract class InitiatedWebSocketSession {
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
