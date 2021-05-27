import 'dart:async';
import 'dart:io';

abstract class AlfredHttpResponse {
  HttpResponse get rawResponse;

  /// Set the appropriate headers to download the file
  void setDownload({required String filename});

  /// Set the content type from the extension ie. 'pdf'
  void setContentTypeFromExtension(String extension);

  /// Set the content type given a file
  void setContentTypeFromFile(File file);

  /// Helper method for those used to res.json()
  Future<dynamic> json(Object? json);

  /// Helper method to just send data;
  Future<dynamic> send(Object? data);
}
