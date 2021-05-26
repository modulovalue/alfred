import 'dart:io';

import '../../type_handler/impl/websocket/session.dart';
import '../interface/middleware.dart';

class WebSocketFunctionMiddleware implements Middleware<WebSocketSession> {
  final WebSocketSession Function() websocketSessionFactory;

  const WebSocketFunctionMiddleware(this.websocketSessionFactory);

  @override
  WebSocketSession process(HttpRequest req, HttpResponse res) => websocketSessionFactory();
}

class WebSocketValueMiddleware implements Middleware<WebSocketSession> {
  final WebSocketSession  websocketSession;

  const WebSocketValueMiddleware(this.websocketSession);

  @override
  WebSocketSession process(HttpRequest req, HttpResponse res) => websocketSession;
}
