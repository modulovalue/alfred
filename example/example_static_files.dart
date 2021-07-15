import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl();
  // Note the wildcard (*) this is very important!!
  const log = AlfredLoggingDelegatePrintImpl();
  app.get('/public/*', ServeDirectory.at('test/files', log));
  await app.build();
}
