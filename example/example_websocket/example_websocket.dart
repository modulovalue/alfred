import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/value.dart';
import 'package:alfred/middleware/impl/websocket.dart';
import 'package:alfred/type_handler/impl/websocket/impl.dart';

Future<void> main() async {
  final app = Alfred();
  // Path to this Dart file
  final dir = File(Platform.script.path).parent.path;
  // Deliver web client for chat
  app.get('/', ValueMiddleware(File('$dir/chat-client.html')));
  // Track connected clients
  // WebSocket chat relay implementation
  app.get('/ws', WebSocketValueMiddleware(MyWebSocketSession()));
  final server = await app.listen();
  print('Listening on ${server.port}');
}

class MyWebSocketSession with WebSocketSessionMixin {
  MyWebSocketSession();

  final users = <WebSocket>[];

  @override
  void onClose(WebSocket ws) {
    users.remove(ws);
    users.forEach((user) => user.add('A user has left.'));
  }

  @override
  void onError(WebSocket ws, dynamic error) {
    // Do nothing. this is an example.
  }

  @override
  void onMessage(WebSocket ws, dynamic data) {
    users.forEach((user) => user.add(data));
  }

  @override
  void onOpen(WebSocket ws) {
    users.add(ws);
    users.where((user) => user != ws).forEach((user) => user.add('A new user joined the chat.'));
  }
}
