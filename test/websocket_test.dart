import 'dart:async';
import 'dart:io';

import 'package:alfred/alfred/impl/middleware/websocket.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

import 'common.dart';

void main() {
  group("websocket", () {
    test('it correctly handles a websocket error', () async {
      await runTest(fn: (alfred, built, port) async {
        final ws = WebSocketSessionTest2Impl();
        alfred.get('/ws', WebSocketValueMiddleware(ws));
        final channel = IOWebSocketChannel.connect('ws://localhost:$port/ws');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        channel.sink.add('test');
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(ws.error, 1);
      });
    });
    test('it can handle websockets', () async {
      await runTest(fn: (alfred, built, port) async {
        final ws = WebSocketSessionTest1Impl();
        alfred.get('/ws', WebSocketValueMiddleware(ws));
        final channel = IOWebSocketChannel.connect('ws://localhost:$port/ws');
        channel.sink.add('hi');
        final response = await channel.stream.first as String;
        expect(ws.opened, true);
        expect(ws.closed, false);
        expect(ws.message, 'hi');
        expect(response, 'echo hi');
        await channel.sink.close();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(ws.closed, true);
      });
    });
  });
}

class WebSocketSessionTest2Impl with WebSocketSessionStartMixin {
  int error = 0;

  WebSocketSessionTest2Impl();

  @override
  void onClose(
    final WebSocket _,
  ) {
    // Do nothing.
  }

  @override
  void onMessage(
    final WebSocket _,
    final Object? data,
  ) {
    // ignore: only_throw_errors
    throw "Test";
  }

  @override
  void onError(
    final WebSocket _,
    final dynamic error,
  ) {
    this.error++;
  }

  @override
  void onOpen(
    final WebSocket _,
  ) {
    // Do nothing.
  }
}

class WebSocketSessionTest1Impl with WebSocketSessionStartMixin {
  bool opened = false;

  bool closed = false;

  String? message;

  WebSocketSessionTest1Impl();

  @override
  void onClose(
    final WebSocket _,
  ) =>
      closed = true;

  @override
  void onError(
    final WebSocket _,
    final dynamic error,
  ) {
    // Do nothing.
  }

  @override
  void onMessage(
    final WebSocket _,
    final dynamic data,
  ) {
    message = data as String;
    socket.add('echo $data');
  }

  @override
  void onOpen(
    final WebSocket _,
  ) =>
      opened = true;
}
