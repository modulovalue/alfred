import 'package:alfred/base.dart';
import 'package:alfred/middleware_cors.dart';

Future<void> main() async {
  final app = Alfred();
  // Warning: defaults to origin "*"
  app.all('*', cors(origin: 'myorigin.com'));
  await app.listen();
}
