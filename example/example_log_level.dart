import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl();
  const log = AlfredLoggingDelegatePrintImpl();
  app.get('/static/*', ServeDirectory.at('path/to/files', log));
  await app.build();
}
