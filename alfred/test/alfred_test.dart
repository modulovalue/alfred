import 'dart:convert';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/log_type.dart';
import 'package:alfred/alfred/impl/logging/mixin.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/bytes.dart';
import 'package:alfred/alfred/impl/middleware/bytes_stream.dart';
import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:alfred/alfred/impl/middleware/cors.dart';
import 'package:alfred/alfred/impl/middleware/io_dir.dart';
import 'package:alfred/alfred/impl/middleware/io_download.dart';
import 'package:alfred/alfred/impl/middleware/io_file.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/alfred/interface/middleware.dart';
import 'package:alfred/alfred/interface/serve_context.dart';
import 'package:alfred/base/http_status_code.dart';
import 'package:alfred/base/method.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'common.dart';

// TODO replace image.jpg with something neutral.
void main() {
  test('runTest should be called', () async {
    bool called = false;
    await runTest(fn: (final app, final built, final port) async {
      called = true;
    });
    expect(called, true);
  });
  test('it should return a string correctly', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeString(
                string: 'test string',
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, 'test string');
    });
  });
  test('it should return json', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeJson.map(
                map: {
                  'test': true,
                },
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.headers['content-type'], 'application/json; charset=utf-8');
      expect(response.body, '{"test":true}');
    });
  });
  test('it should return an image', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeFileStringPathImpl(
                path: 'test/files/image.jpg',
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.headers['content-type'], 'image/jpeg');
    });
  });
  test('it should return a pdf', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeFileStringPathImpl(
                path: 'test/files/dummy.pdf',
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.headers['content-type'], 'application/pdf');
    });
  });
  test('routing should, you know, work', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeString(
                string: 'test_route',
              ),
            ),
            Route.get(
              path: '/testRoute',
              middleware: const ServeString(
                string: 'test_route_route',
              ),
            ),
            Route.get(
              path: '/a',
              middleware: const ServeString(
                string: 'a_route',
              ),
            ),
          ],
        ),
      );
      expect(
        (await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'))).body,
        'test_route',
      );
      expect(
        (await http.get(Uri.parse('http://localhost:' + port.toString() + '/testRoute'))).body,
        'test_route_route',
      );
      expect(
        (await http.get(Uri.parse('http://localhost:' + port.toString() + '/a'))).body,
        'a_route',
      );
    });
  });
  test('error handling', () async {
    await runTest(fn: (app, final built, final port) async {
      await built.close();
      app = makeSimpleAlfred(
        onInternalError: (dynamic e) => MiddlewareBuilder(
          process: (final c) {
            c.res.setStatusCode(httpStatusInternalServerError500);
            return const ServeJson.map(
              map: {
                'message': 'error not handled',
              },
            ).process(c);
          },
        ),
      );
      await buildAlfred(alfred: app, port: port);
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/throwserror',
              middleware: MiddlewareBuilder(
                process: (final _) => throw Exception('generic exception'),
              ),
            ),
          ],
        ),
      );
      expect((await http.get(Uri.parse('http://localhost:' + port.toString() + '/throwserror'))).body,
          '{"message":"error not handled"}');
    });
  });
  test('error default handling', () async {
    await runTest(fn: (app, final built, final port) async {
      await built.close();
      app = makeSimpleAlfred();
      await buildAlfred(alfred: app, port: port);
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/throwserror',
              middleware: MiddlewareBuilder(
                process: (final _) => throw Exception('generic exception'),
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/throwserror'));
      expect(response.body, 'Exception: generic exception');
    });
  });
  test('not found handling', () async {
    await runTest(fn: (app, final built, final port) async {
      await built.close();
      app = makeSimpleAlfred(
        onNotFound: MiddlewareBuilder(
          process: (final c) async {
            c.res.setStatusCode(httpStatusNotFound404);
            return const ServeJson.map(
              map: {
                'message': 'not found',
              },
            ).process(c);
          },
        ),
      );
      await buildAlfred(alfred: app, port: port);
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/notfound'));
      expect(response.body, '{"message":"not found"}');
      expect(response.statusCode, 404);
    });
  });
  test('not found default handling', () async {
    await runTest(fn: (app, final built, final port) async {
      await built.close();
      app = makeSimpleAlfred();
      await buildAlfred(alfred: app, port: port);
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/notfound'));
      expect(response.body, '404 not found');
      expect(response.statusCode, 404);
    });
  });
  test('not found with middleware', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.all(
              path: '*',
              middleware: const CorsMiddleware(),
            ),
            Route.get(
              path: 'resource2',
              middleware: const ClosingMiddleware(),
            ),
          ],
        ),
      );
      final r1 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/resource1'));
      expect(r1.body, '404 not found');
      expect(r1.statusCode, 404);
      final r2 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/resource2'));
      expect(r2.body, '');
      expect(r2.statusCode, 200);
    });
  });
  test('not found with directory type handler', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/files/*',
              middleware: const ServeDirectoryStringPathImpl(
                path: 'test/files',
                log: AlfredLoggingDelegatePrintImpl(),
              ),
            ),
          ],
        ),
      );
      final r = await http.get(Uri.parse('http://localhost:' + port.toString() + '/files/no-file.zip'));
      expect(r.body, '404 not found');
      expect(r.statusCode, 404);
    });
  });
  test('not found with file type handler', () async {
    await runTest(
      fn: (app, built, port) async {
        app.router.add(
          routes: Routes(
            routes: [
              Route.get(
                path: '/index.html',
                middleware: const ServeFileStringPathImpl(
                  path: 'does-not.exists',
                ),
              ),
            ],
          ),
        );
        final r = await http.get(Uri.parse('http://localhost:' + port.toString() + '/index.html'));
        expect(r.body, 'Custom404Message');
        expect(r.statusCode, 404);
      },
      notFound: MiddlewareBuilder(
        process: (final c) {
          c.res.setStatusCode(httpStatusNotFound404);
          return const ServeString(
            string: 'Custom404Message',
          ).process(c);
        },
      ),
    );
  });
  test('it handles a post request', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.post(
              path: '/test',
              middleware: const ServeString(
                string: 'test string',
              ),
            ),
          ],
        ),
      );
      print(port);
      final response = await http.post(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles a put request', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.put(
              path: '/test',
              middleware: const ServeString(
                string: 'test string',
              ),
            ),
          ],
        ),
      );
      final response = await http.put(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles a delete request', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.delete(
              path: '/test',
              middleware: const ServeString(
                string: 'test string',
              ),
            ),
          ],
        ),
      );
      final response = await http.delete(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles an options request', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.options(
              path: '/test',
              middleware: const ServeString(
                string: 'test string',
              ),
            ),
          ],
        ),
      );
      final response = await http.Response.fromStream(
        await http.Client().send(
          http.Request(
            MethodOptions.optionsString,
            Uri.parse(
              "http://localhost:" + port.toString() + "/test",
            ),
          ),
        ),
      );
      expect(response.body, "test string");
    });
  });
  test('it handles a patch request', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.patch(
              path: '/test',
              middleware: const ServeString(
                string: 'test string',
              ),
            ),
          ],
        ),
      );
      final response = await http.patch(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, 'test string');
    });
  });
  test('it handles a route that hits all methods', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.all(
              path: '/test',
              middleware: const ServeString(
                string: 'test all',
              ),
            ),
          ],
        ),
      );
      final responseGet = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      final responsePost = await http.post(Uri.parse('http://localhost:' + port.toString() + '/test'));
      final responsePut = await http.put(Uri.parse('http://localhost:' + port.toString() + '/test'));
      final responseDelete = await http.delete(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(responseGet.body, 'test all');
      expect(responsePost.body, 'test all');
      expect(responsePut.body, 'test all');
      expect(responseDelete.body, 'test all');
    });
  });
  test('it closes out a request if you fail to', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const NonClosingMiddleware(),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, '');
    });
  });
  test('it handles a List<int>', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const BytesMiddleware(
                bytes: <int>[1, 2, 3, 4, 5],
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, '\x01\x02\x03\x04\x05');
      expect(response.headers['content-type'], 'application/octet-stream');
    });
  });
  test('it handles a Stream<List<int>>', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: StreamOfBytesMiddleware(
                bytes: Stream.fromIterable(
                  [
                    [1, 2, 3, 4, 5]
                  ],
                ),
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, '\x01\x02\x03\x04\x05');
      expect(response.headers['content-type'], 'application/octet-stream');
    });
  });
  test('it parses a body', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.post(
              path: '/test',
              middleware: MiddlewareBuilder(
                process: (final context) async {
                  final body = await context.body;
                  expect(body is Map, true);
                  expect(context.req.mimeType, 'application/json');
                  context.res.writeString('test result');
                },
              ),
            ),
          ],
        ),
      );
      final response = await http.post(
        Uri.parse('http://localhost:' + port.toString() + '/test'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'test': true}),
      );
      expect(response.body, 'test result');
    });
  });
  test('it serves a file for download', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeDownload(
                filename: 'testfile.jpg',
                child: ServeFileStringPathImpl(
                  path: './test/files/image.jpg',
                ),
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.headers['content-type'], 'image/jpeg');
      expect(response.headers['content-disposition'], 'attachment; filename=testfile.jpg');
    });
  });
  test('it serves a pdf, setting the extension from the filename', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeFileStringPathImpl(
                path: './test/files/dummy.pdf',
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.headers['content-type'], 'application/pdf');
      expect(response.headers['content-disposition'], null);
    });
  });
  test('it uses the json helper correctly', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeJson.map(
                map: {
                  'success': true,
                },
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, '{"success":true}');
    });
  });
  test('it uses the send helper correctly', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test',
              middleware: const ServeString(
                string: 'stuff',
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.body, 'stuff');
    });
  });
  test('it serves static files', () async {
    await runTest(fn: (app, built, port) async {
      const log = AlfredLoggingDelegatePrintImpl();
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/files/*',
              middleware: const ServeDirectoryStringPathImpl(
                path: 'test/files',
                log: log,
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/files/dummy.pdf'));
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/pdf');
    });
  });
  test('it serves static files although directories do not match', () async {
    await runTest(fn: (app, built, port) async {
      const log = AlfredLoggingDelegatePrintImpl();
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/my/directory/*',
              middleware: const ServeDirectoryStringPathImpl(
                path: 'test/files',
                log: log,
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/my/directory/dummy.pdf'));
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/pdf');
    });
  });
  test('it serves static files with basic filtering', () async {
    await runTest(fn: (app, built, port) async {
      const log = AlfredLoggingDelegatePrintImpl();
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/my/directory/*.pdf',
              middleware: const ServeDirectoryStringPathImpl(
                path: 'test/files',
                log: log,
              ),
            ),
          ],
        ),
      );
      final r1 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/my/directory/dummy.pdf'));
      expect(r1.statusCode, 200);
      expect(r1.headers['content-type'], 'application/pdf');
      final r2 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/my/directory/image.jpg'));
      expect(r2.statusCode, 404);
    });
  });
  test('it serves SPA projects', () async {
    await runTest(fn: (app, built, port) async {
      const log = AlfredLoggingDelegatePrintImpl();
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/spa/*',
              middleware: const ServeDirectoryStringPathImpl(
                path: 'test/files/spa',
                log: log,
              ),
            ),
            Route.get(
              path: '/spa/*',
              middleware: const ServeFileStringPathImpl(
                path: 'test/files/spa/index.html',
              ),
            ),
          ],
        ),
      );
      final r1 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/spa'));
      expect(r1.statusCode, 200);
      expect(r1.headers['content-type'], 'text/html');
      expect(r1.body.contains('I am a SPA Application'), true);
      final r2 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/spa/'));
      expect(r2.statusCode, 200);
      expect(r2.headers['content-type'], 'text/html');
      expect(r2.body.contains('I am a SPA Application'), true);
      final r3 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/spa/index.html'));
      expect(r3.statusCode, 200);
      expect(r3.headers['content-type'], 'text/html');
      expect(r3.body.contains('I am a SPA Application'), true);
      final r4 = await http.get(Uri.parse('http://localhost:' + port.toString() + '/spa/assets/some.txt'));
      expect(r4.statusCode, 200);
      expect(r4.headers['content-type'], 'text/plain');
      expect(r4.body.contains('This is some txt'), true);
    });
  });
  test('it does not crash when File not exists', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: 'error',
              middleware: const ServeFileStringPathImpl(
                path: 'does-not-exists',
              ),
            ),
            Route.get(
              path: 'works',
              middleware: const ServeString(
                string: 'works!',
              ),
            ),
          ],
        ),
      );
      await http.get(Uri.parse('http://localhost:' + port.toString() + '/error'));
      final request = await http.get(Uri.parse('http://localhost:' + port.toString() + '/works'));
      expect(request.statusCode, 200);
    });
  });
  test('it routes correctly for a / url', () async {
    await runTest(fn: (final app, final built, final port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/',
              middleware: const ServeString(
                string: 'working',
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/'));
      expect(response.body, 'working');
    });
  });
  test('it handles params', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.get(
              path: '/test/:id',
              middleware: MiddlewareBuilder(
                process: (final context) async {
                  context.res.writeString(context.arguments!['id']!);
                },
              ),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test/15'));
      expect(response.body, '15');
    });
  });
  test('it should implement cors correctly', () async {
    await runTest(fn: (app, built, port) async {
      app.router.add(
        routes: Routes(
          routes: [
            Route.all(
              path: '*',
              middleware: const CorsMiddleware(origin: 'test-origin'),
            ),
          ],
        ),
      );
      final response = await http.get(Uri.parse('http://localhost:' + port.toString() + '/test'));
      expect(response.headers.containsKey('access-control-allow-origin'), true);
      expect(response.headers['access-control-allow-origin'], 'test-origin');
      expect(response.headers.containsKey('access-control-allow-headers'), true);
      expect(response.headers.containsKey('access-control-allow-methods'), true);
    });
  });
  test('it should log out request information', () async {
    final logs = <String>[];
    await runTest(
      fn: (final app, final built, final port) async {
        app.router.add(
          routes: Routes(
            routes: [
              Route.get(
                path: '/resource',
                middleware: const ServeString(
                  string: 'response',
                ),
              ),
            ],
          ),
        );
        await http.get(Uri.parse('http://localhost:' + port.toString() + '/resource'));
        bool inLog(
          final String part,
        ) =>
            logs.where((final log) => log.contains(part)).isNotEmpty;
        print(logs.join("\n"));
        expect(inLog('info GET - /resource'), true);
        expect(inLog('debug Match route: /resource'), true);
        expect(inLog('debug Execute route callback function'), true);
        expect(inLog('debug Response sent to client'), true);
      },
      LOG: TestLogger(logs.add),
    );
  });
}

class TestLogger with AlfredLoggingDelegateGeneralizingMixin {
  final void Function(String) add;

  const TestLogger(
    final this.add,
  );

  @override
  void log({
    required final dynamic Function() messageFn,
    required final LogType type,
  }) =>
      add(type.description + ' ' + messageFn().toString());

  @override
  LogType get logLevel => const LogTypeInfo();
}

class NonClosingMiddleware implements Middleware {
  const NonClosingMiddleware();

  @override
  Future<void> process(
    final ServeContext context,
  ) async {}
}
