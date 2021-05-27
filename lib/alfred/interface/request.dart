import 'dart:async';
import 'dart:io';

import '../../store/interface/store.dart';

abstract class AlfredHttpRequest {
  HttpRequest get rawRequest;

  /// Parse the body automatically and return the result
  Future<Object?> get body;

  /// Parse the body, and convert it to a json map
  Future<Map<String, dynamic>> get bodyAsJsonMap;

  /// Parse the body, and convert it to a json list
  Future<List<dynamic>> get bodyAsJsonList;

  /// Get the content type
  ContentType? get contentType;

  /// Get params
  Map<String, String> get params;

  /// Get the matched route of the current request
  String get route;

  RequestStore get store;
}
