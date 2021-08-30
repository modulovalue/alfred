import '../../hlc/interface/hlc.dart';

/// Stores a value associated with a given HLC.
abstract class Record<V> {
  Hlc get hlc;

  V? get value;

  Hlc get modified;

  bool get isDeleted;
}
