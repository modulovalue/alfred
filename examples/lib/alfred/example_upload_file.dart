import 'dart:io';

import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:alfred/alfred/middleware/json.dart';
import 'package:alfred/alfred/middleware_io/io_dir.dart';

Future<void> main() async {
  final _uploadDirectory = Directory(
    'uploadedFiles',
  );
  // Example of handling a multipart/form-data file upload.
  await helloAlfred(
    routes: [
      AlfredRoute.get(
        path: '/files/*',
        middleware: ServeDirectoryIoDirectoryImpl(
          directory: _uploadDirectory,
        ),
      ),
      AlfredRoute.post(
        path: '/upload',
        middleware: ServeJsonBuilder.map(
          map: (final context) async {
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
              if (uploadedFile is AlfredHttpBodyFileUpload) {
                final dynamic _content = uploadedFile.content;
                if (_content is List<int>) {
                  final fileBytes = _content;
                  // Create the local file name and save the file
                  await File(_uploadDirectory.absolute.path + '/' + uploadedFile.filename)
                      .writeAsBytes(fileBytes);
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
      ),
    ],
  );
}
