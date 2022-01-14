import '../render/interface.dart';

/// The interface for all attributes.
abstract class PlotterAttribute {
  /// Pushes the attribute to the renderer.
  void pushAttr(
    final PlotterRenderer r,
  );

  /// Pops the attribute from the renderer.
  void popAttr(
    final PlotterRenderer r,
  );
}
