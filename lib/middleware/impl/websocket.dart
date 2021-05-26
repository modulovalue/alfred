import 'dart:io';

import '../../handlers.dart';
import '../interface/middleware.dart';

class WebSocketMiddleware implements Middleware<WebSocketSession> {
  final WebSocketSession Function() websocketSessionFactory;

  const WebSocketMiddleware(this.websocketSessionFactory);

  @override
  WebSocketSession process(HttpRequest req, HttpResponse res) => websocketSessionFactory();
}
