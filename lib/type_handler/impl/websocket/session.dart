import 'dart:io';

/// Convenience wrapper around Dart IO WebSocket implementation
abstract class WebSocketSession {
  WebSocket get socket;

  void start(WebSocket webSocket);

  void onOpen(WebSocket webSocket);

  void onMessage(WebSocket webSocket, dynamic data);

  void onClose(WebSocket webSocket);

  void onError(WebSocket webSocket, dynamic error);
}
