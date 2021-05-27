import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/request.dart';
import 'package:alfred/middleware/impl/request.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/example/:id/:name', RequestMiddleware((req) {
    // ignore: unnecessary_statements
    AlfredHttpRequestImpl(req, app).params['id'] != null;
    // ignore: unnecessary_statements
    AlfredHttpRequestImpl(req, app).params['name'] != null;
  }));
  await app.listen();
}
