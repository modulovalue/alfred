import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/request.dart';
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/middleware/impl/request.dart';
import 'package:alfred/middleware/impl/value.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'common.dart';

void main() {
  late Alfred app;
  late int port;
  setUp(() async {
    app = AlfredImpl();
    port = await app.listenForTest();
  });
  tearDown(() async {
    await app.close();
  });
  test('it should store and retrieve a value on a request', () async {
    var didHit = false;
    app.all('/test', RequestMiddleware((req) {
      expect(AlfredHttpRequestImpl(req, app).route, '/test');
      AlfredHttpRequestImpl(req, app).store.set('testValue', 'bah!');
      expect(AlfredHttpRequestImpl(req, app).store.get<String>('testValue'), 'bah!');
      didHit = true;
      return 'done';
    }));
    await http.get(Uri.parse('http://localhost:$port/test'));
    expect(didHit, true);
  });
  test('it handles an on done listener and cleans up the store', () async {
    var hitCount = 0;
    final listener = (HttpRequest req, HttpResponse res) => hitCount++;
    app.registerOnDoneListener(listener);
    app.get('/test', const ValueMiddleware('done'));
    await http.get(Uri.parse('http://localhost:$port/test'));
    expect(hitCount, 1);
    app.removeOnDoneListener(listener);
    await http.get(Uri.parse('http://localhost:$port/test'));
    expect(hitCount, 1);
    expect(app.store.allKeys().isEmpty, true);
  });
  test('the store is correctly available across multiple routes', () async {
    var didHit = false;
    app.get('*', RequestMiddleware((req) {
      AlfredHttpRequestImpl(req, app).store.set('userid', '123456');
    }));
    app.get('/user', RequestMiddleware((req) {
      didHit = true;
      expect(AlfredHttpRequestImpl(req, app).store.get<String>('userid'), '123456');
    }));
    await http.get(Uri.parse('http://localhost:$port/user'));
    expect(didHit, true);
  });
}
