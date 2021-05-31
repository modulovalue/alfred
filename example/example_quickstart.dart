import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/example', const ServeString('Hello world'));
  await app.build();
}

