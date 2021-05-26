import '../../type_handler/interface/type_handler.dart';
import '../interface/logging_delegate.dart';

/// A [AlfredLoggingDelegate] that disables all logging.
class NilLoggingDelegate implements AlfredLoggingDelegate {
  const NilLoggingDelegate();

  @override
  void onIncomingRequest(String method, Uri uri) {
    // Does nothing.
  }

  @override
  void onIsListening(int port) {
    // Does nothing.
  }

  @override
  void onResponseSent() {
    // Does nothing.
  }

  @override
  void onNoMatchingRouteFound() {
    // Does nothing.
  }

  @override
  void onMatchingRoute(String route) {
    // Does nothing.
  }

  @override
  void onApplyMiddleware() {
    // Does nothing.
  }

  @override
  void onApplyingTypeHandlerTo(TypeHandler<dynamic> handler, Type runtimeType) {
    // Does nothing.
  }

  @override
  void onExecuteRouteCallbackFunction() {
    // Does nothing.
  }

  @override
  void onIncomingRequestException(Object e, StackTrace s) {
    // Does nothing.
  }

  @override
  void logTypeHandler(String Function() msgFn) {
    // Does nothing.
  }
}
