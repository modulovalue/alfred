import '../../type_handler/interface/type_handler.dart';

abstract class AlfredLoggingDelegate {
  void onIsListening(int port);

  void onIncomingRequest(String method, Uri uri);

  void onResponseSent();

  void onNoMatchingRouteFound();

  void onMatchingRoute(String route);

  void onApplyMiddleware();

  void onExecuteRouteCallbackFunction();

  void onIncomingRequestException(Object e, StackTrace s);

  void onApplyingTypeHandlerTo(TypeHandler<dynamic> handler, Type runtimeType);

  void logTypeHandler(String Function() msgFn);
}
