import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl();
  // Provide any static assets
  app.get('/frontend/*', ServeDirectory.at('test/files/spa'));
  // Let any other routes handle by client SPA
  app.get('/frontend/*', ServeFile.at('test/files/spa/index.html'));
  await app.build(6565);
}
