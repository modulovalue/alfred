import 'log_type.dart';
import 'mixin.dart';

class AlfredLoggingDelegatePrintImpl with AlfredLoggingDelegateGeneralizingMixin {
  @override
  final LogType logLevel;

  const AlfredLoggingDelegatePrintImpl([
    final this.logLevel = const LogTypeDebug(),
  ]);

  @override
  void log({
    required final String Function() messageFn,
    required final LogType type,
  }) {
    if (type.index >= logLevel.index) {
      print(
        DateTime.now().toString() + ' - ' + type.description + ' - ' + messageFn(),
      );
    }
  }
}
