// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alfred/alfred/impl/parse_http_body.dart';
import 'package:alfred/alfred/interface/parse_http_body.dart';
import 'package:test/test.dart';

void main() {
  test('client response body', _testHttpClientResponseBody);
  test('server request body', _testHttpServerRequestBody);
  test('Does not close stream while requests are pending', () async {
    final data = StreamController<Uint8List>();
    final requests = Stream<HttpRequest>.fromIterable([FakeHttpRequest(Uri(), data: data.stream)]);
    var isDone = false;
    requests.transform(const HttpBodyHandlerImpl(utf8)).listen((_) {}, onDone: () => isDone = true);
    await pumpEventQueue();
    expect(isDone, isFalse);
    await data.close();
    expect(isDone, isTrue);
  });
  test('Closes stream while no requests are pending', () async {
    const requests = Stream<HttpRequest>.empty();
    var isDone = false;
    requests.transform(const HttpBodyHandlerImpl(utf8)).listen((_) {}, onDone: () => isDone = true);
    await pumpEventQueue();
    expect(isDone, isTrue);
  });
}

void _testHttpClientResponseBody() {
  Future<void> check(
    String mimeType,
    List<int> content,
    dynamic expectedBody,
    String type, [
    bool shouldFail = false,
  ]) async {
    final server = await HttpServer.bind('localhost', 0);
    server.listen((request) {
      request.listen((_) {}, onDone: () {
        request.response.headers.contentType = ContentType.parse(mimeType);
        request.response.add(content);
        request.response.close();
      });
    });
    final client = HttpClient();
    try {
      final request = await client.get('localhost', server.port, '/');
      final response = await request.close();
      final body = await HttpBodyHandlerImpl.processResponse(response);
      expect(shouldFail, isFalse);
      expect(body.type, equals(type));
      expect(body.response, isNotNull);
      switch (type) {
        case 'text':
        case 'json':
          expect(body.body, equals(expectedBody));
          break;
        default:
          fail('bad body type');
      }
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      if (!shouldFail) rethrow;
    } finally {
      client.close();
      await server.close();
    }
  }

  check('text/plain', 'body'.codeUnits, 'body', 'text');
  check('text/plain; charset=utf-8', 'body'.codeUnits, 'body', 'text');
  check('text/plain; charset=iso-8859-1', 'body'.codeUnits, 'body', 'text');
  check('text/plain; charset=us-ascii', 'body'.codeUnits, 'body', 'text');
  check('text/plain; charset=utf-8', [42], '*', 'text');
  check('text/plain; charset=us-ascii', [142], null, 'text', true);
  check('text/plain; charset=utf-8', [142], null, 'text', true);
  check('application/json', '{"val": 5}'.codeUnits, {'val': 5}, 'json');
  check('application/json', '{ bad json }'.codeUnits, null, 'json', true);
}

