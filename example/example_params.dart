import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all('/example/:id/:name', MiddlewareBuilder((context) async {
    // ignore: unnecessary_statements
    print(context.params!['id']);
    // ignore: unnecessary_statements
    print(context.params!['name']);
  }));
  await app.build();
}
