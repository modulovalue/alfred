import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io_dir.dart';
import 'package:alfred/alfred/impl/middleware/io_file.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';

Future<void> main() async {
  await helloAlfred(
    routes: [
      // Provide any static assets
      const RouteGet(
        path: '/frontend/*',
        middleware: ServeDirectoryStringPathImpl('test/files/spa'),
      ),
      // Let any other routes handle by client SPA
      const RouteGet(
        path: '/frontend/*',
        middleware: ServeFileStringPathImpl('test/files/spa/index.html'),
      ),
    ],
  );
}
