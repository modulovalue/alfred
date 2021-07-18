import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';

void main() {
  final app = AlfredImpl();
  // The app will now return the Chicken.response if you return one from a route.
  app.get('/kfc', const ServeString('I am a chicken')); // I am a chicken.
  app.build(); // Listening on 3000.
}
