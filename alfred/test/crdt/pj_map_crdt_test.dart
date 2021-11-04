import 'package:alfred/crdt/pj_map_crdt.dart';
import 'package:alfred/crdt/pj_vector_clock.dart';
import 'package:test/test.dart';

void main() {
  test('put all', () {
    final crdt = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdtNode = MapCrdtNode<String, String>(crdt);
    crdt.put('node', crdtNode);
    crdtNode.putAll({'key1': 'value1', 'key2': 'value2'});
    expect(crdtNode.map, {'key1': 'value1', 'key2': 'value2'});
    expect(
      crdtNode.getRecord('key1')!.clock,
      crdtNode.getRecord('key2')!.clock,
    );
    expect(crdt.vectorClock, VectorClock.fromList([2]));
  });
  test('map crdt deep clone', () {
    final crdt = MapCrdtRoot<String, MapCrdtNode<String, String>>('node');
    final crdtNode = MapCrdtNode<String, String>(crdt)..put('key', 'value');
    crdt.put('node', crdtNode);
    final crdtCopy = _deepCloneCrdt(crdt);
    crdtCopy.put('node2', MapCrdtNode(crdtCopy)..put('key2', 'value2'));
    expect(crdtCopy.nodes, ['node']);
    expect(crdtCopy.records.keys.toSet(), {'node', 'node2'});
    expect(crdtCopy.get('node2')?.map, {'key2': 'value2'});
    expect(crdtCopy.get('node')?.map, {'key': 'value'});
    crdtCopy.get('node')!.put('key3', 'value3');
    expect(crdtCopy.get('node')?.map, {'key': 'value', 'key3': 'value3'});
    crdtCopy.addNode('node2');
    expect(crdtCopy.nodes, ['node', 'node2']);
    crdtCopy.get('node')!.root.addNode('node3');
    expect(crdtCopy.nodes, ['node', 'node2', 'node3']);
    // expect original unchanged
    expect(crdt.nodes, ['node']);
    expect(crdt.records.keys.toSet(), {'node'});
    expect(crdtNode.map, {'key': 'value'});
    expect(crdt.get('node')?.map, {'key': 'value'});
  });
  test('map crdt node merge', () {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt1.put('node', crdt1Node);
    crdt2.put('node', crdt2Node);
    crdt1Node.put('key1', 'value1');
    crdt2Node.put('key2', 'value2');
    expect(crdt1Node.map, {'key1': 'value1'});
    expect(crdt2Node.map, {'key2': 'value2'});
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1.get('node')?.map, {'key1': 'value1', 'key2': 'value2'});
    expect(crdt1Node.map, {'key1': 'value1', 'key2': 'value2'});
  });
  test('map crdt merge node parent updated', () {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt2.put('node', crdt2Node);
    crdt2Node.put('key2', 'value2');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1.map['node']?.map, {'key2': 'value2'});
    expect(
      crdt1.records.values.every(
        (record) => record.isDeleted || record.value!.root == crdt1,
      ),
      true,
      reason: 'expected crdt nodes to have updated their parent',
    );
  });
  test('map crdt node merge delete node', () {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt1.put('node', crdt1Node);
    crdt2.put('node', crdt2Node);
    crdt1Node.put('key1', 'value1');
    crdt2Node.put('key2', 'value2');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1Node.map, {'key1': 'value1', 'key2': 'value2'});
    crdt2.delete('node');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1.map, <String, dynamic>{});
  });
  test('map crdt node merge node first updated then deleted', () async {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt1.put('node', crdt1Node);
    crdt2.put('node', crdt2Node);
    // first update in crdt2 then delete in crdt1
    crdt2Node.put('key2', 'new value');
    await Future<dynamic>.delayed(const Duration(milliseconds: 10));
    crdt1.delete('node');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1.map, <String, dynamic>{});
  });
  test(
    'map crdt node merge node first updated then deleted after merge',
    () async {
      final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
      final crdt1Node = MapCrdtNode<String, String>(crdt1);
      final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
      final crdt2Node = MapCrdtNode<String, String>(crdt2);
      crdt1.put('node', crdt1Node);
      crdt2.put('node', crdt2Node);
      crdt1.merge(_deepCloneCrdt(crdt2));
      // first update in crdt2 then delete in crdt1
      crdt2Node.put('key2', 'new value');
      await Future<dynamic>.delayed(const Duration(milliseconds: 10));
      crdt1.delete('node');
      crdt1.merge(_deepCloneCrdt(crdt2));
      expect(crdt1.map, <String, dynamic>{});
    },
  );
  test('map crdt node merge node first deleted then updated', () async {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt1.put('node', crdt1Node);
    crdt2.put('node', crdt2Node);
    // first delete in crdt1 then update in crdt2
    crdt1.delete('node');
    await Future<dynamic>.delayed(const Duration(milliseconds: 10));
    crdt2Node.put('key', 'value');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1.map.keys.toSet(), {'node'});
    expect(crdt1.map['node']?.map, {'key': 'value'});
  });
  test(
    'map crdt node merge node first deleted then updated after merge',
    () async {
      final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
      final crdt1Node = MapCrdtNode<String, String>(crdt1);
      final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
      final crdt2Node = MapCrdtNode<String, String>(crdt2);
      crdt1.put('node', crdt1Node);
      crdt2.put('node', crdt2Node);
      crdt1.merge(_deepCloneCrdt(crdt2));
      // first delete in crdt1 then update in crdt2
      crdt1.delete('node');
      await Future<dynamic>.delayed(const Duration(milliseconds: 10));
      crdt2Node.put('key', 'value');
      crdt1.merge(_deepCloneCrdt(crdt2));
      expect(crdt1.map.keys.toSet(), {'node'});
      expect(crdt1.map['node']?.map, {'key': 'value'});
    },
  );
  test('map crdt node merge delete in node', () {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt1.put('node', crdt1Node);
    crdt2.put('node', crdt2Node);
    crdt1Node.put('key1', 'value1');
    crdt2Node.put('key2', 'value2');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1Node.map, {'key1': 'value1', 'key2': 'value2'});
    crdt2Node.delete('key1');
    crdt1.merge(_deepCloneCrdt(crdt2));
    expect(crdt1Node.map, {'key2': 'value2'});
  });
  test('vector clock merge with node', () async {
    final crdt1 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2 = MapCrdtRoot<String, MapCrdtNode<String, String>>('node2');
    crdt1.put('node', crdt1Node);
    crdt1Node.put('key', 'value');
    crdt2.merge(crdt1);
    final crdt1ClockValue = crdt1.vectorClock.value[crdt1.vectorClockIndex];
    expect(crdt2.vectorClock.value.length, 2);
    expect(
      crdt2.vectorClock.value[(crdt2.vectorClockIndex + 1) % 2],
      crdt1ClockValue,
    );
  });
  test('map crdt node to json', () {
    final crdt = MapCrdtRoot<String, MapCrdtNode<String, String>>('node1');
    final crdtNode = MapCrdtNode<String, String>(crdt);
    crdt.put('node1', crdtNode);
    crdtNode.put('key1', 'value1');
    final key1Clock = crdtNode.getRecord('key1')!.clock;
    final expectedCrdtNodeJson = {
      'key1': {
        'clock': key1Clock.toJson(),
        'value': 'value1',
      },
    };
    expect(crdtNode.toJson(), expectedCrdtNodeJson);
    final node1Clock = crdt.getRecord('node1')!.clock;
    expect(crdt.toJson(valueEncode: (node) => node.toJson()), {
      'node': 'node1',
      'nodes': ['node1'],
      'vectorClock': crdt.vectorClock.value.toList(),
      'records': {
        'node1': {
          'clock': node1Clock.toJson(),
          'value': expectedCrdtNodeJson,
        },
      },
    });
  });
  test('map crdt node to json custom value type', () {
    final crdt = MapCrdtRoot<String, MapCrdtNode<String, ValueType>>('node1');
    final crdtNode = MapCrdtNode<String, ValueType>(crdt);
    crdt.put('node1', crdtNode);
    crdtNode.put('key1', ValueType('value1'));
    final valueEncodeFunc = (ValueType v) => {'value': v.value};
    final key1Clock = crdtNode.getRecord('key1')!.clock;
    final expectedCrdtNodeJson = {
      'key1': {
        'clock': key1Clock.toJson(),
        'value': {'value': 'value1'},
      },
    };
    expect(
      crdtNode.toJson(valueEncode: valueEncodeFunc),
      expectedCrdtNodeJson,
    );
    final node1Clock = crdt.getRecord('node1')!.clock;
    expect(
      crdt.toJson(
        valueEncode: (node) => node.toJson(valueEncode: valueEncodeFunc),
      ),
      {
        'node': 'node1',
        'nodes': ['node1'],
        'vectorClock': crdt.vectorClock.value.toList(),
        'records': {
          'node1': {
            'clock': node1Clock.toJson(),
            'value': expectedCrdtNodeJson,
          },
        },
      },
    );
  });
  test('map crdt node from json', () {
    final vectorClock = VectorClock(1);
    final node1Clock = DistributedClock(
      vectorClock..increment(0),
      DateTime.now().millisecondsSinceEpoch,
      'node1',
    );
    final key1Clock = DistributedClock(
      vectorClock..increment(0),
      DateTime.now().millisecondsSinceEpoch,
      'node1',
    );
    final crdtNodeJson = {
      'key1': {
        'clock': key1Clock.toJson(),
        'value': 'value1',
      },
    };
    expect(
      MapCrdtNode<String, String>.fromJson(
        crdtNodeJson,
        parent: MapCrdtRoot<String, MapCrdtNode<String, String>>('node1'),
      ).records,
      {
        'key1': Record<String>(
          clock: key1Clock,
          value: 'value1',
        ),
      },
    );
    final crdtJson = {
      'node': 'node1',
      'nodes': ['node1'],
      'vectorClock': vectorClock.value.toList(),
      'records': {
        'node1': {
          'clock': node1Clock.toJson(),
          'value': crdtNodeJson,
        },
      },
    };
    final decodedCrdt = MapCrdtRoot<String, MapCrdtNode<String, String>>.fromJson(
      crdtJson,
      lateValueDecode: (crdt, dynamic json) => MapCrdtNode<String, String>.fromJson(
        json as Map<String, dynamic>,
        parent: crdt,
      ),
    );
    expect(
      decodedCrdt.records,
      {
        'node1': Record<MapCrdtNode<String, String>>(
          clock: node1Clock,
          value: MapCrdtNode<String, String>(
            decodedCrdt,
            records: {
              'key1': Record<String>(
                clock: key1Clock,
                value: 'value1',
              ),
            },
          ),
        ),
      },
    );
  });
  test('map crdt node from json custom value type', () {
    final vectorClock = VectorClock(1);
    final node1Clock = DistributedClock(
      vectorClock..increment(0),
      DateTime.now().millisecondsSinceEpoch,
      'node1',
    );
    final key1Clock = DistributedClock(
      vectorClock..increment(0),
      DateTime.now().millisecondsSinceEpoch,
      'node1',
    );
    final crdtNodeJson = {
      'key1': {
        'clock': key1Clock.toJson(),
        'value': {'value': 'value1'},
      },
    };
    expect(
      MapCrdtNode<String, ValueType>.fromJson(
        crdtNodeJson,
        parent: MapCrdtRoot<String, MapCrdtNode<String, ValueType>>('node1'),
        // ignore: avoid_dynamic_calls
        valueDecode: (dynamic v) => ValueType(v['value'] as String),
      ).records,
      {
        'key1': Record<ValueType>(
          clock: key1Clock,
          value: ValueType('value1'),
        ),
      },
    );
    final crdtJson = {
      'node': 'node1',
      'nodes': ['node1'],
      'vectorClock': vectorClock.value.toList(),
      'records': {
        'node1': {
          'clock': node1Clock.toJson(),
          'value': crdtNodeJson,
        },
      },
    };
    final decodedCrdt = MapCrdtRoot<String, MapCrdtNode<String, ValueType>>.fromJson(
      crdtJson,
      lateValueDecode: (crdt, dynamic json) => MapCrdtNode<String, ValueType>.fromJson(
        json as Map<String, dynamic>,
        parent: crdt,
        valueDecode: (dynamic v) => ValueType((v as Map<dynamic, dynamic>)['value'] as String),
      ),
    );
    expect(
      decodedCrdt.records,
      {
        'node1': Record<MapCrdtNode<String, ValueType>>(
          clock: node1Clock,
          value: MapCrdtNode<String, ValueType>(
            decodedCrdt,
            records: {
              'key1': Record<ValueType>(
                clock: key1Clock,
                value: ValueType('value1'),
              ),
            },
          ),
        ),
      },
    );
  });
  test('map crdt mixed node merge', () {
    final crdt1 = MapCrdtRoot<String, dynamic>('node1');
    final crdt2 = MapCrdtRoot<String, dynamic>('node2');
    final crdt1Node = MapCrdtNode<String, String>(crdt1);
    final crdt2Node = MapCrdtNode<String, String>(crdt2);
    crdt1.put('node', crdt1Node);
    crdt2.put('node', crdt2Node);
    crdt1.put('title1', 'this is title 1');
    crdt2.put('title2', 'this is title 2');
    crdt1Node.put('key1', 'value1');
    crdt2Node.put('key2', 'value2');
    crdt1.merge(crdt2);
    expect(crdt1.map.keys.toSet(), {'node', 'title1', 'title2'});
    expect(crdt1Node.map, {'key1': 'value1', 'key2': 'value2'});
    expect((crdt1.get('node') as MapCrdtNode<dynamic, dynamic>).map, {'key1': 'value1', 'key2': 'value2'});
    expect(crdt1.get('title1'), 'this is title 1');
    expect(crdt1.get('title2'), 'this is title 2');
  });

  test('init with records', () {
    final crdt = MapCrdtRoot<String, String>(
      'node1',
      records: <String, Record<String>>{
        'key': Record<String>(
          clock: DistributedClock.now(
            VectorClock(1),
            'node1',
          ),
          value: 'value',
        ),
      },
    );
    expect(crdt.map, {'key': 'value'});
  });
  test('init with records fail validation invalid node', () {
    expect(
      () => MapCrdtRoot<String, String>(
        'node1',
        records: <String, Record<String>>{
          'key': Record<String>(
            clock: DistributedClock.now(
              VectorClock(1),
              'node2',
            ),
            value: 'value',
          ),
        },
      ),
      throwsArgumentError,
    );
  });
  test('init with records fail validation invalid vector clock', () {
    expect(
      () => MapCrdtRoot<String, String>(
        'node1',
        records: <String, Record<String>>{
          'key': Record<String>(
            clock: DistributedClock.now(
              VectorClock(2),
              'node1',
            ),
            value: 'value',
          ),
        },
      ),
      throwsArgumentError,
    );
  });
  test('put & get', () {
    final crdt = MapCrdtRoot<String, String>('node1');
    crdt.put('key', 'value');
    expect(crdt.get('key'), 'value');
    expect(crdt.vectorClock, VectorClock.fromList([1]));
  });
  test('add node empty map', () {
    final crdt = MapCrdtRoot<String, String>('node1');
    expect(crdt.nodes, ['node1']);
    expect(crdt.vectorClock.numNodes, 1);
    crdt.addNode('node2');
    expect(crdt.nodes, ['node1', 'node2']);
    expect(crdt.vectorClock.numNodes, 2);
  });
  test('add node with record', () {
    final crdt = MapCrdtRoot<String, String>('node1');
    crdt.put('key', 'value');
    final record = crdt.getRecord('key');
    expect(record, isNot(null));
    expect(record!.clock.vectorClock.numNodes, 1);
    crdt.addNode('node2');
    expect(crdt.vectorClock, VectorClock.fromList([1, 0]));
    expect(record.clock.vectorClock, VectorClock.fromList([1, 0]));
    crdt.put('key2', 'value2');
    final record2 = crdt.getRecord('key2');
    expect(record2, isNot(null));
    expect(crdt.vectorClock, VectorClock.fromList([2, 0]));
    expect(record.clock.vectorClock, VectorClock.fromList([1, 0]));
    expect(record2!.clock.vectorClock, VectorClock.fromList([2, 0]));
  });
  test('add node existing', () {
    final crdt = MapCrdtRoot<String, String>('node1');
    expect(crdt.nodes, ['node1']);
    expect(crdt.vectorClock.numNodes, 1);
    crdt.addNode('node1');
    expect(crdt.nodes, ['node1']);
    expect(crdt.vectorClock.numNodes, 1);
  });
  test('map', () {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    expect(crdt1.map, <String, dynamic>{});
    crdt1.put('key1', 'value1');
    expect(crdt1.map, {'key1': 'value1'});
    crdt1.put('key2', 'value2');
    expect(crdt1.map, {'key1': 'value1', 'key2': 'value2'});
    crdt1.delete('key1');
    expect(crdt1.map, {'key2': 'value2'});
  });
  test('put all', () {
    final crdt = MapCrdtRoot<String, String>('node1');
    crdt.putAll({'key1': 'value1', 'key2': 'value2'});
    expect(crdt.map, {'key1': 'value1', 'key2': 'value2'});
    expect(crdt.getRecord('key1')!.clock, crdt.getRecord('key2')!.clock);
    expect(crdt.vectorClock, VectorClock.fromList([1]));
  });
  test('clone', () {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    crdt1.put('key', 'value1');
    final crdt2 = MapCrdtRoot.from(crdt1);
    expect(crdt2.map, {'key': 'value1'});
    crdt2.getRecord('key')!.value = 'value2';
    expect(crdt1.map, {'key': 'value1'});
  });
  test('clone custom clone value', () {
    final crdt1 = MapCrdtRoot<String, ValueType>('node1');
    crdt1.put('key', ValueType('value1'));
    final crdt2 = MapCrdtRoot<String, ValueType>.from(
      crdt1,
      cloneValue: (v) => ValueType(v.value),
    );
    expect(crdt2.map, {'key': ValueType('value1')});
    crdt2.getRecord('key')!.value!.value = 'value2';
    expect(crdt1.map, {'key': ValueType('value1')});
  });
  test('clone custom clone key', () {
    final crdt1 = MapCrdtRoot<ValueType, String>('node1');
    crdt1.put(ValueType('key'), 'value1');
    final crdt2 = MapCrdtRoot<ValueType, String>.from(
      crdt1,
      cloneKey: (k) => ValueType(k.value),
    );
    expect(crdt2.map, {ValueType('key'): 'value1'});
    crdt2.records.keys.first.value = 'key2';
    expect(crdt1.map, {ValueType('key'): 'value1'});
  });
  test('values', () {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    expect(crdt1.values, <dynamic>[]);
    crdt1.put('key1', 'value1');
    expect(crdt1.values, ['value1']);
    crdt1.put('key2', 'value2');
    expect(crdt1.values, ['value1', 'value2']);
    crdt1.delete('key1');
    expect(crdt1.values, ['value2']);
  });
  test('merge keep both', () {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    crdt1.put('key1', 'value1');
    crdt2.put('key2', 'value2');
    crdt1.merge(MapCrdtRoot.from(crdt2));
    expect(crdt1.map, {'key1': 'value1', 'key2': 'value2'});
    expect(crdt1.nodes, ['node1', 'node2']);
    crdt2.merge(MapCrdtRoot.from(crdt1));
    expect(crdt2.map, {'key1': 'value1', 'key2': 'value2'});
    expect(crdt2.nodes, ['node1', 'node2']);
  });
  test('merge keep more recent by timestamp', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    crdt1.put('key1', 'value1');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    crdt2.put('key1', 'value2');
    crdt1.merge(MapCrdtRoot.from(crdt2));
    expect(crdt1.map, {'key1': 'value2'});
    expect(crdt1.nodes, ['node1', 'node2']);
    crdt2.merge(MapCrdtRoot.from(crdt1));
    expect(crdt2.map, {'key1': 'value2'});
    expect(crdt2.nodes, ['node1', 'node2']);
  });
  test('merge use timestamp in concurrent changes', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    final crdt3 = MapCrdtRoot<String, String>('node3');
    crdt1.put('key1', 'value1');
    crdt2.merge(MapCrdtRoot.from(crdt1));
    crdt3.merge(MapCrdtRoot.from(crdt1));
    for (var i = 0; i < 10; i++) {
      crdt3.put('key1', 'value3');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
    crdt2.put('key1', 'value2');
    crdt1.merge(MapCrdtRoot.from(crdt3));
    crdt1.merge(MapCrdtRoot.from(crdt2));
    expect(crdt1.map, {'key1': 'value2'});
    expect(crdt1.nodes, ['node1', 'node2', 'node3']);
  });

  test('merge timestamp initial tiebreak', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    crdt1.put('key1', 'value1');
    _setTimestamp(crdt1.getRecord('key1')!, 0);
    crdt2.put('key1', 'value2');
    _setTimestamp(crdt2.getRecord('key1')!, 1);
    crdt1.merge(MapCrdtRoot.from(crdt2));
    expect(crdt1.map, {'key1': 'value2'});
  });
  test('merge use vector clock (node idle)', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    crdt2.put('key1', 'value2');
    crdt1.merge(MapCrdtRoot.from(crdt2));
    expect(crdt1.map, {'key1': 'value2'});
    crdt1.put('key1', 'value1');
    _setTimestamp(crdt1.getRecord('key1')!, 0);
    crdt2.merge(MapCrdtRoot.from(crdt1));
    expect(crdt2.map, {'key1': 'value1'});
  });
  test('merge use vector clock (node busy)', () {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    crdt1.put('key', 'value');
    crdt2.merge(MapCrdtRoot.from(crdt1));
    for (var i = 0; i < 10; i++) {
      crdt1.put('unrelated key', 'unrelated value');
    }
    crdt2.put('key', 'new value');
    _setTimestamp(crdt1.getRecord('key')!, 0);
    crdt1.merge(MapCrdtRoot.from(crdt2));
    expect(crdt1.map, {'unrelated key': 'unrelated value', 'key': 'new value'});
    crdt2.merge(MapCrdtRoot.from(crdt1));
    expect(crdt2.map, {'unrelated key': 'unrelated value', 'key': 'new value'});
  });
  test('change node', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    crdt1.put('key1', 'value1');
    crdt1.changeNode('newNode1');
    expect(crdt1.node, 'newNode1');
    expect(crdt1.nodes.toSet(), {'node1', 'newNode1'});
    expect(
      () => crdt1.records.values.forEach((record) => crdt1.validateRecord(record)),
      returnsNormally,
    );
  });
  test('can contain changes', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    expect(crdt1.canContainChangesFor(crdt2), true);
    expect(crdt2.canContainChangesFor(crdt1), true);
    crdt1.put('key', 'value');
    expect(crdt1.canContainChangesFor(crdt2), true);
    expect(crdt2.canContainChangesFor(crdt1), true);
    crdt2.merge(MapCrdtRoot.from(crdt1));
    expect(crdt2.canContainChangesFor(crdt1), true);
    expect(crdt1.canContainChangesFor(crdt2), false);
    crdt2.put('key2', 'value2');
    expect(crdt2.canContainChangesFor(crdt1), true);
    expect(crdt1.canContainChangesFor(crdt2), false);
    crdt1.put('key3', 'value3');
    expect(crdt2.canContainChangesFor(crdt1), true);
    expect(crdt1.canContainChangesFor(crdt2), true);
  });
  test('vector clock merge', () async {
    final crdt1 = MapCrdtRoot<String, String>('node1');
    final crdt2 = MapCrdtRoot<String, String>('node2');
    crdt1.put('key', 'value');
    crdt2.merge(crdt1);
    final crdt1ClockValue = crdt1.vectorClock.value[crdt1.vectorClockIndex];
    expect(crdt2.vectorClock.value.length, 2);
    expect(
      crdt2.vectorClock.value[(crdt2.vectorClockIndex + 1) % 2],
      crdt1ClockValue,
    );
  });
  test('to json', () {
    final node1Clock = DistributedClock.now(
      VectorClock(1),
      'node1',
    );
    final crdt = MapCrdtRoot<String, String>(
      'node1',
      vectorClock: VectorClock.fromList([1]),
      records: <String, Record<String>>{
        'key': Record<String>(
          clock: node1Clock,
          value: 'value',
        ),
      },
    );
    expect(crdt.toJson(), {
      'node': 'node1',
      'nodes': ['node1'],
      'vectorClock': [1],
      'records': {
        'key': {
          'clock': node1Clock.toJson(),
          'value': 'value',
        },
      },
    });
  });
  test('from json', () {
    final node1Clock = DistributedClock.now(
      VectorClock(1),
      'node1',
    );
    final json = {
      'node': 'node1',
      'nodes': ['node1'],
      'vectorClock': [1],
      'records': {
        'key': {
          'clock': node1Clock.toJson(),
          'value': 'value',
        },
      },
    };
    final crdt = MapCrdtRoot<String, String>.fromJson(json);
    expect(crdt.vectorClock, VectorClock.fromList([1]));
    expect(crdt.nodes, ['node1']);
    expect(crdt.map, {'key': 'value'});
    expect(crdt.records, {
      'key': Record<String>(
        clock: node1Clock,
        value: 'value',
      ),
    });
  });
  test('to json value encode', () {
    final node1Clock = DistributedClock.now(
      VectorClock(1),
      'node1',
    );
    final crdt = MapCrdtRoot<String, ValueType>(
      'node1',
      vectorClock: VectorClock.fromList([1]),
      records: <String, Record<ValueType>>{
        'key': Record<ValueType>(
          clock: node1Clock,
          value: ValueType('value'),
        ),
      },
    );
    expect(
      crdt.toJson(
        valueEncode: (v) => {'value': v.value},
      ),
      {
        'node': 'node1',
        'nodes': ['node1'],
        'vectorClock': [1],
        'records': {
          'key': {
            'clock': node1Clock.toJson(),
            'value': {
              'value': 'value',
            },
          },
        },
      },
    );
  });
  test('from json value decode', () {
    final node1Clock = DistributedClock.now(
      VectorClock(1),
      'node1',
    );
    final json = {
      'node': 'node1',
      'nodes': ['node1'],
      'vectorClock': [1],
      'records': {
        'key': {
          'clock': node1Clock.toJson(),
          'value': {
            'value': 'value',
          },
        },
      },
    };
    // ignore: prefer-trailing-comma
    final crdt = MapCrdtRoot<String, ValueType>.fromJson(
      json,
      valueDecode: (dynamic valueJson) => ValueType((valueJson as Map<String, dynamic>)['value'] as String),
    );
    expect(crdt.vectorClock, VectorClock.fromList([1]));
    expect(crdt.nodes, ['node1']);
    expect(crdt.map, {'key': ValueType('value')});
    expect(crdt.records, {
      'key': Record<ValueType>(
        clock: node1Clock,
        value: ValueType('value'),
      ),
    });
  });
}

MapCrdtRoot<String, MapCrdtNode<String, String>> _deepCloneCrdt(
  MapCrdtRoot<String, MapCrdtNode<String, String>> crdt,
) {
  final crdtCopy = MapCrdtRoot<String, MapCrdtNode<String, String>>.from(crdt);
  crdtCopy.updateValues((k, v) => MapCrdtNode.from(v, parent: crdtCopy));
  return crdtCopy;
}

class ValueType {
  String value;

  ValueType(
    final this.value,
  );

  @override
  int get hashCode => value.hashCode;

  @override
  bool operator ==(
    final Object other,
  ) =>
      other is ValueType ? other.value == value : false;

  @override
  String toString() => 'ValueType("$value")';
}

void _setTimestamp(Record<String> record, int timestamp) {
  record.clock = DistributedClock(
    record.clock.vectorClock,
    timestamp,
    record.clock.node,
  );
}
