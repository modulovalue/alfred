import 'dart:io';

void main() {
  _run_command(
    command: "dart2js main.dart -O3 -o main.dart.js -m",
  );
}

/// Runs a command via Process from a string, the
/// same way that a terminal would.
void _run_command({
  required final String command,
}) {
  final separated = command.split(" ");
  final result = Process.runSync(
    separated.first,
    separated.sublist(1),
  );
  _debug_process_result(
    result: result,
  );
}

/// Prints out the contents of a [ProcessResult].
void _debug_process_result({
  required final ProcessResult result,
}) {
  print(result.exitCode);
  print(result.pid);
  print(result.stderr);
  print(result.stdout);
}
