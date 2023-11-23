import '../interface.dart';

class ServeWebSocket implements AlfredMiddleware {
  final WebSocketSession web_socket_session;

  const ServeWebSocket({
    required this.web_socket_session,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    web_socket_session.start(
      await c.req.upgrade_to_websocket(),
    );
  }
}

class ServeWebSocketFactory implements AlfredMiddleware {
  final Future<WebSocketSession> Function(ServeContext) web_socket_session_factory;

  const ServeWebSocketFactory({
    required this.web_socket_session_factory,
  });

  @override
  Future<void> process(
    final ServeContext c,
  ) async {
    (await web_socket_session_factory(c)).start(
      await c.req.upgrade_to_websocket(),
    );
  }
}

class WebSocketSessionAnonymousImpl with WebSocketSessionStartMixin {
  final InitiatedWebSocketSession Function(AlfredWebSocket web_socket) open;

  WebSocketSessionAnonymousImpl({
    required this.open,
  });

  @override
  InitiatedWebSocketSession on_open(
    final AlfredWebSocket web_socket,
  ) {
    return open.call(web_socket);
  }
}

/// Convenience wrapper around Dart IO WebSocket implementation.
mixin WebSocketSessionStartMixin implements WebSocketSession {
  @override
  void start(
    final AlfredWebSocket web_socket,
  ) {
    final socket = web_socket;
    try {
      final delegate = on_open(socket);
      socket.listen(
        on_data: (final dynamic data) {
          try {
            if (data is String) {
              delegate.on_message_string(socket, data);
            } else if (data is List<int>) {
              delegate.on_message_bytes(socket, data);
            } else {
              throw Exception(
                "Unknown data type emitted by socket. " + data.runtimeType.toString(),
              );
            }
          } on Object catch (e) {
            delegate.on_error(socket, e);
          }
        },
        on_done: () => delegate.on_close(socket),
        on_error: (final dynamic error) => delegate.on_error(socket, error),
        cancel_on_error: true,
      );
    } on Object catch (e) {
      print('WebSocket Error: ' + e.toString());
      try {
        // ignore: discarded_futures
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
  InitiatedWebSocketSession on_open(
    final AlfredWebSocket web_socket,
  );

  void start(
    final AlfredWebSocket web_socket,
  );
}

class InitiatedWebSocketSessionAnonymousImpl implements InitiatedWebSocketSession {
  final void Function(AlfredWebSocket web_socket, String data)? message_string;
  final void Function(AlfredWebSocket web_socket, List<int> data)? message_bytes;
  final void Function(AlfredWebSocket web_socket, dynamic error)? error;
  final void Function(AlfredWebSocket web_socket)? close;

  const InitiatedWebSocketSessionAnonymousImpl({
    this.message_string,
    this.message_bytes,
    this.error,
    this.close,
  });

  @override
  void on_message_string(
    final AlfredWebSocket web_socket,
    final String data,
  ) {
    message_string?.call(web_socket, data);
  }

  @override
  void on_message_bytes(
    final AlfredWebSocket web_socket,
    final List<int> bytes,
  ) {
    message_bytes?.call(web_socket, bytes);
  }

  @override
  void on_error(
    final AlfredWebSocket web_socket,
    final dynamic err,
  ) {
    error?.call(web_socket, err);
  }

  @override
  void on_close(
    final AlfredWebSocket web_socket,
  ) {
    close?.call(web_socket);
  }
}

abstract class InitiatedWebSocketSession {
  void on_message_string(
    final AlfredWebSocket web_socket,
    final String data,
  );

  void on_message_bytes(
    final AlfredWebSocket web_socket,
    final List<int> data,
  );

  void on_error(
    final AlfredWebSocket web_socket,
    final dynamic error,
  );

  void on_close(
    final AlfredWebSocket web_socket,
  );
}
