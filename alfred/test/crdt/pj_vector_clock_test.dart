import 'dart:convert';

import 'package:alfred/crdt/pj_vector_clock.dart';
import 'package:test/test.dart';

void main() {
  test('equality', () {
    final c1 = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    final c2 = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    expect(c1, c2);
  });
  test('hash equality', () {
    final c1 = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    final c2 = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    expect(c1.hashCode, c2.hashCode);
  });
  test('compare to equality', () {
    final c1 = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    final c2 = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    expect(c1.compareTo(c2), 0);
  });
  test('compare to less', () {
    expect(
      DistributedClock(
        VectorClock.fromList([1, 1]),
        42,
        'node1',
      ).compareTo(DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node1',
      )),
      -1,
    );
    expect(
      DistributedClock(
        VectorClock.fromList([1, 2]),
        41,
        'node1',
      ).compareTo(DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node1',
      )),
      -1,
    );
    expect(
      DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node0',
      ).compareTo(DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node1',
      )),
      -1,
    );
  });
  test('compare to greater', () {
    expect(
      DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node1',
      ).compareTo(DistributedClock(
        VectorClock.fromList([1, 1]),
        42,
        'node1',
      )),
      1,
    );
    expect(
      DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node1',
      ).compareTo(DistributedClock(
        VectorClock.fromList([1, 2]),
        41,
        'node1',
      )),
      1,
    );
    expect(
      DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node1',
      ).compareTo(DistributedClock(
        VectorClock.fromList([1, 2]),
        42,
        'node0',
      )),
      1,
    );
  });
  test('to json', () {
    final clock = DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1');
    expect(clock.toJson(), <String, dynamic>{
      'clock': [1, 2],
      'timestamp': 42,
      'node': 'node1',
    });
  });
  test('from json', () {
    const json = '{"clock": [1, 2], "timestamp": 42, "node": "node1"}';
    expect(
      DistributedClock.fromJson(jsonDecode(json) as Map<String, dynamic>),
      DistributedClock(VectorClock.fromList([1, 2]), 42, 'node1'),
    );
  });
  test('init num nodes', () {
    final clock = VectorClock(2);
    expect(clock.value, [0, 0]);
  });
  test('init from list', () {
    final list = [1, 2];
    final clock = VectorClock.fromList(list);
    expect(clock.value, [1, 2]);
    list[0] = 2;
    expect(clock.value, [1, 2], reason: 'list should be copied');
  });
  test('init from other', () {
    final c1 = VectorClock.fromList([1, 2]);
    final c2 = VectorClock.from(c1);
    expect(c2.value, [1, 2]);
  });
  test('increment', () {
    final clock = VectorClock.fromList([1, 2]);
    clock.increment(0);
    expect(clock.value, [2, 2]);
    clock.increment(1);
    expect(clock.value, [2, 3]);
  });
  test('equality', () {
    final c1 = VectorClock.fromList([1, 2]);
    final c2 = VectorClock.fromList([1, 2]);
    expect(c1, c2);
  });
  test('hash equality', () {
    final c1 = VectorClock.fromList([1, 2]);
    final c2 = VectorClock.fromList([1, 2]);
    expect(c1.hashCode, c2.hashCode);
  });
  test('merge', () {
    final c1 = VectorClock.fromList([1, 2]);
    final c2 = VectorClock.fromList([2, 1]);
    c1.merge(c2);
    expect(c1.value, [2, 2]);
  });
  test('partial compare equal', () {
    final c1 = VectorClock.fromList([1, 2]);
    final c2 = VectorClock.fromList([1, 2]);
    expect(c1.partialCompareTo(c2), 0);
  });
  test('partial compare greater', () {
    final c1 = VectorClock.fromList([2, 2]);
    final c2 = VectorClock.fromList([1, 2]);
    expect(c1.partialCompareTo(c2), 1);
  });
  test('partial compare less', () {
    final c1 = VectorClock.fromList([1, 1]);
    final c2 = VectorClock.fromList([1, 2]);
    expect(c1.partialCompareTo(c2), -1);
  });
  test('partial compare not comparable', () {
    final c1 = VectorClock.fromList([2, 1]);
    final c2 = VectorClock.fromList([1, 2]);
    expect(c1.partialCompareTo(c2), null);
  });
}
