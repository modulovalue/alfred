import 'bounds.dart';

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

/// A generic transformation between two coordinate systems.
///
/// Since there are many packages that the plotter could be used to
/// output to, such as opengl, svg, gnuplot, swing, etc., this is a
/// simple non-matrix transformation to reduce complexity and to keep consistent.
abstract class Transformer {
  /// The x-axis scalar.
  double get xScalar;

  /// The y-axis scalar.
  double get yScalar;

  /// The x-axis post-scale offset.
  double get dx;

  /// The y-axis post-scale offset.
  double get dy;

  /// Resets the transformer to the identity.
  void reset();

  /// Sets the scalars of the transformation.
  /// The scalars should be positive and non-zero.
  void setScale(
    final double xScalar,
    final double yScalar,
  );

  /// Sets the post-scalar offset.
  /// During a transformation the offset are added to the location after scaling, hence post-scalar.
  void setOffset(
    final double dx,
    final double dy,
  );

  /// Creates a transformer which is the multiple of this transformer and the given transformer.
  // Transformers are not commutative when multiplying since they are coordinate transformations just like matrices.
  Transformer mul(
    final Transformer trans,
  );

  /// Transforms a bounds from the source coordinate system into the destination coordinate system.
  Bounds transform(
    final Bounds b,
  );

  /// Transforms the given x value from the source coordinate system into the destination coordinate system.
  /// First the value is scaled then translated with the offset.
  double transformX(
    final double x,
  );

  /// Transforms the given y value from the source coordinate system into the destination coordinate system.
  /// First the value is scaled then translated with the offset.
  double transformY(
    final double y,
  );

  /// Performs an inverse transformation on the given bounds.
  Bounds untransform(
    final Bounds b,
  );

  /// Performs an inverse transformation on the given x value.
  double untransformX(
    final double x,
  );

  /// Performs an inverse transformation on the given y value.
  double untransformY(
    final double y,
  );
}
