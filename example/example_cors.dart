import 'package:alfred/alfred.dart';
import 'package:alfred/src/middleware/cors.dart';

Future<void> main() async {
  final app = Alfred();

  // Warning: defaults to origin "*"
  app.all('*', cors(origin: 'myorigin.com'));

  await app.listen();
}
