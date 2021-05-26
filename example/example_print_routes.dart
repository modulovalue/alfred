import 'package:alfred/alfred.dart';

Future<void> main() async {
  final app = Alfred();

  app.get('/html', (req, res) {});

  app.printRoutes(); //Will print the routes to the console

  await app.listen();
}
