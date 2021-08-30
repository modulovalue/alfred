/// Indicates the severity of logged messages.
abstract class LogType {
  int get index;

  String get description;
}

class LogTypeDebug implements LogType {
  const LogTypeDebug();

  @override
  int get index => 1;

  @override
  String get description => "debug";

  @override
  String toString() => 'DebugLogType{}';
}

class LogTypeInfo implements LogType {
  const LogTypeInfo();

  @override
  int get index => 2;

  @override
  String get description => "info";

  @override
  String toString() => 'InfoLogType{}';
}

class LogTypeWarn implements LogType {
  const LogTypeWarn();

  @override
  int get index => 3;

  @override
  String get description => "warn";

  @override
  String toString() => 'WarnLogType{}';
}

class LogTypeError implements LogType {
  const LogTypeError();

  @override
  int get index => 4;

  @override
  String get description => "error";

  @override
  String toString() => 'ErrorLogType{}';
}
