import '../../interface/alfred.dart';
import '../../interface/logging_delegate.dart';
import 'log_type.dart';

/// Maps from notifications about certain event to a log method.
mixin AlfredLoggingDelegateGeneralizingMixin implements AlfredLoggingDelegate {
  LogType get logLevel;

  void log(
    final dynamic Function() messageFn,
    final LogType type,
  );

  @override
  void onIsListening(
    final ServerArguments args,
  ) =>
      log(
        () =>
            'HTTP Server listening on port: ' +
            args.port.toString() +
            " boundIp: " +
            args.bindIp +
            " shared: " +
            args.shared.toString() +
            " simultaneousProcessing: " +
            args.simultaneousProcessing.toString(),
        LogType.info,
      );

  @override
  void onIncomingRequest(
    final String method,
    final Uri uri,
  ) =>
      log(
        () => method + ' - ' + uri.toString(),
        LogType.info,
      );

  @override
  void onResponseSent() => log(
        () => 'Response sent to client',
        LogType.debug,
      );

  @override
  void onNoMatchingRouteFound() => log(
        () => 'No matching route found.',
        LogType.debug,
      );

  @override
  void onMatchingRoute(
    final String route,
  ) =>
      log(
        () => 'Match route: ' + route,
        LogType.debug,
      );

  @override
  void onExecuteRouteCallbackFunction() => log(
        () => 'Execute route callback function',
        LogType.debug,
      );

  @override
  void onIncomingRequestException(
    final Object e,
    final StackTrace s,
  ) {
    log(
      () => e,
      LogType.error,
    );
    log(
      () => s,
      LogType.error,
    );
  }

  @override
  void logTypeHandler(
    final String Function() msgFn,
  ) =>
      log(
        () => 'DirectoryTypeHandler: ' + msgFn(),
        LogType.debug,
      );
}
