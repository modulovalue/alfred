import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/empty.dart';

Future<void> main() async {
  final app = Alfred();
  app.get('/html', const EmptyMiddleware());
  app.printRoutes(); //Will print the routes to the console
  await app.listen();
}
