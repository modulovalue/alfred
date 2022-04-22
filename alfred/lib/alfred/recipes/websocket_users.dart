import '../interface.dart';
import '../middleware/websocket.dart';

class WebSocketSessionUsersImpl with WebSocketSessionStartMixin implements InitiatedWebSocketSession {
  final List<AlfredWebSocket> active_users = [];

  WebSocketSessionUsersImpl();

  @override
  void onClose(
    final AlfredWebSocket ws,
  ) {
    active_users.remove(ws);
    active_users.forEach(
      (final user) => user.addString('A user has left.'),
    );
  }

  @override
  void onError(
    final AlfredWebSocket ws,
    final dynamic error,
  ) {
    // Do nothing. this is an example.
  }

  @override
  void onMessageString(
    final AlfredWebSocket ws,
    final String data,
  ) {
    active_users.forEach(
      (final user) {
        user.addString(data);
      },
    );
  }

  @override
  void onMessageBytes(
    final AlfredWebSocket ws,
    final List<int> data,
  ) {
    for (final user in active_users) {
      user.addBytes(data);
    }
  }

  @override
  InitiatedWebSocketSession onOpen(
    final AlfredWebSocket ws,
  ) {
    active_users.add(ws);
    for (final user in active_users) {
      if (user == ws) {
        user.addString('You have joined the chat.');
      } else {
        user.addString('A new user joined the chat.');
      }
    }
    return this;
  }

  void send(
    final String message,
  ) {
    for (final user in active_users) {
      user.addString(message);
    }
  }
}
