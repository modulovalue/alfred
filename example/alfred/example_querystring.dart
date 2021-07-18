import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.post(
    '/route',
    MiddlewareBuilder((c) async {
      /// Handle /route?qsvar=true
      final result = c.req.uri.queryParameters['qsvar'];
      // ignore: unnecessary_statements
      result == 'true'; //true
      await c.res.close();
    }),
  );
  await app.build(); //Listening on port 3000
}
