import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl()
    ..post(
      '/post-route',
      MiddlewareBuilder(
        (final context) async {
          final body = await context.body; // JSON body.
          assert(body != null, "Body is not null");
        },
      ),
    );
  await app.build(); //Listening on port 3000
}
