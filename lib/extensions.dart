import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../base.dart';
import 'http_route.dart';
import 'mime.dart';
import 'parser_http_body.dart';
import 'plugin_store.dart';

/// TODO consider having wrapper for third party types and putting the extensions into them.

/// A set of extensions on the [HttpResponse] object, mostly for convenience
extension ResponseHelpers on HttpResponse {
  /// Set the appropriate headers to download the file
  ///
  void setDownload({required String filename}) {
    headers.add('Content-Disposition', 'attachment; filename=$filename');
  }

  /// Set the content type from the extension ie. 'pdf'
  ///
  void setContentTypeFromExtension(String extension) {
    final mime = mimeFromExtension(extension);
    if (mime != null) {
      final split = mime.split('/');
      headers.contentType = ContentType(split[0], split[1]);
    }
  }

  /// Set the content type given a file
  void setContentTypeFromFile(File file) {
    if (headers.contentType == null || headers.contentType!.mimeType == 'text/plain') {
      headers.contentType = fileContentType(file);
    }
  }

  /// Helper method for those used to res.json()
  Future<dynamic> json(Object? json) {
    headers.contentType = ContentType.json;
    write(jsonEncode(json));
    return close();
  }

  /// Helper method to just send data;
  Future<dynamic> send(Object? data) {
    write(data);
    return close();
  }
}

/// Some convenience methods on the [HttpRequest] object to make the api
/// more like ExpressJS
extension RequestHelpers on HttpRequest {
  /// Parse the body automatically and return the result
  Future<Object?> get body async => (await HttpBodyHandler.processRequest(this)).body;

  /// Parse the body, and convert it to a json map
  Future<Map<String, dynamic>> get bodyAsJsonMap async => Map<String, dynamic>.from((await body as Map?)!);

  /// Parse the body, and convert it to a json list
  Future<List<dynamic>> get bodyAsJsonList async => (await body as List?)!;

  /// Get the content type
  ContentType? get contentType => headers.contentType;

  /// Get params
  Map<String, String> get params => RouteMatcher.getParams(route, uri.path);

  /// Get the matched route of the current request
  String get route => store.get<String?>('_internal_route') ?? '';

  /// TODO consider plumbing alfred through everywhere explicitly or have it be in the httprequest wrapper.
  /// Get Alfred instance which is associated with this request
  Alfred get alfred => store.get<Alfred>('_internal_alfred');

  /// Returns the [RequestStore] dedicated to this request.
  RequestStore get store => StorePluginData.singleton.update(this, RequestStoreImpl());
}
