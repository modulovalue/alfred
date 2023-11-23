/// A boundary of data.
class BoundsImpl implements Bounds {
  /// Indicate the bounds are empty.
  bool _empty;

  /// The minimum x of the bounds.
  double _xmin;

  /// The minimum y of the bounds.
  double _ymin;

  /// The maximum x of the bounds.
  double _xmax;

  /// The maximum y of the bounds.
  double _ymax;

  /// Creates a new boundary for data.
  BoundsImpl(
    this._xmin,
    this._ymin,
    this._xmax,
    this._ymax,
  ) : _empty = false;

  /// Creates a new empty bounds.
  BoundsImpl.empty()
      : _empty = true,
        _xmin = 0.0,
        _ymin = 0.0,
        _xmax = 0.0,
        _ymax = 0.0;

  /// Indicates if the bounds are empty.
  @override
  bool get isEmpty => _empty;

  /// Gets the minimum x of the bounds.
  @override
  double get xmin => _xmin;

  /// Gets the minimum y of the bounds.
  @override
  double get ymin => _ymin;

  /// Gets the maximum x of the bounds.
  @override
  double get xmax => _xmax;

  /// Gets the maximum y of the bounds.
  @override
  double get ymax => _ymax;

  /// Gets the width of the bounds.
  @override
  double get width => _xmax - _xmin;

  /// Gets the height of the bounds.
  @override
  double get height => _ymax - _ymin;

  /// Expands the bounds to include the given point.
  @override
  void expand(
    final double x,
    final double y,
  ) {
    if (_empty) {
      _empty = false;
      _xmin = _xmax = x;
      _ymin = _ymax = y;
    } else {
      if (_xmin > x) {
        _xmin = x;
      }
      if (_ymin > y) {
        _ymin = y;
      }
      if (_xmax < x) {
        _xmax = x;
      }
      if (_ymax < y) {
        _ymax = y;
      }
    }
  }

  /// Unions the other bounds into this bounds.
  @override
  void union(
    final Bounds bounds,
  ) {
    if (isEmpty) {
      _empty = bounds.isEmpty;
      _xmin = bounds.xmin;
      _ymin = bounds.ymin;
      _xmax = bounds.xmax;
      _ymax = bounds.ymax;
    } else {
      if (!bounds.isEmpty) {
        if (_xmin > bounds.xmin) {
          _xmin = bounds.xmin;
        }
        if (_ymin > bounds.ymin) {
          _ymin = bounds.ymin;
        }
        if (_xmax < bounds.xmax) {
          _xmax = bounds.xmax;
        }
        if (_ymax < bounds.ymax) {
          _ymax = bounds.ymax;
        }
      }
    }
  }

  /// Gets the string of the bounds.
  @override
  String toString() {
    if (_empty) {
      return "[empty]";
    } else {
      return "[${_xmin}, ${_ymin}, ${_xmax}, ${_ymax}]";
    }
  }
}

/// A boundary of data.
abstract class Bounds {
  /// Indicates if the bounds are empty.
  bool get isEmpty;

  /// Gets the minimum x of the bounds.
  double get xmin;

  /// Gets the minimum y of the bounds.
  double get ymin;

  /// Gets the maximum x of the bounds.
  double get xmax;

  /// Gets the maximum y of the bounds.
  double get ymax;

  /// Gets the width of the bounds.
  double get width;

  /// Gets the height of the bounds.
  double get height;

  /// Expands the bounds to include the given point.
  void expand(
    final double x,
    final double y,
  );

  /// Unions the other bounds into this bounds.
  void union(
    final Bounds bounds,
  );
}
