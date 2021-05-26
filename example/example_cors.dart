import 'package:alfred/base.dart';
import 'package:alfred/middleware/impl/cors.dart';

Future<void> main() async {
  final app = Alfred();
  // Warning: defaults to origin "*"
  app.all('*', const CorsMiddleware(origin: 'myorigin.com'));
  await app.listen();
}
