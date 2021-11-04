import 'dart:io';

void openLocalhost({
  final int port = 80,
}) =>
    openAt(
      url: "http://localhost:" + port.toString(),
    );

void openAt({
  required final String url,
}) =>
    Process.runSync("open", [url]);
