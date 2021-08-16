import 'primitives.dart';

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
    final this._xmin,
    final this._ymin,
    final this._xmax,
    final this._ymax,
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
      if (_xmin > x) _xmin = x;
      if (_ymin > y) _ymin = y;
      if (_xmax < x) _xmax = x;
      if (_ymax < y) _ymax = y;
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
        if (_xmin > bounds.xmin) _xmin = bounds.xmin;
        if (_ymin > bounds.ymin) _ymin = bounds.ymin;
        if (_xmax < bounds.xmax) _xmax = bounds.xmax;
        if (_ymax < bounds.ymax) _ymax = bounds.ymax;
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

/// A generic transformation between two coordinate systems.
///
/// Since there are many packages that the plotter could be used to
/// output to, such as opengl, svg, gnuplot, swing, etc., this is a
/// simple non-matrix transformation to reduce complexity and to keep consistent.
class TransformerImpl implements Transformer {
  /// The x-axis scalar.
  double _xScalar;

  /// The y-axis scalar.
  double _yScalar;

  /// The x-axis post-scale offset.
  double _dx;

  /// The y-axis post-scale offset.
  double _dy;

  /// Creates a new transformer.
  TransformerImpl(
    final this._xScalar,
    final this._yScalar,
    final this._dx,
    final this._dy,
  )   :
        // ignore: prefer_asserts_with_message
        assert(_xScalar > 0.0),
        // ignore: prefer_asserts_with_message
        assert(_yScalar > 0.0);

  /// Creates a new identity transformer.
  TransformerImpl.identity()
      : _xScalar = 1.0,
        _yScalar = 1.0,
        _dx = 0.0,
        _dy = 0.0;

  /// Creates a copy of the given transformer.
  TransformerImpl.copy(
    final Transformer other,
  )   : _xScalar = other.xScalar,
        _yScalar = other.yScalar,
        _dx = other.dx,
        _dy = other.dy;

  @override
  void reset() {
    _xScalar = 1.0;
    _yScalar = 1.0;
    _dx = 0.0;
    _dy = 0.0;
  }

  @override
  void setScale(
    final double xScalar,
    final double yScalar,
  ) {
    _xScalar = xScalar;
    _yScalar = yScalar;
    // ignore: prefer_asserts_with_message
    assert(_xScalar > 0.0);
    // ignore: prefer_asserts_with_message
    assert(_yScalar > 0.0);
  }

  @override
  double get xScalar => _xScalar;

  @override
  double get yScalar => _yScalar;

  @override
  void setOffset(
    final double dx,
    final double dy,
  ) {
    _dx = dx;
    _dy = dy;
  }

  @override
  double get dx => _dx;

  @override
  double get dy => _dy;

  @override
  Transformer mul(
    final Transformer trans,
  ) =>
      TransformerImpl(
        _xScalar * trans.xScalar,
        _yScalar * trans.yScalar,
        transformX(trans.dx),
        transformY(trans.dy),
      );

  @override
  Bounds transform(
    final Bounds b,
  ) {
    if (b.isEmpty) {
      return BoundsImpl.empty();
    } else {
      return BoundsImpl(
        transformX(b.xmin),
        transformY(b.ymin),
        transformX(b.xmax),
        transformY(b.ymax),
      );
    }
  }

  @override
  double transformX(
    final double x,
  ) =>
      x * _xScalar + _dx;

  @override
  double transformY(
    final double y,
  ) =>
      y * _yScalar + _dy;

  @override
  Bounds untransform(
    final Bounds b,
  ) {
    if (b.isEmpty) {
      return BoundsImpl.empty();
    } else {
      return BoundsImpl(
        untransformX(b.xmin),
        untransformY(b.ymin),
        untransformX(b.xmax),
        untransformY(b.ymax),
      );
    }
  }

  @override
  double untransformX(
    final double x,
  ) =>
      (x - _dx) / _xScalar;

  @override
  double untransformY(
    final double y,
  ) =>
      (y - _dy) / _yScalar;
}

/// A simple color for plotting.
///
/// Since there are many packages that the plotter could be used to
/// output to, such as opengl, svg, gnuplot, swing, etc.,
/// this is a generic color is used to reduce complexity and keep consistent.
class ColorImpl implements Color {
  /// The red component for the color, 0 .. 1.
  double _red;

  /// The green component for the color, 0 .. 1.
  double _green;

  /// The blue component for the color, 0 .. 1.
  double _blue;

  /// The alpha component for the color, 0 .. 1.
  double _alpha;

  /// Creates a color.
  ColorImpl(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ])  : _red = _clamp(red),
        _green = _clamp(green),
        _blue = _clamp(blue),
        _alpha = _clamp(alpha);

  @override
  void set(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]) {
    _red = _clamp(red);
    _green = _clamp(green);
    _blue = _clamp(blue);
    _alpha = _clamp(alpha);
  }

  @override
  double get red => _red;

  @override
  set red(
    final double red,
  ) =>
      _red = _clamp(red);

  @override
  double get green => _green;

  @override
  set green(
    final double green,
  ) =>
      _green = _clamp(green);

  @override
  double get blue => _blue;

  @override
  set blue(
    final double blue,
  ) =>
      _blue = _clamp(blue);

  @override
  double get alpha => _alpha;

  @override
  set alpha(
    final double alpha,
  ) =>
      _alpha = _clamp(alpha);
}

/// Clamps a value to between 0 and 1 inclusively.
double _clamp(
  final double val,
) {
  if (val > 1.0) {
    return 1.0;
  } else {
    if (val < 0.0) {
      return 0.0;
    } else {
      return val;
    }
  }
}
