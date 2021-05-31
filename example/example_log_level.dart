import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/log_type.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl(log: const AlfredLoggingDelegatePrintImpl(LogType.debug));
  app.get('/static/*', ServeDirectory.at('path/to/files'));
  await app.build();
}
