import 'dart:async';
import 'dart:io';

abstract class TypeHandler<T> {
  @Deprecated('Please create a subclass or use the named .make constructor')
  factory TypeHandler(FutureOr<dynamic> Function(HttpRequest req, HttpResponse res, T value) handler) => _TypeHandlerImpl(handler);
  
  factory TypeHandler.make(FutureOr<dynamic> Function(HttpRequest req, HttpResponse res, T value) handler) => _TypeHandlerImpl(handler);

  FutureOr<dynamic> handler(HttpRequest req, HttpResponse res, T value);

  bool shouldHandle(dynamic item) => item is T;
}

class _TypeHandlerImpl<T> with TypeHandlerShouldHandleMixin<T> {
  final FutureOr<dynamic> Function(HttpRequest req, HttpResponse res, T value) _handler;

  const _TypeHandlerImpl(this._handler);

  @override
  FutureOr<dynamic> handler(HttpRequest req, HttpResponse res, T value) => _handler(req, res, value);
}

mixin TypeHandlerShouldHandleMixin<T> implements TypeHandler<T> {
  @override
  bool shouldHandle(dynamic item) => item is T;
}
