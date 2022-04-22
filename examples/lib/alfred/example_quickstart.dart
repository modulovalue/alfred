import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/middleware/string.dart';

Future<void> main() async {
  await helloAlfred(
    routes: [
      AlfredRoute.get(
        path: "/example",
        middleware: const ServeString(
          string: 'Hello world',
        ),
      ),
    ],
  );
}
