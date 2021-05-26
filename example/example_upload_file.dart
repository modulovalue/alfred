import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:alfred/middleware/impl/request.dart';
import 'package:alfred/middleware/impl/value.dart';
import 'package:alfred/parser_http_body.dart';

Future<void> main() async {
  final _uploadDirectory = Directory('uploadedFiles');
  final app = Alfred();
  app.get('/files/*', ValueMiddleware(_uploadDirectory));

  /// Example of handling a multipart/form-data file upload
  app.post(
    '/upload',
    RequestMiddleware((req) async {
      final body = await req.bodyAsJsonMap;
      // Create the upload directory if it doesn't exist
      // ignore: avoid_slow_async_io
      if (await _uploadDirectory.exists() == false) {
        await _uploadDirectory.create();
      }
      // Get the uploaded file content
      final uploadedFile = body['file'] as HttpBodyFileUpload;
      final fileBytes = uploadedFile.content as List<int>;
      // Create the local file name and save the file
      await File('${_uploadDirectory.absolute}/${uploadedFile.filename}').writeAsBytes(fileBytes);

      /// Return the path to the user
      ///
      /// The path is served from the /files route above
      return {'path': 'https://${req.headers.host ?? ''}/files/${uploadedFile.filename}'};
    }),
  );
  await app.listen();
}
