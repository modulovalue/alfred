import 'package:alfred/crdt/crdt/interface/crdt.dart';
import 'package:test/test.dart';

void crdtTests<T extends Crdt<String, int>>(
  final String nodeId, {
  final T Function()? syncSetup,
  final Future<T> Function()? asyncSetup,
  final void Function(T crdt)? syncTearDown,
  final Future<void> Function(T crdt)? asyncTearDown,
}) {
  group('Basic', () {
    late T crdt;
    setUp(() async {
      if (syncSetup != null) {
        crdt = syncSetup();
      } else {
        crdt = await asyncSetup!();
      }
    });
    test('Node ID', () {
      expect(crdt.nodeId, nodeId);
    });
    test('Empty', () {
      expect(crdt.isEmpty, isTrue);
      expect(crdt.length, 0);
      expect(crdt.map, <String, int>{});
    });
    test('One record', () {
      crdt.put('x', 1);
      expect(crdt.isEmpty, isFalse);
      expect(crdt.length, 1);
      expect(crdt.map, {'x': 1});
    });
    test('Empty after deleted record', () {
      crdt.put('x', 1);
      crdt.delete('x');
      expect(crdt.isEmpty, isTrue);
      expect(crdt.length, 0);
      expect(crdt.map, <String, int>{});
    });
    test('Put', () {
      crdt.put('x', 1);
      expect(crdt.get('x'), 1);
    });
    test('Update existing', () {
      crdt.put('x', 1);
      crdt.put('x', 2);
      expect(crdt.get('x'), 2);
    });
    test('Put many', () {
      crdt.putAll({'x': 2, 'y': 3});
      expect(crdt.get('x'), 2);
      expect(crdt.get('y'), 3);
    });
    test('Delete value', () {
      crdt.put('x', 1);
      crdt.put('y', 2);
      crdt.delete('x');
      expect(crdt.isDeleted('x'), isTrue);
      expect(crdt.isDeleted('y'), isFalse);
      expect(crdt.get('x'), null);
      expect(crdt.get('y'), 2);
    });
    test('Clear', () {
      crdt.put('x', 1);
      crdt.put('y', 2);
      crdt.clear();
      expect(crdt.isDeleted('x'), isTrue);
      expect(crdt.isDeleted('y'), isTrue);
      expect(crdt.get('x'), null);
      expect(crdt.get('y'), null);
    });
    tearDown(() async {
      if (syncTearDown != null) {
        syncTearDown(crdt);
      }
      if (asyncTearDown != null) {
        await asyncTearDown(crdt);
      }
    });
  });
  group('Watch', () {
    late T crdt;
    setUp(() async {
      if (syncSetup != null) {
        crdt = syncSetup();
      } else {
        crdt = await asyncSetup!();
      }
    });
    test('All changes', () async {
      final streamTest = expectLater(
        crdt.watch(),
        emitsInAnyOrder(<bool Function(MapEntry<String, int?>)>[
          (final event) => event.key == 'x' && event.value == 1,
          (final event) => event.key == 'y' && event.value == 2,
        ]),
      );
      crdt.put('x', 1);
      crdt.put('y', 2);
      await streamTest;
    });
    test('Key', () async {
      final streamTest = expectLater(
        crdt.watch(key: 'y'),
        emits(
          // ignore: avoid_dynamic_calls
          (final MapEntry<String, int?> event) => event.key == 'y' && event.value == 2,
        ),
      );
      crdt.put('x', 1);
      crdt.put('y', 2);
      await streamTest;
    });
    tearDown(() async {
      if (syncTearDown != null) {
        syncTearDown(crdt);
      }
      if (asyncTearDown != null) {
        await asyncTearDown(crdt);
      }
    });
  });
}
