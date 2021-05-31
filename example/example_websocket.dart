import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';
import 'package:alfred/alfred/impl/middleware/websocket.dart';

Future<void> main() async {
  final session = MyWebSocketSession();
  final app = AlfredImpl();
  // Deliver web client for chat
  app.get(
    '/',
    const ServeHtml(
      r"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WebSocket</title>
    <style>
        body {font-family: sans-serif;}
        #messages {background: #d8edf5; border-radius: 8px; min-height: 100px; margin-bottom: 8px; display: flex; flex-direction: column;}
        #messages div {background: #eff6f8; border-radius: 8px;  margin: 8px; padding: 6px 12px; display: inline-block; width: fit-content}
    </style>
</head>
<body>
<div id="messages"></div>
<div class="panel">
    <label>Type message and hit <i>&lt;Enter&gt;</i>: <input autofocus id="input" type="text"></label>
</div>
<script type="module">
    document.addEventListener('DOMContentLoaded', () => {
        const input = document.querySelector('#input');
        const messages = document.querySelector('#messages');
        const socket = new WebSocket(`ws://${location.host}/ws`);
        socket.onopen = () => {
            console.log('WebSocket connection established.');
        }
        socket.onmessage = (e) => {
            const el = document.createElement('div');
            el.innerText = e.data;
            messages.appendChild(el);
        }
        socket.onclose = () => {
            console.log('WebSocket connection closed');
        }
        socket.onerror = () => {
            location.reload();
        }
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && input.value.length > 0) {
                socket.send(input.value);
                input.value = '';
            }
        });
    })
</script>
</body>
</html>
""",
    ),
  );
  // Track connected clients
  // WebSocket chat relay implementation
  app.get('/ws', WebSocketValueMiddleware(session));
  final server = await app.build(6565);
  print('Listening on ${server.server.port}');
}

class MyWebSocketSession with WebSocketSessionStartMixin {
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
    print("Starteeeeeeeed ${users.length}");
    users.add(ws);
    users.where((user) => user != ws).forEach((user) => user.add('A new user joined the chat.'));
  }
}
