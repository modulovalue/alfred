import '../../render/interface.dart';
import '../plotter_attribute.dart';

/// The point size attribute indicates if a point should be drawn and the size to
/// draw the point in pixels.
/// This effects [Line Strip](#line-strip), [Lines](#lines), [Points](#points),
/// and [Polygon](#polygon).
///
/// An attribute for setting the point size.
class PointSizeAttrImpl implements PointSizeAttr {
  /// The size of the point to set.
  @override
  double size;

  /// The previous size of the point to store.
  double _last;

  /// Creates a new point size attribute.
  PointSizeAttrImpl(
    final this.size,
  ) : _last = 0.0;

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.state.currentPointSize;
    r.state.currentPointSize = size;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) =>
      r.state.currentPointSize = _last;
}

/// An attribute for setting the point size.
abstract class PointSizeAttr implements PlotterAttribute {
  /// The size of the point to set.
  abstract double size;
}
