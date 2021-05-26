
/// Indicates the severity of logged message
abstract class LogType {
  static const DebugLogType debug = DebugLogType();
  static const WarnLogType warn = WarnLogType();
  static const InfoLogType info = InfoLogType();
  static const ErrorLogType error = ErrorLogType();

  int get index;

  String get description;
}

class DebugLogType implements LogType {
  const DebugLogType();

  @override
  int get index => 1;

  @override
  String get description => "debug";

  @override
  String toString() => 'DebugLogType{}';
}

class InfoLogType implements LogType {
  const InfoLogType();

  @override
  int get index => 2;

  @override
  String get description => "info";

  @override
  String toString() => 'InfoLogType{}';
}

class WarnLogType implements LogType {
  const WarnLogType();

  @override
  int get index => 3;

  @override
  String get description => "warn";

  @override
  String toString() => 'WarnLogType{}';
}

class ErrorLogType implements LogType {
  const ErrorLogType();

  @override
  int get index => 4;

  @override
  String get description => "error";

  @override
  String toString() => 'ErrorLogType{}';
}
