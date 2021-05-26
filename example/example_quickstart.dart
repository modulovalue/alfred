import 'package:alfred/alfred.dart';

Future<void> main() async {
  final app = Alfred();

  app.get('/example', (req, res) => 'Hello world');

  await app.listen();
}
