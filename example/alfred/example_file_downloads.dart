import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';

Future<void> main() async {
  final app = AlfredImpl()
    ..get(
      '/image/download',
      ServeDownload(
        filename: 'image.jpg',
        child: ServeFile.at('test/files/image.jpg'),
      ),
    );
  await app.build(); //Listening on port 3000
}
