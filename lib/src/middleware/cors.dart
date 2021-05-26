import 'dart:async';
import 'dart:io';

import '../../alfred.dart';

/// CORS Middlware.
///
/// Has some sensible defaults. You probably want to change the origin
FutureOr<dynamic> Function(HttpRequest, HttpResponse) cors({
  int age = 86400,
  String headers = '*',
  String methods = 'POST, GET, OPTIONS, PUT, PATCH',
  String origin = '*',
}) => (HttpRequest req, HttpResponse res) {
    res.headers.set('Access-Control-Allow-Origin', origin);
    res.headers.set('Access-Control-Allow-Methods', methods);
    res.headers.set('Access-Control-Allow-Headers', headers);
    res.headers.set('Access-Control-Max-Age', age);
    if (req.method == 'OPTIONS') {
      res.close();
    }
  };
