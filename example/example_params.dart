import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all(
    '/example/:id/:name',
    MiddlewareBuilder(
      (final context) async {
        // ignore: unnecessary_statements
        print(context.arguments!['id']);
        // ignore: unnecessary_statements
        print(context.arguments!['name']);
      },
    ),
  );
  await app.build();
}
