import 'plotter_item.dart';

/// A plotter item for coordinate based items.
/// TODO this is bad. be explicit about the size of coordinates.
mixin BasicCoordsMixin implements PlotterItem {
  /// The x coordinates for the points.
  List<List<double>>? __coords;

  List<List<double>> get coords => __coords ??= () {
        final _coords = <List<double>>[];
        for (int i = 0; i < coordCount; i++) {
          _coords.add(<double>[]);
        }
        return _coords;
      }();

  int get coordCount;

  // Clears all the items.
  void clear() {
    for (int i = 0; i < coords.length; i++) {
      coords[i].clear();
    }
  }

  /// Adds values to the item.
  void add(
    final List<double> val,
  ) {
    final count = val.length;
    for (int i = 0; i < count; i += coords.length) {
      for (int j = 0; j < coords.length; j++) {
        coords[j].add(val[i + j]);
      }
    }
  }

  /// Sets the value to the item.
  void set(
    final int index,
    final List<double> val,
  ) {
    final count = val.length;
    final localCoords = <List<double>>[];
    for (int i = 0; i < coords.length; i++) {
      localCoords.add(<double>[]);
    }
    for (int i = 0; i < count; i += coords.length) {
      for (int j = 0; j < coords.length; j++) {
        localCoords[j].add(val[i + j]);
      }
    }
    for (int i = 0; i < coords.length; i++) {
      coords[i].setAll(index, coords[i]);
    }
  }

  /// Gets values from the item.
  List<double> get(
    final int index,
    final int count,
  ) {
    final val = <double>[];
    for (int i = 0; i < count; i++) {
      for (int j = 0; j < coords.length; j++) {
        val.add(coords[j][index + i]);
      }
    }
    return val;
  }

  /// The number of coordinate.
  int get count => coords[0].length;
}
