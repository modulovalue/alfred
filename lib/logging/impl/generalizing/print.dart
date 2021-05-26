import 'package:enum_to_string/enum_to_string.dart';

import 'mixin.dart';

class AlfredLoggingDelegatePrintImpl with AlfredLoggingDelegateGeneralizingMixin {
  @override
  final LogType logLevel;

  const AlfredLoggingDelegatePrintImpl(this.logLevel);

  @override
  void log(dynamic Function() messageFn, LogType type) {
    if (type.index >= logLevel.index) {
      final timestamp = DateTime.now();

      /// TODO Remove enum to string once LogType is an adt.
      final logType = EnumToString.convertToString(type);
      final message = messageFn().toString();
      print('$timestamp - $logType - $message');
    }
  }
}
