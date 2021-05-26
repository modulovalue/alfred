import 'log_type.dart';
import 'mixin.dart';

class AlfredLoggingDelegatePrintImpl with AlfredLoggingDelegateGeneralizingMixin {
  @override
  final LogType logLevel;

  const AlfredLoggingDelegatePrintImpl(this.logLevel);

  @override
  void log(dynamic Function() messageFn, LogType type) {
    if (type.index >= logLevel.index) {
      print('${DateTime.now()} - ${type.description} - ${messageFn().toString()}');
    }
  }
}
