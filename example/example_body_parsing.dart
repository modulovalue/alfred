import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:alfred/middleware/impl/request.dart';

Future<void> main() async {
  final app = Alfred();
  app.post('/post-route', RequestMiddleware((req) async {
    final body = await req.body; //JSON body
    // ignore: unnecessary_statements
    body != null; //true
  }));
  await app.listen(); //Listening on port 3000
}
