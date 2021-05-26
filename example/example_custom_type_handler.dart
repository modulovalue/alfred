import 'dart:async';
import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/handlers.dart';

class Chicken {
  const Chicken();

  String get response => 'I am a chicken';
}

void main() {
  final app = Alfred();
  app.typeHandlers.add(TypeHandlerImpl<Chicken>((req, res, val) async {
    res.write(val.response);
    await res.close();
  }));
  // The app will now return the Chicken.response if you return one from a route.
  app.get('/kfc', (req, res) => const Chicken()); // I am a chicken.
  app.listen(); // Listening on 3000.
}

class TypeHandlerImpl<T> with TypeHandlerShouldHandleMixin<T> {
  final FutureOr<dynamic> Function(HttpRequest req, HttpResponse res, T value) _handler;

  const TypeHandlerImpl(this._handler);

  @override
  FutureOr<dynamic> handler(HttpRequest req, HttpResponse res, T value) => _handler(req, res, value);
}
