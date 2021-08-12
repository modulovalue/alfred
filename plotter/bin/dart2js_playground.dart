import 'dart:io';

/// Exploratory efforts to see what's fast and practical with dart2js go here.
void main() {
  _runCommand(
    command: "dart2js main.dart -O3 -o main.dart.js -m",
  );
}

/// Runs a command via Process from a string, the
/// same way that a terminal would.
void _runCommand({
  required final String command,
}) {
  final separated = command.split(" ");
  final result = Process.runSync(
    separated.first,
    separated.sublist(1),
  );
  _debugProcessResult(
    result: result,
  );
}

/// Prints out the contents of a [ProcessResult].
void _debugProcessResult({
  required final ProcessResult result,
}) {
  print(result.exitCode);
  print(result.pid);
  print(result.stderr);
  print(result.stdout);
}
