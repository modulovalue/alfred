import 'dart:io';

void openLocalhost(
  final int port,
) =>
    Process.runSync("open", ["http://localhost:" + port.toString()]);
