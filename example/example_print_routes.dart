import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:alfred/util/print_routes.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/html', const ClosingMiddleware());
  printRoutes(app); // Will print the routes to the console.
  await app.build();
}
