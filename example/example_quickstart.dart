import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/example', const ValueMiddleware('Hello world'));
  await app.listen();
}
