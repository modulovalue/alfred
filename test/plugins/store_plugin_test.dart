import 'dart:io';

import 'package:alfred/base.dart';
import 'package:alfred/extensions.dart';
import 'package:alfred/plugin_store.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../common.dart';

void main() {
  late Alfred app;
  late int port;
  setUp(() async {
    app = Alfred();
    port = await app.listenForTest();
  });
  tearDown(() async {
    await app.close();
  });
  test('it should store and retrieve a value on a request', () async {
    var didHit = false;
    app.all('/test', (req, res) {
      expect(req.route, '/test');
      req.store.set('testValue', 'bah!');
      expect(req.store.get<String>('testValue'), 'bah!');
      didHit = true;
      return 'done';
    });
    await http.get(Uri.parse('http://localhost:$port/test'));
    expect(didHit, true);
  });
  test('it handles an on done listener and cleans up the store', () async {
    var hitCount = 0;
    final listener = (HttpRequest req, HttpResponse res) => hitCount++;
    app.registerOnDoneListener(listener);
    app.get('/test', (req, res) => 'done');
    await http.get(Uri.parse('http://localhost:$port/test'));
    expect(hitCount, 1);
    app.removeOnDoneListener(listener);
    await http.get(Uri.parse('http://localhost:$port/test'));
    expect(hitCount, 1);
    expect(_outstandingRequests.isEmpty, true);
  });
  test('the store is correctly available across multiple routes', () async {
    var didHit = false;
    app.get('*', (req, res) {
      req.store.set('userid', '123456');
    });
    app.get('/user', (req, res) {
      didHit = true;
      expect(req.store.get<String>('userid'), '123456');
    });
    await http.get(Uri.parse('http://localhost:$port/user'));
    expect(didHit, true);
  });
}

List<HttpRequest> get _outstandingRequests => storePluginData.keys.toList();
