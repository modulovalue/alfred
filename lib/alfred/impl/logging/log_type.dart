/// Indicates the severity of logged messages.
abstract class LogType {
  static const DebugLogType debug = DebugLogType._();
  static const WarnLogType warn = WarnLogType._();
  static const InfoLogType info = InfoLogType._();
  static const ErrorLogType error = ErrorLogType._();

  int get index;

  String get description;
}

class DebugLogType implements LogType {
  const DebugLogType._();

  @override
  int get index => 1;

  @override
  String get description => "debug";

  @override
  String toString() => 'DebugLogType{}';
}

class InfoLogType implements LogType {
  const InfoLogType._();

  @override
  int get index => 2;

  @override
  String get description => "info";

  @override
  String toString() => 'InfoLogType{}';
}

class WarnLogType implements LogType {
  const WarnLogType._();

  @override
  int get index => 3;

  @override
  String get description => "warn";

  @override
  String toString() => 'WarnLogType{}';
}

class ErrorLogType implements LogType {
  const ErrorLogType._();

  @override
  int get index => 4;

  @override
  String get description => "error";

  @override
  String toString() => 'ErrorLogType{}';
}