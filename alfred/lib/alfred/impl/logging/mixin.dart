import '../../interface/alfred.dart';
import '../../interface/logging_delegate.dart';
import 'log_type.dart';

/// Maps from notifications about certain events to a log method.
mixin AlfredLoggingDelegateGeneralizingMixin implements AlfredLoggingDelegate {
  LogType get logLevel;

  void log({
    required final String Function() messageFn,
    required final LogType type,
  });

  @override
  void onIsListening({
    required final ServerConfig arguments,
  }) =>
      log(
        messageFn: () =>
            'HTTP Server listening on port: ' +
            arguments.port.toString() +
            " • boundIp: " +
            arguments.bindIp +
            " • shared: " +
            arguments.shared.toString() +
            " • simultaneousProcessing: " +
            arguments.simultaneousProcessing.toString(),
        type: const LogTypeInfo(),
      );

  @override
  void onIncomingRequest({
    required final String method,
    required final Uri uri,
  }) =>
      log(
        messageFn: () => method + ' - ' + uri.toString(),
        type: const LogTypeInfo(),
      );

  @override
  void onResponseSent() => log(
        messageFn: () => 'Response sent to client',
        type: const LogTypeDebug(),
      );

  @override
  void onNoMatchingRouteFound() => log(
        messageFn: () => 'No matching route found.',
        type: const LogTypeDebug(),
      );

  @override
  void onMatchingRoute({
    required final String route,
  }) =>
      log(
        messageFn: () => 'Match route: ' + route,
        type: const LogTypeDebug(),
      );

  @override
  void onExecuteRouteCallbackFunction() => log(
        messageFn: () => 'Execute route callback function',
        type: const LogTypeDebug(),
      );

  @override
  void onIncomingRequestException({
    required final Object e,
    required final StackTrace s,
  }) {
    log(
      messageFn: () => e.toString(),
      type: const LogTypeError(),
    );
    log(
      messageFn: () => s.toString(),
      type: const LogTypeError(),
    );
  }

  @override
  void logTypeHandler({
    required final String Function() msgFn,
  }) =>
      log(
        messageFn: () => 'DirectoryTypeHandler: ' + msgFn(),
        type: const LogTypeDebug(),
      );
}
