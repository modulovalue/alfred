import 'dart:math';

import '../../basic/bounds.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../basic/transformer.dart';
import '../../mouse/impl/mouse_pan.dart';
import '../../mouse/mouse_handle.dart';
import '../../render/interface.dart';
import 'data_bounds.dart';
import 'grid.dart';
import 'group.dart';

Plotter makePlotter([
  final String label = "",
]) {
  final bounds = BoundsImpl.empty();
  final view = TransformerImpl.identity();
  return Plotter(
    dataBounds: bounds,
    windowToViewTransformer: view,
    mouseHandles: <PlotterMouseHandle>[
      makeMousePan(
        view,
        view.setOffset,
        const PlotterMouseButtonStateImpl(
          button: 0,
        ),
      ),
    ],
    label: label,
  )
    ..addItems(
      [
        Grid(),
        DataBounds(),
      ],
    )
    ..addColor(0.0, 0.0, 0.0);
}

/// The plotter to quickly draw 2D plots.
/// Great for reviewing data and debugging 2D algorithms.
class Plotter extends Group {
  static const double _minZoom = 1.0e-4;
  static const double _maxZoom = 1.0e+4;
  Bounds dataBounds;
  final Transformer windowToViewTransformer;
  final List<PlotterMouseHandle> mouseHandles;

  Plotter({
    required final this.dataBounds,
    required final this.windowToViewTransformer,
    required final this.mouseHandles,
    required final String label,
  }) : super(label);

  /// Note: May need to call updateBounds before this if the data has changed.
  void focusOnData() => focusViewOnGivenBounds(dataBounds);

  void focusViewOnGivenBounds(
    final Bounds bounds, [
    final double scalar = 0.95,
  ]) {
    windowToViewTransformer.reset();
    if (!bounds.isEmpty) {
      final scale = scalar /
          max(
            bounds.width,
            bounds.height,
          );
      windowToViewTransformer.setScale(
        scale,
        scale,
      );
      windowToViewTransformer.setOffset(
        -0.5 * (bounds.xmin + bounds.xmax) * scale,
        -0.5 * (bounds.ymin + bounds.ymax) * scale,
      );
    }
  }

  /// This should be called whenever the data has changed.
  void updateDataBounds() => dataBounds = onGetBounds(
        windowToViewTransformer,
      );

  void renderPlotWithRenderer(
    final PlotterRenderer renderer,
  ) {
    renderer.state.dataSetBounds = dataBounds;
    final trans = renderer.state.transform!.mul(
      windowToViewTransformer,
    );
    renderer.state.transform = trans;
    draw(renderer);
  }

  void setOffsetOfTheViewTransformation(
    final double x,
    final double y,
  ) =>
      windowToViewTransformer.setOffset(x, y);

  /// Note: This is 10 to the power of the given value, such that 0 is x1.0 zoom.
  void setViewTransformationZoom(
    final double pow_,
  ) {
    final scale = pow(10.0, pow_).toDouble();
    windowToViewTransformer.setScale(scale, scale);
  }

  void handleOnMouseDown(
    final PlotterMouseEvent e,
  ) {
    for (final hndl in mouseHandles) {
      hndl.mouseDown(e);
    }
  }

  void handleOnMouseMove(
    final PlotterMouseEvent e,
  ) {
    for (final hndl in mouseHandles) {
      hndl.mouseMove(e);
    }
  }

  void handleOnMouseUp(
    final PlotterMouseEvent e,
  ) {
    for (final hndl in mouseHandles) {
      hndl.mouseUp(e);
    }
  }

  void handleOnMouseWheel(
    final PlotterMouseEvent e,
    final double dw,
  ) {
    final prev = max(
      windowToViewTransformer.xScalar,
      windowToViewTransformer.yScalar,
    );
    double scale = pow(10.0, log(prev) / ln10 - dw) as double;
    if (scale < _minZoom) {
      scale = _minZoom;
    } else if (scale > _maxZoom) {
      scale = _maxZoom;
    }
    final x = e.px;
    final y = e.py;
    final dx = (windowToViewTransformer.dx - x) * (scale / prev) + x;
    final dy = (windowToViewTransformer.dy - y) * (scale / prev) + y;
    windowToViewTransformer.setOffset(dx, dy);
    windowToViewTransformer.setScale(scale, scale);
    e.redraw = true;
  }
}
