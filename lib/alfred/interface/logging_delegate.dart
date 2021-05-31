
abstract class AlfredLoggingDelegate {
  void onIsListening(int port);

  void onIncomingRequest(String method, Uri uri);

  void onResponseSent();

  void onNoMatchingRouteFound();

  void onMatchingRoute(String route);

  void onExecuteRouteCallbackFunction();

  void onIncomingRequestException(Object e, StackTrace s);

  void logTypeHandler(String Function() msgFn);
}
