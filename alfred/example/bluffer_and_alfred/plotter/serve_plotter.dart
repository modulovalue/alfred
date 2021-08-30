import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io_dir.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final built = await helloAlfred(
    routes: [
      Route.get(
        path: "/*",
        middleware: const ServeDirectoryStringPathImpl(
          path: "/Users/valauskasmodestas/Desktop/alfred/plotter/build",
        ),
      ),
    ],
  );
  openLocalhost(built.args.port);
}
