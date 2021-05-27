import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/request.dart';
import 'package:alfred/middleware/impl/request.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.post('/post-route', RequestMiddleware((req) async {
    final body = await AlfredHttpRequestImpl(req, app).body; //JSON body
    // ignore: unnecessary_statements
    body != null; //true
  }));
  await app.listen(); //Listening on port 3000
}
