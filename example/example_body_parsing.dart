import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/impl.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.post('/post-route', MiddlewareBuilder((context) async {
    final body = await context.body; //JSON body
    assert(body != null, "Body is not null");
  }));
  await app.build(); //Listening on port 3000
}
