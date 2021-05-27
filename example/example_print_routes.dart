import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/middleware/impl/empty.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/html', const EmptyMiddleware());
  app.printRoutes(); //Will print the routes to the console
  await app.listen();
}