void _testHttpServerRequestBody() {
  Future<void> check(
    String? mimeType,
    List<int> content,
    dynamic expectedBody,
    String type, {
    bool shouldFail = false,
    Encoding defaultEncoding = utf8,
  }) async {
    final server = await HttpServer.bind('localhost', 0);
    server.transform(HttpBodyHandlerImpl(defaultEncoding)).listen((body) {
      if (shouldFail) return;
      expect(shouldFail, isFalse);
      expect(body.type, equals(type));
      switch (type) {
        case 'text':
          expect(body.request.headers.contentType!.mimeType, equals('text/plain'));
          expect(body.body, equals(expectedBody));
          break;
        case 'json':
          expect(body.request.headers.contentType!.mimeType, equals('application/json'));
          expect(body.body, equals(expectedBody));
          break;
        case 'binary':
          expect(body.request.headers.contentType, isNull);
          expect(body.body, equals(expectedBody));
          break;
        case 'form':
          final mimeType = body.request.headers.contentType!.mimeType;
          expect(mimeType, anyOf(equals('multipart/form-data'), equals('application/x-www-form-urlencoded')));
          // ignore: avoid_dynamic_calls
          expect(body.body.keys.toSet(), equals(expectedBody.keys.toSet()));
          // ignore: avoid_dynamic_calls
          for (final key in expectedBody.keys) {
            // ignore: avoid_dynamic_calls
            final dynamic found = body.body[key];
            // ignore: avoid_dynamic_calls
            final dynamic expected = expectedBody[key];
            if (found is HttpBodyFileUpload) {
              // ignore: avoid_dynamic_calls
              expect(found.contentType.toString(), equals(expected['contentType']));
              // ignore: avoid_dynamic_calls
              expect(found.filename, equals(expected['filename']));
              // ignore: avoid_dynamic_calls
              expect(found.content, equals(expected['content']));
            } else {
              expect(found, equals(expected));
            }
          }
          break;
        default:
          throw StateError('bad body type');
      }
      body.request.response.close();
    }, onError: (Object error) {
      // ignore: only_throw_errors
      if (!shouldFail) throw error;
    });
    final client = HttpClient();
    try {
      final request = await client.post('localhost', server.port, '/');
      if (mimeType != null) {
        request.headers.contentType = ContentType.parse(mimeType);
      }
      request.add(content);
      final response = await request.close();
      if (shouldFail) {
        expect(response.statusCode, equals(HttpStatus.badRequest));
      }
      return response.drain();
      // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      if (!shouldFail) rethrow;
    } finally {
      client.close();
      await server.close();
    }
  }

  check('text/plain', 'body'.codeUnits, 'body', 'text');
  check('text/plain; charset=utf-8', 'body'.codeUnits, 'body', 'text');
  check('text/plain; charset=utf-8', [42], '*', 'text');
  check('text/plain; charset=us-ascii', [142], null, 'text', shouldFail: true);
  check('text/plain; charset=utf-8', [142], null, 'text', shouldFail: true);
  check('application/json', '{"val": 5}'.codeUnits, {'val': 5}, 'json');
  check('application/json', '{ bad json }'.codeUnits, null, 'json', shouldFail: true);
  check(null, 'body'.codeUnits, 'body'.codeUnits, 'binary');
  check(
      'multipart/form-data; boundary=AaB03x',
      '''
--AaB03x\r
Content-Disposition: form-data; name="name"\r
\r
Larry\r
--AaB03x--\r\n'''
          .codeUnits,
      {'name': 'Larry'},
      'form');
  check(
      'multipart/form-data; boundary=AaB03x',
      '''
--AaB03x\r
Content-Disposition: form-data; name="files"; filename="myfile"\r
Content-Type: application/octet-stream\r
\r
File content\r
--AaB03x--\r\n'''
          .codeUnits,
      {
        'files': {'filename': 'myfile', 'contentType': 'application/octet-stream', 'content': 'File content'.codeUnits}
      },
      'form');
  check(
      'multipart/form-data; boundary=AaB03x',
      '''
--AaB03x\r
Content-Disposition: form-data; name="files"; filename="myfile"\r
Content-Type: application/octet-stream\r
\r
File content\r
--AaB03x\r
Content-Disposition: form-data; name="files"; filename="myfile"\r
Content-Type: text/plain\r
\r
File content\r
--AaB03x--\r\n'''
          .codeUnits,
      {
        'files': {'filename': 'myfile', 'contentType': 'text/plain', 'content': 'File content'}
      },
      'form');
  check(
      'multipart/form-data; boundary=AaB03x',
      '''
--AaB03x\r
Content-Disposition: form-data; name="files"; filename="myfile"\r
Content-Type: application/json\r
\r
File content\r
--AaB03x--\r\n'''
          .codeUnits,
      {
        'files': {'filename': 'myfile', 'contentType': 'application/json', 'content': 'File content'}
      },
      'form');
  check(
      'application/x-www-form-urlencoded',
      '%E5%B9%B3%3D%E4%BB%AE%E5%90%8D=%E5%B9%B3%E4%BB%AE%E5%90%8D&b'
              '=%E5%B9%B3%E4%BB%AE%E5%90%8D'
          .codeUnits,
      {'平=仮名': '平仮名', 'b': '平仮名'},
      'form');
  check('application/x-www-form-urlencoded', 'a=%F8+%26%23548%3B'.codeUnits, null, 'form', shouldFail: true);
  check('application/x-www-form-urlencoded', 'a=%C0%A0'.codeUnits, null, 'form', shouldFail: true);
  check('application/x-www-form-urlencoded', 'a=x%A0x'.codeUnits, null, 'form', shouldFail: true);
  check('application/x-www-form-urlencoded', 'a=x%C0x'.codeUnits, null, 'form', shouldFail: true);
  check('application/x-www-form-urlencoded', 'a=%C3%B8+%C8%A4'.codeUnits, {'a': 'ø Ȥ'}, 'form');
  check('application/x-www-form-urlencoded', 'a=%F8+%26%23548%3B'.codeUnits, {'a': 'ø &#548;'}, 'form', defaultEncoding: latin1);
  check('application/x-www-form-urlencoded', 'name=%26'.codeUnits, {'name': '&'}, 'form', defaultEncoding: latin1);
  check('application/x-www-form-urlencoded', 'name=%F8%26'.codeUnits, {'name': 'ø&'}, 'form', defaultEncoding: latin1);
  check('application/x-www-form-urlencoded', 'name=%26%3B'.codeUnits, {'name': '&;'}, 'form', defaultEncoding: latin1);
  check('application/x-www-form-urlencoded', 'name=%26%23548%3B%26%23548%3B'.codeUnits, {'name': '&#548;&#548;'}, 'form',
      defaultEncoding: latin1);
  check('application/x-www-form-urlencoded', 'name=%26'.codeUnits, {'name': '&'}, 'form');
  check('application/x-www-form-urlencoded', 'name=%C3%B8%26'.codeUnits, {'name': 'ø&'}, 'form');
  check('application/x-www-form-urlencoded', 'name=%26%3B'.codeUnits, {'name': '&;'}, 'form');
  check('application/x-www-form-urlencoded', 'name=%C8%A4%26%23548%3B'.codeUnits, {'name': 'Ȥ&#548;'}, 'form');
  check('application/x-www-form-urlencoded', 'name=%C8%A4%C8%A4'.codeUnits, {'name': 'ȤȤ'}, 'form');
}

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = HashMap<String, List<String>>();

  FakeHttpHeaders();

  @override
  List<String>? operator [](String key) => _headers[key];

  @override
  int get contentLength => int.parse(_headers[HttpHeaders.contentLengthHeader]![0]);

  @override
  DateTime? get ifModifiedSince {
    final values = _headers[HttpHeaders.ifModifiedSinceHeader];
    if (values != null) {
      try {
        return HttpDate.parse(values[0]);
      } on Exception {
        return null;
      }
    }
    return null;
  }

  @override
  set ifModifiedSince(DateTime? ifModifiedSince) {
    ArgumentError.checkNotNull(ifModifiedSince);
    // Format "ifModifiedSince" header with date in Greenwich Mean Time (GMT).
    final formatted = HttpDate.format(ifModifiedSince!.toUtc());
    _set(HttpHeaders.ifModifiedSinceHeader, formatted);
  }

  @override
  ContentType? contentType;

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    if (preserveHeaderCase) {
      throw ArgumentError('preserveHeaderCase not supported');
    } else {
      final _name = name.toLowerCase();
      _headers.remove(_name);
      _addAll(_name, value);
    }
  }

  @override
  String? value(String name) {
    final _name = name.toLowerCase();
    final values = _headers[_name];
    if (values == null) {
      return null;
    } else {
      if (values.length > 1) {
        throw HttpException('More than one value for header $_name');
      } else {
        return values[0];
      }
    }
  }

  @override
  String toString() => '$runtimeType : $_headers';

  // [name] must be a lower-case version of the name.
  void _add(String name, Object value) {
    if (name == HttpHeaders.ifModifiedSinceHeader) {
      if (value is DateTime) {
        ifModifiedSince = value;
      } else if (value is String) {
        _set(HttpHeaders.ifModifiedSinceHeader, value);
      } else {
        throw HttpException('Unexpected type for header named $name');
      }
    } else {
      _addValue(name, value);
    }
  }

  void _addAll(String name, Object value) {
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        _add(name, value[i] as Object);
      }
    } else {
      _add(name, value);
    }
  }

  void _addValue(String name, Object value) {
    var values = _headers[name];
    if (values == null) {
      values = <String>[];
      _headers[name] = values;
    }
    if (value is DateTime) {
      values.add(HttpDate.format(value));
    } else {
      values.add(value.toString());
    }
  }

  void _set(String name, String value) {
    assert(name == name.toLowerCase(), "$name must be canonicalized to its lowercase version.");
    _headers[name] = [value];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    print([invocation.memberName, invocation.isGetter, invocation.isSetter, invocation.isMethod, invocation.isAccessor]);
    return super.noSuchMethod(invocation);
  }
}

