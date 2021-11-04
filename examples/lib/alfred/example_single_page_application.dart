import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl_io/middleware/io_dir.dart';
import 'package:alfred/alfred/impl_io/middleware/io_file.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';

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
