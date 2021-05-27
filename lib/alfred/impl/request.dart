import 'dart:async';
import 'dart:io';

import '../../alfred/impl/alfred.dart';
import '../../parse_http_body/interface/parse_http_body.dart';
import '../../store/impl/store.dart';
import '../../store/interface/store.dart';
import '../interface/alfred.dart';
import '../interface/request.dart';

class AlfredHttpRequestImpl implements AlfredHttpRequest {
  @override
  final HttpRequest rawRequest;
  final Alfred alfred;

  const AlfredHttpRequestImpl(this.rawRequest, this.alfred);

  @override
  Future<Object?> get body async => //
      (await HttpBodyHandler.processRequest(rawRequest)).body;

  @override
  Future<Map<String, dynamic>> get bodyAsJsonMap async => //
      Map<String, dynamic>.from((await body as Map?)!);

  @override
  Future<List<dynamic>> get bodyAsJsonList async => //
      (await body as List?)!;

  @override
  ContentType? get contentType => //
      rawRequest.headers.contentType;

  @override
  Map<String, String> get params => //
      RouteMatcher.getParams(route, rawRequest.uri.path);

  @override
  RequestStore get store => alfred.store.update(rawRequest, () => RequestStoreImpl());

  @override
  String get route => //
      store.get<String?>('_internal_route') ?? '';
}
