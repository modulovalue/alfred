import 'dart:io';

void openLocalhost(
  final int port,
) =>
    openAt(
      "http://localhost:" + port.toString(),
    );

void openAt(
  final String url,
) =>
    Process.runSync("open", [url]);
