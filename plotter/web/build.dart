import 'dart:io';

void main() {
  runCommand(
    command: "dart2js main.dart -O3 -o main.dart.js -m",
  );
}

void runCommand({
  required final String command,
}) {
  final separated = command.split(" ");
  final result = Process.runSync(
    separated.first,
    separated.sublist(1),
  );
  debugProcessResult(
    result: result,
  );
}

void debugProcessResult({
  required final ProcessResult result,
}) {
  print(result.exitCode);
  print(result.pid);
  print(result.stderr);
  print(result.stdout);
}
