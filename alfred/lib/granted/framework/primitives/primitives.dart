/// A simple color for plotting.
///
/// Since there are many packages that the plotter could be used to
/// output to, such as opengl, svg, gnuplot, swing, etc.,
/// this is a generic color is used to reduce complexity and keep consistent.
abstract class Color {
  /// The red component for the color, 0 .. 1.
  abstract double red;

  /// The green component for the color, 0 .. 1.
  abstract double green;

  /// The blue component for the color, 0 .. 1.
  abstract double blue;

  /// The alpha component for the color, 0 .. 1.
  abstract double alpha;

  /// Sets the color to the given values.
  void set(
    final double red,
    final double green,
    final double blue, [
    final double alpha = 1.0,
  ]);
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
