import 'dart:io';

void openLocalhost([
  final int port = 80,
]) =>
    openAt(
      "http://localhost:" + port.toString(),
    );

void openAt(
  final String url,
) =>
    Process.runSync("open", [url]);
