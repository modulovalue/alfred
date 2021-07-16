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
        final _body = await context.body;
        if (_body is Map?) {
          final body = Map<String, dynamic>.from(_body!);
          // Create the upload directory if it doesn't exist
          // ignore: avoid_slow_async_io
          if (await _uploadDirectory.exists() == false) {
            await _uploadDirectory.create();
          }
          // Get the uploaded file content
          final dynamic uploadedFile = body['file'];
          if (uploadedFile is HttpBodyFileUpload) {
            final dynamic _content = uploadedFile.content;
            if (_content is List<int>) {
              final fileBytes = _content;
              // Create the local file name and save the file
              await File(_uploadDirectory.absolute.path + '/' + uploadedFile.filename).writeAsBytes(fileBytes);
              // Return the path to the user.
              //
              // The path is served from the /files route above.
              return {
                'path': 'https://' + (context.req.headers.host ?? '') + '/files/' + uploadedFile.filename,
              };
            } else {
              throw Exception("Expected file to be a list of integers.");
            }
          } else {
            throw Exception("Expected file to be of type HttpBodyFileUpload.");
          }
        } else {
          throw Exception("Expected a body of type Map.");
        }
      },
    ),
  );
  await app.build(log: log);
}
