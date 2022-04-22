import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/middleware_io/io_dir.dart';
import 'package:alfred/alfred/middleware_io/io_file.dart';

Future<void> main() async {
  await helloAlfred(
    routes: [
      // Provide any static assets
      AlfredRoute.get(
        path: '/frontend/*',
        middleware: const ServeDirectoryStringPathImpl(
          path: 'test/files/spa',
        ),
      ),
      // Let any other routes handle by client SPA
      AlfredRoute.get(
        path: '/frontend/*',
        middleware: const ServeFileStringPathImpl(
          path: 'test/files/spa/index.html',
        ),
      ),
    ],
  );
}
