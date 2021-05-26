import 'package:alfred/alfred.dart';

Future<void> main() async {
  final app = Alfred();

  app.post('/route', (req, res) async {
    /// Handle /route?qsvar=true
    final result = req.uri.queryParameters['qsvar'];
    // ignore: unnecessary_statements
    result == 'true'; //true
  });

  await app.listen(); //Listening on port 3000
}
