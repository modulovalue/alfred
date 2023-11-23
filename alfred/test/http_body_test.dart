// ignore_for_file: discarded_futures

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/alfred_io.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:test/test.dart';

void main() {
  test('client response body', () {
    // TODO clean this up.
    Future<void> check(
      final String mimeType,
      final List<int> content,
      final dynamic expectedBody,
      final String type, [
      final bool shouldFail = false,
    ]) async {
      final server = await HttpServer.bind('localhost', 0);
      server.listen(
        (final request) {
          request.listen(
            (final _) {},
            onDone: () {
              request.response.headers.contentType = ContentType.parse(mimeType);
              request.response.add(content);
              request.response.close();
            },
          );
        },
      );
      final client = HttpClient();
      try {
        final request = await client.get(
          'localhost',
          server.port,
          '/',
        );
        final response = await request.close();
        final body = await processResponse(response);
        expect(shouldFail, isFalse);
        expect(body.httpBody.type, equals(type));
        expect(body.response, isNotNull);
        switch (type) {
          case 'text':
          case 'json':
            expect(body.httpBody.body, equals(expectedBody));
            break;
          default:
            fail('bad body type');
        }
        // ignore: avoid_catches_without_on_clauses
      } catch (_) {
        if (!shouldFail) {
          rethrow;
        }
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
  });
  test('server request body', () {
    // TODO clean this up.
    Future<void> check(
      final String? mimeType,
      final List<int> content,
      final dynamic expectedBody,
      final String type, {
      final bool shouldFail = false,
      final Encoding defaultEncoding = utf8,
    }) async {
      final server = await HttpServer.bind(
        'localhost',
        0,
      );
      HttpBodyHandlerImpl(defaultEncoding)
          .bind(
        server.map(
          (final a) => AlfredRequestImpl(
            req: a,
            response: AlfredResponseImpl(
              res: a.response,
            ),
          ),
        ),
      )
          .listen(
        (final body) {
          if (shouldFail) {
            return;
          } else {
            expect(shouldFail, isFalse);
            expect(body.httpBody.type, equals(type));
            switch (type) {
              case 'text':
                expect(body.request.mime_type, equals('text/plain'));
                expect(body.httpBody.body, equals(expectedBody));
                break;
              case 'json':
                expect(body.request.mime_type, equals('application/json'));
                expect(body.httpBody.body, equals(expectedBody));
                break;
              case 'binary':
                expect(body.request.mime_type, isNull);
                expect(body.httpBody.body, equals(expectedBody));
                break;
              case 'form':
                final mimeType = body.request.mime_type;
                expect(mimeType, anyOf(equals('multipart/form-data'), equals('application/x-www-form-urlencoded')));
                // ignore: avoid_dynamic_calls
                expect(body.httpBody.body.keys.toSet(), equals(expectedBody.keys.toSet()));
                // ignore: avoid_dynamic_calls
                for (final key in (expectedBody as Map).keys) {
                  // ignore: avoid_dynamic_calls
                  final dynamic found = body.httpBody.body[key];
                  // ignore: avoid_dynamic_calls
                  final dynamic expected = expectedBody[key];
                  if (found is AlfredHttpBodyFileUpload) {
                    // ignore: avoid_dynamic_calls
                    expect(
                      found.content_type!.primary_type + "/" + found.content_type!.sub_type,
                      // ignore: avoid_dynamic_calls
                      equals(expected['contentType']),
                    );
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
          }
        },
        onError: (final Object error) {
          if (!shouldFail) {
            // ignore: only_throw_errors
            throw error;
          }
        },
      );
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
        if (!shouldFail) {
          rethrow;
        }
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
          'files': {
            'filename': 'myfile',
            'contentType': 'application/octet-stream',
            'content': 'File content'.codeUnits
          }
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
    check('application/x-www-form-urlencoded', 'a=%F8+%26%23548%3B'.codeUnits, {'a': 'ø &#548;'}, 'form',
        defaultEncoding: latin1);
    check('application/x-www-form-urlencoded', 'name=%26'.codeUnits, {'name': '&'}, 'form', defaultEncoding: latin1);
    check('application/x-www-form-urlencoded', 'name=%F8%26'.codeUnits, {'name': 'ø&'}, 'form',
        defaultEncoding: latin1);
    check('application/x-www-form-urlencoded', 'name=%26%3B'.codeUnits, {'name': '&;'}, 'form',
        defaultEncoding: latin1);
    check('application/x-www-form-urlencoded', 'name=%26%23548%3B%26%23548%3B'.codeUnits, {'name': '&#548;&#548;'},
        'form',
        defaultEncoding: latin1);
    check('application/x-www-form-urlencoded', 'name=%26'.codeUnits, {'name': '&'}, 'form');
    check('application/x-www-form-urlencoded', 'name=%C3%B8%26'.codeUnits, {'name': 'ø&'}, 'form');
    check('application/x-www-form-urlencoded', 'name=%26%3B'.codeUnits, {'name': '&;'}, 'form');
    check('application/x-www-form-urlencoded', 'name=%C8%A4%26%23548%3B'.codeUnits, {'name': 'Ȥ&#548;'}, 'form');
    check('application/x-www-form-urlencoded', 'name=%C8%A4%C8%A4'.codeUnits, {'name': 'ȤȤ'}, 'form');
  });
  test('Does not close stream while requests are pending', () async {
    final data = StreamController<Uint8List>();
    final req = FakeHttpRequest(
      Uri(),
      data: data.stream,
    );
    final requests = Stream<AlfredRequest>.fromIterable(
      [
        AlfredRequestImpl(
          req: req,
          response: AlfredResponseImpl(
            res: req.response,
          ),
        ),
      ],
    );
    var isDone = false;
    const HttpBodyHandlerImpl(utf8).bind(requests).listen(
          (final _) {},
          onDone: () => isDone = true,
        );
    await pumpEventQueue();
    expect(isDone, isFalse);
    await data.close();
    expect(isDone, isTrue);
  });
  test('Closes stream while no requests are pending', () async {
    const requests = Stream<AlfredRequest>.empty();
    var isDone = false;
    const HttpBodyHandlerImpl(utf8).bind(requests).listen(
          (final _) {},
          onDone: () => isDone = true,
        );
    await pumpEventQueue();
    expect(isDone, isTrue);
  });
}

class FakeHttpHeaders implements HttpHeaders {
  final Map<String, List<String>> _headers = HashMap<String, List<String>>();

  FakeHttpHeaders();

  @override
  List<String>? operator [](
    final String key,
  ) =>
      _headers[key];

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
  set ifModifiedSince(
    final DateTime? ifModifiedSince,
  ) {
    ArgumentError.checkNotNull(ifModifiedSince);
    // Format "ifModifiedSince" header with date in Greenwich Mean Time (GMT).
    final formatted = HttpDate.format(ifModifiedSince!.toUtc());
    _set(HttpHeaders.ifModifiedSinceHeader, formatted);
  }

  @override
  ContentType? contentType;

  @override
  void set(
    final String name,
    final Object value, {
    final bool preserveHeaderCase = false,
  }) {
    if (preserveHeaderCase) {
      throw ArgumentError('preserveHeaderCase not supported');
    } else {
      final _name = name.toLowerCase();
      _headers.remove(_name);
      _addAll(_name, value);
    }
  }

  @override
  String? value(
    final String name,
  ) {
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

  /// [name] must be a lower-case version of the name.
  void _add(
    final String name,
    final Object value,
  ) {
    if (name == HttpHeaders.ifModifiedSinceHeader) {
      if (value is DateTime) {
        ifModifiedSince = value;
      } else if (value is String) {
        _set(HttpHeaders.ifModifiedSinceHeader, value);
      } else {
        throw HttpException('Unexpected type for header named ' + name);
      }
    } else {
      _addValue(name, value);
    }
  }

  void _addAll(
    final String name,
    final Object value,
  ) {
    if (value is List<dynamic>) {
      for (var i = 0; i < value.length; i++) {
        final dynamic val = value[i];
        if (val is Object) {
          _add(name, val);
        } else {
          throw Exception("Expected a value of type Object.");
        }
      }
    } else {
      _add(name, value);
    }
  }

  void _addValue(
    final String name,
    final Object value,
  ) {
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

  void _set(
    final String name,
    final String value,
  ) {
    assert(
      name == name.toLowerCase(),
      name + " must be canonicalized to its lowercase version.",
    );
    _headers[name] = [value];
  }

  @override
  dynamic noSuchMethod(
    final Invocation invocation,
  ) {
    print([
      invocation.memberName,
      invocation.isGetter,
      invocation.isSetter,
      invocation.isMethod,
      invocation.isAccessor,
    ]);
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
    required final Stream<Uint8List> data,
    this.followRedirects = true,
    final DateTime? ifModifiedSince,
  }) : super(data) {
    if (ifModifiedSince != null) {
      headers.ifModifiedSince = ifModifiedSince;
    }
  }

  @override
  dynamic noSuchMethod(
    final Invocation invocation,
  ) =>
      super.noSuchMethod(invocation);
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
  set reasonPhrase(
    final String value,
  ) =>
      _reasonPhrase = value;

  @override
  Future<dynamic> get done => _doneFuture;

  @override
  Future<dynamic> close() {
    _completer.complete();
    return _doneFuture;
  }

  @override
  void add(
    final List<int> data,
  ) =>
      _buffer.addAll(data);

  @override
  void addError(
    final dynamic error, [
    final StackTrace? stackTrace,
  ]) {
    // doesn't seem to be hit...hmm...
  }

  @override
  Future<dynamic> redirect(
    final Uri location, {
    final int status = HttpStatus.movedTemporarily,
  }) {
    statusCode = status;
    headers.set(HttpHeaders.locationHeader, location.toString());
    return close();
  }

  @override
  void write(
    final Object? obj,
  ) =>
      add(utf8.encode(obj.toString()));

  @override
  dynamic noSuchMethod(
    final Invocation invocation,
  ) =>
      super.noSuchMethod(invocation);

  String get fakeContent => utf8.decode(_buffer);

  List<int> get fakeContentBinary => _buffer;

  bool get fakeDone => _isDone;

  // Copied from SDK http_impl.dart @ 845 on 2014-01-05
  // TODO: file an SDK bug to expose this on HttpStatus in some way
  String? _findReasonPhrase(
    final int statusCode,
  ) {
    if (_reasonPhrase != null) {
      return _reasonPhrase;
    } else {
      switch (statusCode) {
        case HttpStatus.notFound:
          return 'Not Found';
        default:
          return 'Status ' + statusCode.toString();
      }
    }
  }
}
