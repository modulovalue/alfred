import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io_dir.dart';
import 'package:alfred/alfred/impl/middleware/io_file.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';

Future<void> main() async {
  await helloAlfred(
    routes: [
      // Provide any static assets
      Route.get(
        path: '/frontend/*',
        middleware: const ServeDirectoryStringPathImpl(
          path: 'test/files/spa',
        ),
      ),
      // Let any other routes handle by client SPA
      Route.get(
        path: '/frontend/*',
        middleware: const ServeFileStringPathImpl(
          path: 'test/files/spa/index.html',
        ),
      ),
    ],
  );
}
