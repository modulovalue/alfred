import 'dart:async';

import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:alfred/alfred/middleware/websocket.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

import 'common.dart';

void main() {
  group("websocket", () {
    test('it correctly handles a websocket error', () async {
      await runTest(fn: (final alfred, final built, final port) async {
        final ws = WebSocketSessionTest2Impl();
        alfred.router.add(
          routes: AlfredRoutedRoutes(
            routes: [
              AlfredRoute.get(
                path: '/ws',
                middleware: ServeWebSocket(
                  web_socket_session: ws,
                ),
              ),
            ],
          ),
        );
        final channel = IOWebSocketChannel.connect('ws://localhost:' + port.toString() + '/ws');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        channel.sink.add('test');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(ws.error, 1);
      });
    });
    test('it can handle websockets', () async {
      await runTest(fn: (final alfred, final built, final port) async {
        final ws = WebSocketSessionTest1Impl();
        alfred.router.add(
          routes: AlfredRoutedRoutes(
            routes: [
              AlfredRoute.get(
                path: '/ws',
                middleware: ServeWebSocket(
                  web_socket_session: ws,
                ),
              ),
            ],
          ),
        );
        final channel = IOWebSocketChannel.connect('ws://localhost:' + port.toString() + '/ws');
        channel.sink.add('hi');
        final dynamic response = await channel.stream.first;
        if (response is String) {
          expect(ws.opened, true);
          expect(ws.closed, false);
          expect(ws.message, 'hi');
          expect(response, 'echo hi');
          await channel.sink.close();
          await Future<void>.delayed(const Duration(milliseconds: 10));
          expect(ws.closed, true);
        } else {
          throw Exception("Invalid response " + response.toString());
        }
      });
    });
  });
}

class WebSocketSessionTest2Impl with WebSocketSessionStartMixin implements InitiatedWebSocketSession {
  int error = 0;

  WebSocketSessionTest2Impl();

  @override
  InitiatedWebSocketSession on_open(
    final AlfredWebSocket _,
  ) {
    return this;
  }

  @override
  void on_close(
    final AlfredWebSocket _,
  ) {
    // Do nothing.
  }

  @override
  void on_message_string(
    final AlfredWebSocket _,
    final String data,
  ) {
    throw Exception("Test");
  }

  @override
  void on_message_bytes(
    final AlfredWebSocket _,
    final List<int> data,
  ) {
    throw Exception("Test");
  }

  @override
  void on_error(
    final AlfredWebSocket _,
    final dynamic error,
  ) =>
      this.error++;
}

class WebSocketSessionTest1Impl with WebSocketSessionStartMixin implements InitiatedWebSocketSession {
  bool opened = false;

  bool closed = false;

  String? message;

  WebSocketSessionTest1Impl();

  @override
  InitiatedWebSocketSession on_open(
    final AlfredWebSocket _,
  ) {
    opened = true;
    return this;
  }

  @override
  void on_close(
    final AlfredWebSocket socket,
  ) =>
      closed = true;

  @override
  void on_error(
    final AlfredWebSocket socket,
    final dynamic error,
  ) {
    // Do nothing.
  }

  @override
  void on_message_string(
    final AlfredWebSocket socket,
    final String data,
  ) {
    message = data;
    socket.add_string('echo ' + data);
  }

  @override
  void on_message_bytes(
    final AlfredWebSocket socket,
    final List<int> data,
  ) {
    throw Exception("Expected a String " + data.toString());
  }
}
