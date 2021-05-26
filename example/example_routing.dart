import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:alfred/middleware/impl/request.dart';

Future<void> main() async {
  final app = Alfred();
  app.all('/example/:id/:name', RequestMiddleware((req) {
    // ignore: unnecessary_statements
    req.params['id'] != null;
    // ignore: unnecessary_statements
    req.params['name'] != null;
  }));
  await app.listen();
}
