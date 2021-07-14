import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all(
    '*',
    MiddlewareBuilder((c) async {
      // Perform action
      c.req.headers.add(
        'x-custom-header',
        "Alfred isn't bad",
      );
      // No need to call next as we don't send a response.
      // Alfred will find the next matching route
    }),
  );
  // Action performed next.
  app.get(
    '/otherFunction',
    const ServeJson.map(
      {
        'message': 'complete',
      },
    ),
  );
  await app.build();
}
