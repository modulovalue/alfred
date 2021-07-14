import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all(
    '/example/:id/:name',
    MiddlewareBuilder(
      (final context) async {
        // ignore: unnecessary_statements
        print(context.params!['id']);
        // ignore: unnecessary_statements
        print(context.params!['name']);
      },
    ),
  );
  await app.build();
}
