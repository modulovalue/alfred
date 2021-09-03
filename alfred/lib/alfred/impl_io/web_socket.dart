import 'dart:async';
import 'dart:io';

import '../interface/serve_context.dart';

class AlfredWebSocketImpl implements AlfredWebSocket {
  final WebSocket socket;

  const AlfredWebSocketImpl({
    required final this.socket,
  });

  @override
  void addString(
    final String string,
  ) =>
      socket.add(string);

  @override
  void addBytes(
    final List<int> bytes,
  ) =>
      socket.add(bytes);

  @override
  Future<void> close({
    required int? code,
    required String? reason,
  }) =>
      socket.close(code, reason);

  @override
  StreamSubscription<dynamic> listen({
    required final void Function(dynamic event)? onData,
    required final Function? onError,
    required final void Function()? onDone,
    required final bool? cancelOnError,
  }) =>
      socket.listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );
}
