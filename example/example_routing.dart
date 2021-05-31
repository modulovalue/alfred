import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/example/:id/:name', MiddlewareBuilder((context) async {
    // ignore: unnecessary_statements
    context.params!['id'] != null;
    // ignore: unnecessary_statements
    context.params!['name'] != null;
  }));
  await app.build();
}
