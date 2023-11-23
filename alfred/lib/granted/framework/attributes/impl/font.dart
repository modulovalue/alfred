import '../../render/interface.dart';
import '../plotter_attribute.dart';

/// The font attribute sets the font-family for the [Text](#text).
///
/// An attribute for setting the font.
class FontAttrImpl implements FontAttr {
  /// The font to set.
  @override
  String font;

  /// The last font in the renderer.
  String? _last;

  /// Creates a line font attribute.
  FontAttrImpl(
    this.font,
  );

  /// Pushes the attribute to the renderer.
  @override
  void pushAttr(
    final PlotterRenderer r,
  ) {
    _last = r.state.currentFont;
    r.state.currentFont = font;
  }

  /// Pops the attribute from the renderer.
  @override
  void popAttr(
    final PlotterRenderer r,
  ) {
    r.state.currentFont = _last;
    _last = null;
  }
}

/// An attribute for setting the font.
abstract class FontAttr implements PlotterAttribute {
  /// The font to set.
  abstract String font;
}
