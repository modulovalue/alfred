import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:alfred/handlers.dart';
import 'package:alfred/middleware/impl/callback.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = Alfred();
  // Path to this Dart file
  final dir = File(Platform.script.path).parent.path;
  // Deliver web client for chat
  app.get('/', ValueMiddleware(File('$dir/chat-client.html')));
  // Track connected clients
  final users = <WebSocket>[];
  // WebSocket chat relay implementation
  app.get(
    '/ws',
    CallbackMiddleware(
      () => WebSocketSession(
        onOpen: (ws) {
          users.add(ws);
          users.where((user) => user != ws).forEach((user) => user.send('A new user joined the chat.'));
        },
        onClose: (ws) {
          users.remove(ws);
          users.forEach((user) => user.send('A user has left.'));
        },
        onMessage: (ws, dynamic data) async {
          users.forEach((user) => user.add(data));
        },
      ),
    ),
  );
  final server = await app.listen();
  print('Listening on ${server.port}');
}
