import '../interface.dart';

class ServeWebSocket implements AlfredMiddleware {
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

class ServeWebSocketFactory implements AlfredMiddleware {
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
  final InitiatedWebSocketSession Function(AlfredWebSocket webSocket) open;

  WebSocketSessionAnonymousImpl({
    required final this.open,
  });

  @override
  InitiatedWebSocketSession onOpen(
    final AlfredWebSocket webSocket,
  ) =>
      open.call(webSocket);
}

/// Convenience wrapper around Dart IO WebSocket implementation.
mixin WebSocketSessionStartMixin implements WebSocketSession {
  @override
  void start(
    final AlfredWebSocket webSocket,
  ) {
    final socket = webSocket;
    try {
      final delegate = onOpen(socket);
      socket.listen(
        onData: (final dynamic data) {
          try {
            if (data is String) {
              delegate.onMessageString(socket, data);
            } else if (data is List<int>) {
              delegate.onMessageBytes(socket, data);
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
        cancelOnError: true,
      );
    } on Object catch (e) {
      print('WebSocket Error: ' + e.toString());
      try {
        socket.close(
          code: null,
          reason: null,
        );
        // TODO handle properly.
        // ignore: empty_catches
      } on Object catch (_) {}
    }
  }
}

/// Convenience wrapper around Dart IO WebSocket implementation
abstract class WebSocketSession {
  InitiatedWebSocketSession onOpen(
    final AlfredWebSocket webSocket,
  );

  void start(
    final AlfredWebSocket webSocket,
  );
}

class InitiatedWebSocketSessionAnonymousImpl implements InitiatedWebSocketSession {
  final void Function(AlfredWebSocket webSocket, String data)? messageString;
  final void Function(AlfredWebSocket webSocket, List<int> data)? messageBytes;
  final void Function(AlfredWebSocket webSocket, dynamic error)? error;
  final void Function(AlfredWebSocket webSocket)? close;

  const InitiatedWebSocketSessionAnonymousImpl({
    final this.messageString,
    final this.messageBytes,
    final this.error,
    final this.close,
  });

  @override
  void onMessageString(
    final AlfredWebSocket webSocket,
    final String data,
  ) =>
      messageString?.call(webSocket, data);

  @override
  void onMessageBytes(
    final AlfredWebSocket webSocket,
    final List<int> bytes,
  ) =>
      messageBytes?.call(webSocket, bytes);

  @override
  void onError(
    final AlfredWebSocket webSocket,
    final dynamic err,
  ) =>
      error?.call(webSocket, err);

  @override
  void onClose(
    final AlfredWebSocket webSocket,
  ) =>
      close?.call(webSocket);
}

abstract class InitiatedWebSocketSession {
  void onMessageString(
    final AlfredWebSocket webSocket,
    final String data,
  );

  void onMessageBytes(
    final AlfredWebSocket webSocket,
    final List<int> data,
  );

  void onError(
    final AlfredWebSocket webSocket,
    final dynamic error,
  );

  void onClose(
    final AlfredWebSocket webSocket,
  );
}
