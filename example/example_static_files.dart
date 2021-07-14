import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl();
  // Note the wildcard (*) this is very important!!
  app.get('/public/*', ServeDirectory.at('test/files'));
  await app.build();
}
