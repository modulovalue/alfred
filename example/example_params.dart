import 'package:alfred/alfred.dart';

Future<void> main() async {
  final app = Alfred();
  app.all('/example/:id/:name', (req, res) {
    // ignore: unnecessary_statements
    req.params['id'] != null;
    // ignore: unnecessary_statements
    req.params['name'] != null;
  });
  await app.listen();
}
