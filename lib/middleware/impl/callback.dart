import 'dart:io';

import '../interface/middleware.dart';

/// Middleware that generates a value from a callback
/// but doesn't depend on the request and response.
class CallbackMiddleware<T> implements Middleware<T> {
  final T Function() callback;

  const CallbackMiddleware(this.callback)
      : assert(
          callback is! void Function(),
          "Be careful about expression bodies that are meant to return void. "
          "Please use ${VoidCallbackMiddleware}."
          "See ${VoidCallbackMiddleware} for an explanation.",
        );

  @override
  T process(HttpRequest req, HttpResponse res) => callback();
}

/// Middleware that just calls a callback without passing on a value.
class VoidCallbackMiddleware implements Middleware<void> {
  final void Function() callback;

  const VoidCallbackMiddleware(this.callback);

  @override
  void process(HttpRequest req, HttpResponse res) {
    // Very weird dart behavior. This must not be an expression body
    // or else dart will pass on the return type of [callback] to those
    // that use the runtimeType of process.
    callback();
  }
}
