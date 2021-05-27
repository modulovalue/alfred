import 'dart:convert';
import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/request.dart';
import 'package:alfred/alfred/impl/response.dart';
import 'package:alfred/base/interface/exception.dart';
import 'package:alfred/logging/impl/generalizing/log_type.dart';
import 'package:alfred/logging/impl/generalizing/mixin.dart';
import 'package:alfred/middleware/impl/callback.dart';
import 'package:alfred/middleware/impl/cors.dart';
import 'package:alfred/middleware/impl/empty.dart';
import 'package:alfred/middleware/impl/impl.dart';
import 'package:alfred/middleware/impl/null.dart';
import 'package:alfred/middleware/impl/request.dart';
import 'package:alfred/middleware/impl/response.dart';
import 'package:alfred/middleware/impl/value.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'common.dart';

/// TODO replace image.jpg with something neutral.
void main() {
  test('runTest should be called', () async {
    bool called = false;
    await runTest(fn: (app, port) async {
      called = true;
    });
    expect(called, true);
  });
  test('it should return a string correctly', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', MiddlewareImpl((req, res) => 'test string'));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'test string');
    });
  });
  test('it should return json', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', MiddlewareImpl((req, res) => {'test': true}));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.headers['content-type'], 'application/json; charset=utf-8');
      expect(response.body, '{"test":true}');
    });
  });
  test('it should return an image', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', MiddlewareImpl((req, res) => File('test/files/image.jpg')));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.headers['content-type'], 'image/jpeg');
    });
  });
  test('it should return a pdf', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', MiddlewareImpl((req, res) => File('test/files/dummy.pdf')));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.headers['content-type'], 'application/pdf');
    });
  });
  test('routing should, you know, work', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', MiddlewareImpl((req, res) => 'test_route'));
      app.get('/testRoute', MiddlewareImpl((req, res) => 'test_route_route'));
      app.get('/a', MiddlewareImpl((req, res) => 'a_route'));
      expect((await http.get(Uri.parse('http://localhost:$port/test'))).body, 'test_route');
      expect((await http.get(Uri.parse('http://localhost:$port/testRoute'))).body, 'test_route_route');
      expect((await http.get(Uri.parse('http://localhost:$port/a'))).body, 'a_route');
    });
  });
  test('error handling', () async {
    await runTest(fn: (app, port) async {
      await app.close();
      app = AlfredImpl(onInternalError: MiddlewareImpl((req, res) {
        res.statusCode = 500;
        return {'message': 'error not handled'};
      }));
      await app.listen(port);
      app.get('/throwserror', MiddlewareImpl((req, res) => throw Exception('generic exception')));
      expect((await http.get(Uri.parse('http://localhost:$port/throwserror'))).body, '{"message":"error not handled"}');
    });
  });
  test('error default handling', () async {
    await runTest(fn: (app, port) async {
      await app.close();
      app = AlfredImpl();
      await app.listen(port);
      app.get('/throwserror', MiddlewareImpl((req, res) => throw Exception('generic exception')));
      final response = await http.get(Uri.parse('http://localhost:$port/throwserror'));
      expect(response.body, 'Exception: generic exception');
    });
  });
  test('not found handling', () async {
    await runTest(fn: (app, port) async {
      await app.close();
      app = AlfredImpl(onNotFound: MiddlewareImpl((req, res) {
        res.statusCode = 404;
        return {'message': 'not found'};
      }));
      await app.listen(port);
      final response = await http.get(Uri.parse('http://localhost:$port/notfound'));
      expect(response.body, '{"message":"not found"}');
      expect(response.statusCode, 404);
    });
  });
  test('not found default handling', () async {
    await runTest(fn: (app, port) async {
      await app.close();
      app = AlfredImpl();
      await app.listen(port);
      final response = await http.get(Uri.parse('http://localhost:$port/notfound'));
      expect(response.body, '404 not found');
      expect(response.statusCode, 404);
    });
  });
  test('not found with middleware', () async {
    await runTest(fn: (app, port) async {
      app.all('*', const CorsMiddleware());
      app.get('resource2', const EmptyMiddleware());
      final r1 = await http.get(Uri.parse('http://localhost:$port/resource1'));
      expect(r1.body, '404 not found');
      expect(r1.statusCode, 404);
      final r2 = await http.get(Uri.parse('http://localhost:$port/resource2'));
      expect(r2.body, '');
      expect(r2.statusCode, 200);
    });
  });
  test('not found with directory type handler', () async {
    await runTest(fn: (app, port) async {
      app.get('/files/*', MiddlewareImpl((req, res) => Directory('test/files')));
      final r = await http.get(Uri.parse('http://localhost:$port/files/no-file.zip'));
      expect(r.body, '404 not found');
      expect(r.statusCode, 404);
    });
  });
  test('not found with file type handler', () async {
    await runTest(
      fn: (app, port) async {
        app.get('/index.html', MiddlewareImpl((req, res) => File('does-not.exists')));
        final r = await http.get(Uri.parse('http://localhost:$port/index.html'));
        expect(r.body, 'Custom404Message');
        expect(r.statusCode, 404);
      },
      notFound: MiddlewareImpl((req, res) {
        res.statusCode = HttpStatus.notFound;
        return 'Custom404Message';
      }),
    );
  });
  test('it handles a post request', () async {
    await runTest(fn: (app, port) async {
      app.post('/test', const ValueMiddleware('test string'));
      final response = await http.post(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles a put request', () async {
    await runTest(fn: (app, port) async {
      app.put('/test', const ValueMiddleware('test string'));
      final response = await http.put(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles a delete request', () async {
    await runTest(fn: (app, port) async {
      app.delete('/test', const ValueMiddleware('test string'));
      final response = await http.delete(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles an options request', () async {
    await runTest(fn: (app, port) async {
      app.options('/test', const ValueMiddleware('test string'));
      // TODO: Need to find a way to send an options request. The HTTP library doesn't
      /// seem to support it.
      // final response = await http.head(Uri.parse("http://localhost:$port/test"));
      // expect(response.body, "test string");
    });
  });
  test('it handles a patch request', () async {
    await runTest(fn: (app, port) async {
      app.patch('/test', const ValueMiddleware('test string'));
      final response = await http.patch(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles a route that hits all methods', () async {
    await runTest(fn: (app, port) async {
      app.all('/test', const ValueMiddleware('test all'));
      final responseGet = await http.get(Uri.parse('http://localhost:$port/test'));
      final responsePost = await http.post(Uri.parse('http://localhost:$port/test'));
      final responsePut = await http.put(Uri.parse('http://localhost:$port/test'));
      final responseDelete = await http.delete(Uri.parse('http://localhost:$port/test'));
      expect(responseGet.body, 'test all');
      expect(responsePost.body, 'test all');
      expect(responsePut.body, 'test all');
      expect(responseDelete.body, 'test all');
    });
  });
  test('it executes middleware, but passes through', () async {
    await runTest(fn: (app, port) async {
      var hitMiddleware = false;
      app.get(
        '/test',
        const ValueMiddleware('test route'),
        middleware: [VoidCallbackMiddleware(() => hitMiddleware = true)],
      );
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'test route');
      expect(hitMiddleware, true);
    });
  });
  test('it executes middleware, but handles it and stops executing', () async {
    await runTest(fn: (app, port) async {
      app.get(
        '/test',
        const ValueMiddleware('test route'),
        middleware: [const ValueMiddleware('hit middleware')],
      );
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'hit middleware');
    });
  });
  test('it closes out a request if you fail to', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', const NullMiddleware());
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, '');
    });
  });
  test('it throws and handles an exception', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', VoidCallbackMiddleware(() => throw const _AlfredExceptionImpl(360, 'exception')));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'exception');
      expect(response.statusCode, 360);
    });
  });
  test('it handles a List<int>', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', const ValueMiddleware(<int>[1, 2, 3, 4, 5]));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, '\x01\x02\x03\x04\x05');
      expect(response.headers['content-type'], 'application/octet-stream');
    });
  });
  test('it handles a Stream<List<int>>', () async {
    await runTest(fn: (app, port) async {
      app.get(
        '/test',
        ValueMiddleware(Stream.fromIterable([
          [1, 2, 3, 4, 5]
        ])),
      );
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, '\x01\x02\x03\x04\x05');
      expect(response.headers['content-type'], 'application/octet-stream');
    });
  });
  test('it parses a body', () async {
    await runTest(fn: (app, port) async {
      app.post('/test', MiddlewareImpl((req, res) async {
        final body = await AlfredHttpRequestImpl(req, app).body;
        expect(body is Map, true);
        expect(AlfredHttpRequestImpl(req, app).contentType!.mimeType, 'application/json');
        return 'test result';
      }));
      final response = await http.post(Uri.parse('http://localhost:$port/test'),
          headers: {'Content-Type': 'application/json'}, body: jsonEncode({'test': true}));
      expect(response.body, 'test result');
    });
  });
  test('it serves a file for download', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', MiddlewareImpl((req, res) {
        AlfredHttpResponseImpl(res).setDownload(filename: 'testfile.jpg');
        return File('./test/files/image.jpg');
      }));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.headers['content-type'], 'image/jpeg');
      expect(response.headers['content-disposition'], 'attachment; filename=testfile.jpg');
    });
  });
  test('it serves a pdf, setting the extension from the filename', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', ResponseMiddleware((res) {
        AlfredHttpResponseImpl(res).setContentTypeFromExtension('pdf');
        return File('./test/files/dummy.pdf');
      }));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.headers['content-type'], 'application/pdf');
      expect(response.headers['content-disposition'], null);
    });
  });
  test('it uses the json helper correctly', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', ResponseMiddleware((res) async {
        await AlfredHttpResponseImpl(res).json({'success': true});
      }));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, '{"success":true}');
    });
  });
  test('it uses the send helper correctly', () async {
    await runTest(fn: (app, port) async {
      app.get('/test', ResponseMiddleware((res) async {
        await AlfredHttpResponseImpl(res).send('stuff');
      }));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.body, 'stuff');
    });
  });
  test('it serves static files', () async {
    await runTest(fn: (app, port) async {
      app.get('/files/*', ValueMiddleware(Directory('test/files')));
      final response = await http.get(Uri.parse('http://localhost:$port/files/dummy.pdf'));
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/pdf');
    });
  });
  test('it serves static files although directories do not match', () async {
    await runTest(fn: (app, port) async {
      app.get('/my/directory/*', ValueMiddleware(Directory('test/files')));
      final response = await http.get(Uri.parse('http://localhost:$port/my/directory/dummy.pdf'));
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/pdf');
    });
  });
  test('it serves static files with basic filtering', () async {
    await runTest(fn: (app, port) async {
      app.get('/my/directory/*.pdf', ValueMiddleware(Directory('test/files')));
      final r1 = await http.get(Uri.parse('http://localhost:$port/my/directory/dummy.pdf'));
      expect(r1.statusCode, 200);
      expect(r1.headers['content-type'], 'application/pdf');
      final r2 = await http.get(Uri.parse('http://localhost:$port/my/directory/image.jpg'));
      expect(r2.statusCode, 404);
    });
  });
  test('it serves SPA projects', () async {
    await runTest(fn: (app, port) async {
      app.get('/spa/*', ValueMiddleware(Directory('test/files/spa')));
      app.get('/spa/*', ValueMiddleware(File('test/files/spa/index.html')));
      final r1 = await http.get(Uri.parse('http://localhost:$port/spa'));
      expect(r1.statusCode, 200);
      expect(r1.headers['content-type'], 'text/html');
      expect(r1.body.contains('I am a SPA Application'), true);
      final r2 = await http.get(Uri.parse('http://localhost:$port/spa/'));
      expect(r2.statusCode, 200);
      expect(r2.headers['content-type'], 'text/html');
      expect(r2.body.contains('I am a SPA Application'), true);
      final r3 = await http.get(Uri.parse('http://localhost:$port/spa/index.html'));
      expect(r3.statusCode, 200);
      expect(r3.headers['content-type'], 'text/html');
      expect(r3.body.contains('I am a SPA Application'), true);
      final r4 = await http.get(Uri.parse('http://localhost:$port/spa/assets/some.txt'));
      expect(r4.statusCode, 200);
      expect(r4.headers['content-type'], 'text/plain');
      expect(r4.body.contains('This is some txt'), true);
    });
  });
  test('it does not crash when File not exists', () async {
    await runTest(fn: (app, port) async {
      app.get('error', ValueMiddleware(File('does-not-exists')));
      app.get('works', const ValueMiddleware('works!'));
      await http.get(Uri.parse('http://localhost:$port/error'));
      final request = await http.get(Uri.parse('http://localhost:$port/works'));
      expect(request.statusCode, 200);
    });
  });
  test('it routes correctly for a / url', () async {
    await runTest(fn: (app, port) async {
      app.get('/', const ValueMiddleware('working'));
      final response = await http.get(Uri.parse('http://localhost:$port/'));
      expect(response.body, 'working');
    });
  });
  test('it handles params', () async {
    await runTest(fn: (app, port) async {
      app.get('/test/:id', RequestMiddleware((req) => AlfredHttpRequestImpl(req, app).params['id']));
      final response = await http.get(Uri.parse('http://localhost:$port/test/15'));
      expect(response.body, '15');
    });
  });
  test('it should implement cors correctly', () async {
    await runTest(fn: (app, port) async {
      app.all('*', const CorsMiddleware(origin: 'test-origin'));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.headers.containsKey('access-control-allow-origin'), true);
      expect(response.headers['access-control-allow-origin'], 'test-origin');
      expect(response.headers.containsKey('access-control-allow-headers'), true);
      expect(response.headers.containsKey('access-control-allow-methods'), true);
    });
  });
  test("it should throw an appropriate error when a return type isn't found", () async {
    await runTest(fn: (app, port) async {
      app.get('/test', ValueMiddleware(_UnknownType()));
      final response = await http.get(Uri.parse('http://localhost:$port/test'));
      expect(response.statusCode, 500);
      expect(response.body.contains('_UnknownType'), true);
    });
  });
  test('it should log out request information', () async {
    final logs = <String>[];
    await runTest(
      fn: (app, port) async {
        app.get(
          '/resource',
          const ValueMiddleware('response'),
          middleware: [const CorsMiddleware()],
        );
        await http.get(Uri.parse('http://localhost:$port/resource'));
        bool inLog(String part) => logs.isNotEmpty && logs.where((log) => log.contains(part)).isNotEmpty;
        print(logs.join("\n"));
        expect(inLog('info GET - /resource'), true);
        expect(inLog('debug Match route: /resource'), true);
        expect(inLog('debug Apply middleware'), true);
        expect(inLog('debug Apply TypeHandler for result type: String'), true);
        expect(inLog('debug Response sent to client'), true);
      },
      LOG: TestLogger(logs.add),
    );
  });
}

class TestLogger with AlfredLoggingDelegateGeneralizingMixin {
  final void Function(String) add;

  const TestLogger(this.add);

  @override
  void log(dynamic Function() messageFn, LogType type) => add(type.description + ' ${messageFn()}');

  @override
  LogType get logLevel => LogType.info;
}

class _UnknownType {}

/// Throw these exceptions to bubble up an error from sub functions and have them
/// handled automatically for the client
/// TODO have an adt for all errors any given method can throw. no catch all exception-types.
class _AlfredExceptionImpl implements AlfredException {
  /// The response to send to the client
  @override
  final Object? response;

  /// The statusCode to send to the client
  @override
  final int statusCode;

  const _AlfredExceptionImpl(this.statusCode, this.response);
}
