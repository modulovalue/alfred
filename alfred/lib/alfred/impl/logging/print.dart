import 'log_type.dart';
import 'mixin.dart';

class AlfredLoggingDelegatePrintImpl with AlfredLoggingDelegateGeneralizingMixin {
  @override
  final LogType logLevel;

  const AlfredLoggingDelegatePrintImpl([
    this.logLevel = LogType.debug,
  ]);

  @override
  void log(
    final String Function() messageFn,
    final LogType type,
  ) {
    if (type.index >= logLevel.index) {
      print(
        DateTime.now().toString() + ' - ' + type.description + ' - ' + messageFn(),
      );
    }
  }
}
