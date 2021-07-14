abstract class AlfredLoggingDelegate {
  void onIsListening(
    final int port,
  );

  void onIncomingRequest(
    final String method,
    final Uri uri,
  );

  void onResponseSent();

  void onNoMatchingRouteFound();

  void onMatchingRoute(
    final String route,
  );

  void onExecuteRouteCallbackFunction();

  void onIncomingRequestException(
    final Object e,
    final StackTrace s,
  );

  void logTypeHandler(
    final String Function() msgFn,
  );
}
