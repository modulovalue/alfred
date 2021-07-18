import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl();
  const log = AlfredLoggingDelegatePrintImpl();
  // Provide any static assets
  app.get('/frontend/*', ServeDirectory.at('test/files/spa', log));
  // Let any other routes handle by client SPA
  app.get('/frontend/*', ServeFile.at('test/files/spa/index.html'));
  await app.build(port: 6565);
}
