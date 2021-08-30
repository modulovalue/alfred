import 'dart:io';

import 'package:alfred/crdt/crdt/impl/map_crdt.dart';
import 'package:alfred/crdt/crdt/impl/record.dart';
import 'package:alfred/crdt/crdt/interface/crdt.dart';
import 'package:alfred/crdt/crdt/serialization/decode_crdt.dart';
import 'package:alfred/crdt/hlc/impl/factory/now.dart';
import 'package:alfred/crdt/hlc/impl/hlc.dart';
import 'package:test/test.dart';

import 'crdt_test_suite.dart';

void main() {
  final hlcNow = nowHlc('abc');
  crdtTests<MapCrdt<String, int>>(
    'abc',
    syncSetup: () => MapCrdt('abc'),
  );
  group('Seed', () {
    late Crdt<String, Object> crdt;
    setUp(() {
      crdt = MapCrdt<String, Object>(
        'abc',
        {'x': RecordImpl<Object>(hlcNow, 1, hlcNow)},
      );
    });
    test('Seed item', () {
      expect(crdt.get('x'), 1);
    });
    test('Seed and put', () {
      crdt.put('x', 2);
      expect(crdt.get('x'), 2);
    });
  });
  group('Merge', () {
    late Crdt<String, Object> crdt;
    setUp(() {
      crdt = MapCrdt<String, Object>('abc');
    });
    test('Merge older', () {
      crdt.put('x', 2);
      crdt.merge({'x': RecordImpl<Object>(HlcImpl(_millis - 1, 0, 'xyz'), 1, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Merge very old', () {
      crdt.put('x', 2);
      crdt.merge({'x': RecordImpl<Object>(HlcImpl(0, 0, 'xyz'), 1, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Merge newer', () async {
      crdt.put('x', 1);
      await Future<Object?>.delayed(const Duration(milliseconds: 1));
      crdt.merge({'x': RecordImpl<Object>(nowHlc('xyz'), 2, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Disambiguate using node id', () {
      crdt.merge({'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'nodeA'), 1, hlcNow)});
      crdt.merge({'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'nodeB'), 2, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Merge same', () {
      crdt.put('x', 2);
      final remoteTs = crdt.getRecord('x')!.hlc;
      crdt.merge({'x': RecordImpl<Object>(remoteTs, 1, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Merge older, newer counter', () {
      crdt.put('x', 2);
      crdt.merge({'x': RecordImpl<Object>(HlcImpl(_millis - 1, 2, 'xyz'), 1, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Merge same, newer counter', () {
      crdt.put('x', 1);
      final remoteTs = HlcImpl(crdt.getRecord('x')!.hlc.millis, 2, 'xyz');
      crdt.merge({'x': RecordImpl<Object>(remoteTs, 2, hlcNow)});
      expect(crdt.get('x'), 2);
    });
    test('Merge new item', () {
      final map = {'x': RecordImpl<Object>(nowHlc('xyz'), 2, hlcNow)};
      crdt.merge(map);
      expect(crdt.recordMap(), map);
    });
    test('Merge deleted item', () async {
      crdt.put('x', 1);
      await Future<Object?>.delayed(const Duration(milliseconds: 1));
      crdt.merge({'x': RecordImpl<Object>(nowHlc('xyz'), null, hlcNow)});
      expect(crdt.isDeleted('x'), isTrue);
    });
    test('Update HLC on merge', () {
      crdt.put('x', 1);
      crdt.merge({'y': RecordImpl<Object>(HlcImpl(_millis - 1, 0, 'xyz'), 2, hlcNow)});
      expect(crdt.map.values.toList(), [1, 2]);
    });
  });
  group('Serialization', () {
    test('To map', () {
      final crdt = MapCrdt<String, Object>('abc', {
        'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow),
      });
      expect(
        crdt.recordMap(),
        {'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow)},
      );
    });
    test('jsonEncodeStringKey', () {
      final crdt = MapCrdt<String, Object>('abc', {
        'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow),
      });
      expect(crdt.toJson(), '{"x":{"hlc":"$_isoTime-0000-abc","value":1}}');
    });
    test('jsonEncodeIntKey', () {
      final crdt = MapCrdt<int, Object>('abc', {
        1: RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow),
      });
      expect(crdt.toJson(), '{"1":{"hlc":"$_isoTime-0000-abc","value":1}}');
    });
    test('jsonEncodeDateTimeKey', () {
      final crdt = MapCrdt<DateTime, Object>('abc', {
        DateTime(2000, 01, 01, 01, 20): RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow),
      });
      expect(crdt.toJson(), '{"2000-01-01 01:20:00.000":{"hlc":"$_isoTime-0000-abc","value":1}}');
    });
    test('jsonEncodeCustomClassValue', () {
      final crdt = MapCrdt<String, Object>('abc', {
        'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), TestClass('test'), hlcNow),
      });
      expect(crdt.toJson(), '{"x":{"hlc":"$_isoTime-0000-abc","value":{"test":"test"}}}');
    });
    test('jsonEncodeCustomNodeId', () {
      final crdt = MapCrdt<String, Object>('abc', {
        'x': RecordImpl<Object>(HlcImpl(_millis, 0, "1"), 0, hlcNow),
      });
      expect(crdt.toJson(), '{"x":{"hlc":"$_isoTime-0000-1","value":0}}');
    });
    test('jsonDecodeStringKey', () {
      final crdt = MapCrdt<String, Object>('abc');
      final map = decodeCrdtJson<String, Object>(
        '{"x":{"hlc":"$_isoTime-0000-abc","value":1}}',
        hlcNow,
      );
      crdt.putRecords(map);
      expect(crdt.recordMap(), {'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow)});
    });
    test('jsonDecodeIntKey', () {
      final crdt = MapCrdt<int, Object>('abc');
      final map = decodeCrdtJson<int, Object>(
        '{"1":{"hlc":"$_isoTime-0000-abc","value":1}}',
        hlcNow,
        keyDecoder: (final key) => int.parse(key),
      );
      crdt.putRecords(map);
      expect(crdt.recordMap(), {1: RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow)});
    });
    test('jsonDecodeDateTimeKey', () {
      final crdt = MapCrdt<DateTime, Object>('abc');
      final map = decodeCrdtJson<DateTime, Object>(
        '{"2000-01-01 01:20:00.000":{"hlc":"$_isoTime-0000-abc","value":1}}',
        hlcNow,
        keyDecoder: (final key) => DateTime.parse(key),
      );
      crdt.putRecords(map);
      expect(crdt.recordMap(),
          {DateTime(2000, 01, 01, 01, 20): RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), 1, hlcNow)});
    });
    test('jsonDecodeCustomClassValue', () {
      final crdt = MapCrdt<String, Object>('abc');
      final map = decodeCrdtJson<String, Object>(
        '{"x":{"hlc":"$_isoTime-0000-abc","value":{"test":"test"}}}',
        hlcNow,
        valueDecoder: (final key, final dynamic value) => TestClass.fromJson(value),
      );
      crdt.putRecords(map);
      expect(
        crdt.recordMap(),
        {
          'x': RecordImpl<Object>(HlcImpl(_millis, 0, 'abc'), TestClass('test'), hlcNow),
        },
      );
    });
    test('jsonDecodeCustomNodeId', () {
      final crdt = MapCrdt<String, Object>('abc');
      final map = decodeCrdtJson<String, Object>(
        '{"x":{"hlc":"$_isoTime-0000-1","value":0}}',
        hlcNow,
        nodeIdDecoder: (final a) => a,
      );
      crdt.putRecords(map);
      expect(
        crdt.recordMap(),
        {
          'x': RecordImpl<Object>(HlcImpl(_millis, 0, "1"), 0, hlcNow),
        },
      );
    });
  });
  group('Delta subsets', () {
    late Crdt<String, Object> crdt;
    final hlc1 = HlcImpl(_millis, 0, 'abc');
    final hlc2 = HlcImpl(_millis + 1, 0, 'abc');
    final hlc3 = HlcImpl(_millis + 2, 0, 'abc');
    setUp(() {
      crdt = MapCrdt<String, Object>('abc', {
        'x': RecordImpl<Object>(hlc1, 1, hlc1),
        'y': RecordImpl<Object>(hlc2, 2, hlc2),
      });
    });
    test('null modifiedSince', () {
      final map = crdt.recordMap();
      expect(map.length, 2);
    });
    test('modifiedSince hlc1', () {
      final map = crdt.recordMap(modifiedSince: hlc1);
      expect(map.length, 2);
    });
    test('modifiedSince hlc2', () {
      final map = crdt.recordMap(modifiedSince: hlc2);
      expect(map.length, 1);
    });
    test('modifiedSince hlc3', () {
      final map = crdt.recordMap(modifiedSince: hlc3);
      expect(map.length, 0);
    });
  });
  group('Delta sync', () {
    late Crdt<String, Object> crdtA;
    late Crdt<String, Object> crdtB;
    late Crdt<String, Object> crdtC;
    setUp(() {
      crdtA = MapCrdt<String, Object>('a');
      crdtB = MapCrdt<String, Object>('b');
      crdtC = MapCrdt<String, Object>('c');
      crdtA.put('x', 1);
      sleep(const Duration(milliseconds: 100));
      crdtB.put('x', 2);
    });
    test('Merge in order', () {
      _sync(crdtA, crdtC);
      _sync(crdtB, crdtC);
      expect(crdtA.get('x'), 1); // node A still contains the old value
      expect(crdtB.get('x'), 2);
      expect(crdtC.get('x'), 2);
    });
    test('Merge in reverse order', () {
      _sync(crdtB, crdtC);
      _sync(crdtA, crdtC);
      _sync(crdtB, crdtC);
      expect(crdtA.get('x'), 2);
      expect(crdtB.get('x'), 2);
      expect(crdtC.get('x'), 2);
    });
  });
}

void _sync(
  final Crdt<String, Object> local,
  final Crdt<String, Object> remote,
) {
  final time = local.canonicalTime;
  final l = local.recordMap();
  remote.merge(l);
  final r = remote.recordMap(modifiedSince: time);
  local.merge(r);
}

class TestClass {
  final String test;

  TestClass(
    final this.test,
  );

  static TestClass fromJson(
    final dynamic map,
  ) =>
      TestClass(
        // ignore: avoid_dynamic_calls
        map['test'] as String,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'test': test,
      };

  @override
  // ignore: hash_and_equals
  bool operator ==(final Object other) => other is TestClass && test == other.test;

  @override
  String toString() => test;
}

const _millis = 1000000000000;
const _isoTime = '2001-09-09T01:46:40.000Z';
