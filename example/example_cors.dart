import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/cors.dart';

Future<void> main() async {
  final app = AlfredImpl();
  // Warning: defaults to origin "*"
  app.all('*', const CorsMiddleware(origin: 'myorigin.com'));
  await app.build();
}
