import 'dart:async';

import '../../hlc/interface/hlc.dart';
import '../interface/record.dart';
import 'base.dart';

/// A CRDT backed by a in-memory map.
/// Useful for testing, or for applications which
/// only require temporary datasets.
class MapCrdt<K, V extends Object> extends CrdtBase<K, V> {
  final Map<K, Record<V>> _map = <K, Record<V>>{};
  final StreamController<MapEntry<K, V?>> _controller = StreamController<MapEntry<K, V?>>.broadcast();
  @override
  final String nodeId;

  MapCrdt(
    final this.nodeId, [
    final Map<K, Record<V>> seed = const {},
  ]) {
    _map.addAll(seed);
  }

  @override
  bool containsKey(
    final K key,
  ) =>
      _map.containsKey(key);

  @override
  Record<V>? getRecord(
    final K key,
  ) =>
      _map[key];

  @override
  void putRecord(
    final K key,
    final Record<V> value,
  ) {
    _map[key] = value;
    final _entry = MapEntry(key, value.value);
    _controller.add(_entry);
  }

  @override
  void putRecords(
    final Map<K, Record<V>> recordMap,
  ) {
    _map.addAll(recordMap);
    recordMap
        .map(
          (final key, final value) => MapEntry(key, value.value),
        )
        .entries
        .forEach(_controller.add);
  }

  @override
  Map<K, Record<V>> recordMap({
    final Hlc? modifiedSince,
  }) =>
      Map<K, Record<V>>.from(_map)
        ..removeWhere(
          (final _, final record) => record.modified.logicalTime < (modifiedSince?.logicalTime ?? 0),
        );

  @override
  Stream<MapEntry<K, V?>> watch({
    final K? key,
  }) =>
      _controller.stream.where(
        (final event) => key == null || key == event.key,
      );

  @override
  void purge() => _map.clear();
}
