import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';

Future<void> main() async {
  await helloAlfred(
    routes: [
      const RouteGet(
        path: "/example",
        middleware: ServeString('Hello world'),
      )
    ],
  );
}
