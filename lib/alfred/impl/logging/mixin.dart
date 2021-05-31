import '../../interface/logging_delegate.dart';
import 'log_type.dart';

/// Maps from notifications about certain event to a log method.
mixin AlfredLoggingDelegateGeneralizingMixin implements AlfredLoggingDelegate {
  LogType get logLevel;

  void log(dynamic Function() messageFn, LogType type);

  @override
  void onIsListening(int port) => //
      log(() => 'HTTP Server listening on port ${port}', LogType.info);

  @override
  void onIncomingRequest(String method, Uri uri) => //
      log(() => method + ' - ' + uri.toString(), LogType.info);

  @override
  void onResponseSent() => //
      log(() => 'Response sent to client', LogType.debug);

  @override
  void onNoMatchingRouteFound() => //
      log(() => 'No matching route found.', LogType.debug);

  @override
  void onMatchingRoute(String route) => //
      log(() => 'Match route: ${route}', LogType.debug);

  @override
  void onExecuteRouteCallbackFunction() => //
      log(() => 'Execute route callback function', LogType.debug);

  @override
  void onIncomingRequestException(Object e, StackTrace s) {
    log(() => e, LogType.error);
    log(() => s, LogType.error);
  }

  @override
  void logTypeHandler(String Function() msgFn) => //
      log(() => 'DirectoryTypeHandler: ${msgFn()}', LogType.debug);
}