class FakeHttpRequest extends StreamView<Uint8List> implements HttpRequest {
  @override
  final Uri uri;
  @override
  // ignore: close_sinks, just for tests, doesn't need to be closed.
  final FakeHttpResponse response = FakeHttpResponse();
  @override
  final HttpHeaders headers = FakeHttpHeaders();
  @override
  final String method = 'GET';
  final bool followRedirects;

  FakeHttpRequest(
    this.uri, {
    required Stream<Uint8List> data,
    this.followRedirects = true,
    DateTime? ifModifiedSince,
  }) : super(data) {
    if (ifModifiedSince != null) {
      headers.ifModifiedSince = ifModifiedSince;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHttpResponse implements HttpResponse {
  @override
  final HttpHeaders headers = FakeHttpHeaders();
  final Completer<dynamic> _completer = Completer<dynamic>();
  final List<int> _buffer = <int>[];
  String? _reasonPhrase;
  late final Future<dynamic> _doneFuture;

  FakeHttpResponse() {
    _doneFuture = _completer.future.whenComplete(() {
      // ignore: prefer_asserts_with_message
      assert(!_isDone);
      _isDone = true;
    });
  }

  bool _isDone = false;

  @override
  int statusCode = HttpStatus.ok;

  @override
  String get reasonPhrase => _findReasonPhrase(statusCode)!;

  @override
  set reasonPhrase(String value) => _reasonPhrase = value;

  @override
  Future<dynamic> get done => _doneFuture;

  @override
  Future<dynamic> close() {
    _completer.complete();
    return _doneFuture;
  }

  @override
  void add(List<int> data) => _buffer.addAll(data);

  @override
  void addError(dynamic error, [StackTrace? stackTrace]) {
    // doesn't seem to be hit...hmm...
  }

  @override
  Future<dynamic> redirect(Uri location, {int status = HttpStatus.movedTemporarily}) {
    statusCode = status;
    headers.set(HttpHeaders.locationHeader, location.toString());
    return close();
  }

  @override
  void write(Object? obj) => add(utf8.encode(obj.toString()));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  String get fakeContent => utf8.decode(_buffer);

  List<int> get fakeContentBinary => _buffer;

  bool get fakeDone => _isDone;

  // Copied from SDK http_impl.dart @ 845 on 2014-01-05
  // TODO: file an SDK bug to expose this on HttpStatus in some way
  String? _findReasonPhrase(int statusCode) {
    if (_reasonPhrase != null) {
      return _reasonPhrase;
    } else {
      switch (statusCode) {
        case HttpStatus.notFound:
          return 'Not Found';
        default:
          return 'Status $statusCode';
      }
    }
  }
}
