import '../interface.dart';
import '../middleware/websocket.dart';

class WebSocketSessionUsersImpl with WebSocketSessionStartMixin implements InitiatedWebSocketSession {
  final List<AlfredWebSocket> active_users = [];

  WebSocketSessionUsersImpl();

  @override
  void on_close(
    final AlfredWebSocket ws,
  ) {
    active_users.remove(ws);
    active_users.forEach(
      (final user) => user.add_string('A user has left.'),
    );
  }

  @override
  void on_error(
    final AlfredWebSocket ws,
    final dynamic error,
  ) {
    // Do nothing. this is an example.
  }

  @override
  void on_message_string(
    final AlfredWebSocket ws,
    final String data,
  ) {
    active_users.forEach(
      (final user) {
        user.add_string(data);
      },
    );
  }

  @override
  void on_message_bytes(
    final AlfredWebSocket ws,
    final List<int> data,
  ) {
    for (final user in active_users) {
      user.add_bytes(data);
    }
  }

  @override
  InitiatedWebSocketSession on_open(
    final AlfredWebSocket ws,
  ) {
    active_users.add(ws);
    for (final user in active_users) {
      if (user == ws) {
        user.add_string('You have joined the chat.');
      } else {
        user.add_string('A new user joined the chat.');
      }
    }
    return this;
  }

  void send(
    final String message,
  ) {
    for (final user in active_users) {
      user.add_string(message);
    }
  }
}
