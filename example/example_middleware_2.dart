import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/middleware/impl/request.dart';
import 'package:alfred/middleware/impl/value.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.all('*', RequestMiddleware((req) {
    // Perform action
    req.headers.add('x-custom-header', "Alfred isn't bad");
    /// No need to call next as we don't send a response.
    /// Alfred will find the next matching route
  }));
    //Action performed next
  app.get('/otherFunction', const ValueMiddleware({'message': 'complete'}));
  await app.listen();
}
