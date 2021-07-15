import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';
import 'package:alfred/alfred/impl/middleware/json_builder.dart';
import 'package:alfred/alfred/interface/parse_http_body.dart';

Future<void> main() async {
  final _uploadDirectory = Directory('uploadedFiles');
  final app = AlfredImpl();
  const log = AlfredLoggingDelegatePrintImpl();
  app.get('/files/*', ServeDirectory(_uploadDirectory, log));
  // Example of handling a multipart/form-data file upload.
  app.post(
    '/upload',
    // TODO replace with json builder.
    ServeJsonBuilder.map(
      (final context) async {
        final body = Map<String, dynamic>.from((await context.body as Map?)!);
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
        // Return the path to the user.
        //
        // The path is served from the /files route above.
        return {
          'path': 'https://${context.req.headers.host ?? ''}/files/${uploadedFile.filename}',
        };
      },
    ),
  );
  await app.build(log: log);
}
