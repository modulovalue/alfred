import '../../render/interface.dart';
import '../plotter_attribute.dart';

/// The directed line attribute is a boolean to indicate if a line should
/// be drawn with an arrow at the end.
/// This effects [Line Strip](#line-strip), [Lines](#lines), and [Polygon](#polygon).
///
/// An attribute for setting if the line is directed or not.
class DirectedLineAttrImpl implements DirectedLineAttr {
  /// Gets the directed line flag to apply for this attribute.
  @override
  bool directed;

  /// The last directed line flag in the renderer.
  bool _last;

  /// Creates a directed line flag attribute.
  DirectedLineAttrImpl([
    this.directed = true,
  ]) : _last = false;

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.state.currentShouldDrawDirectedLines;
    r.state.currentShouldDrawDirectedLines = directed;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.state.currentShouldDrawDirectedLines = _last;
    _last = false;
  }
}

/// An attribute for setting if the line is directed or not.
abstract class DirectedLineAttr implements PlotterAttribute {
  /// Gets the directed line flag to apply for this attribute.
  abstract bool directed;
}
