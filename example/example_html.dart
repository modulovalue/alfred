import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/value.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/html', const ServeHtml('<html><body><h1>Title!</h1></body></html>'));
  await app.build(); //Listening on port 3000
}
