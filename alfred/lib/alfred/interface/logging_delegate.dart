import 'alfred.dart';

abstract class AlfredLoggingDelegate {
  void onIsListening({
    required final ServerConfig arguments,
  });

  void onIncomingRequest({
    required final String method,
    required final Uri uri,
  });

  void onResponseSent();

  void onNoMatchingRouteFound();

  void onMatchingRoute({
    required final String route,
  });

  void onExecuteRouteCallbackFunction();

  void onIncomingRequestException({
    required final Object e,
    required final StackTrace s,
  });

  void logTypeHandler({
    required final String Function() msgFn,
  });
}
