import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/middleware/impl/request.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.post('/route', RequestMiddleware((req) async {
    /// Handle /route?qsvar=true
    final result = req.uri.queryParameters['qsvar'];
    // ignore: unnecessary_statements
    result == 'true'; //true
  }));
  await app.listen(); //Listening on port 3000
}
