import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = Alfred();
  app.get('/example', const ValueMiddleware('Hello world'));
  await app.listen();
}
