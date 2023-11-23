import 'dart:html';
import 'dart:math';

import '../../basic/bounds.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../basic/transformer.dart';
import '../../plotter_item/impl/plotter.dart';
import '../../render/impl/html_canvas.dart';
import '../interface.dart';

PlotHtmlCanvas buildPlotHtmlCanvas({
  required final String targetDivId,
  required final Plotter plot,
}) =>
    PlotHtmlCanvas.fromElem(
      querySelector('#' + targetDivId)!,
      plot,
    );

/// Plotter renderer which outputs to a canvas.
class PlotHtmlCanvas implements PlotterPlot {
  /// The target html div to write to.
  final Element _targetDiv;

  /// The canvas element.
  final CanvasElement _canvas;

  /// The plotter to render.
  final Plotter plotter;

  /// The renderer used to plot with.
  late HtmlCanvasRenderer _renderer;

  /// Indicates that a refresh is pending.
  bool _pendingRender;

  /// Creates a plotter that outputs SVG.
  PlotHtmlCanvas.fromElem(
    this._targetDiv,
    this.plotter,
  )   : _canvas = CanvasElement(),
        _pendingRender = false {
    _canvas.style
      ..margin = "0px"
      ..padding = "0px"
      ..width = "100%"
      ..height = "100%";
    _canvas
      ..onResize.listen(
        (final _) => _resize(),
      )
      ..onMouseDown.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          plotter.handleOnMouseDown(me);
          if (me.redraw) {
            _resize();
          }
        },
      )
      ..onMouseMove.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          plotter.handleOnMouseMove(me);
          if (me.redraw) {
            _resize();
          }
        },
      )
      ..onMouseUp.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          plotter.handleOnMouseUp(me);
          if (me.redraw) {
            _resize();
          }
        },
      )
      ..onMouseWheel.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          final dw = e.deltaY.toDouble() / 300.0;
          plotter.handleOnMouseWheel(me, dw);
          plotter.handleOnMouseMove(me);
          if (me.redraw) {
            _resize();
          }
        },
      );
    _renderer = HtmlCanvasRenderer(
      (_canvas.getContext("2d") as CanvasRenderingContext2D?)!,
    );
    window.onResize.listen(
      (final _) => _resize(),
    );
    _targetDiv.append(_canvas);
    _resize();
  }

  /// Refreshes the canvas drawing.
  @override
  void refresh() => _resize();

  /// Called when the svg is resized.
  void _resize() {
    if (!_pendingRender) {
      _pendingRender = true;
      window.requestAnimationFrame(
        (final t) {
          if (_pendingRender) {
            _pendingRender = false;
            // Draw.
            _canvas.width = _width.floor();
            _canvas.height = _height.floor();
            _renderer.reset(_window, _projection);
            plotter.renderPlotWithRenderer(_renderer);
          }
        },
      );
    }
  }

  /// The width of the div that is being plotted to.
  double get _width {
    final box = _canvas.getBoundingClientRect();
    return (box.right - box.left).toDouble();
  }

  /// The height of the div that is being plotted to.
  double get _height {
    final box = _canvas.getBoundingClientRect();
    return (box.bottom - box.top).toDouble();
  }

  /// Gets the transformer for the plot target div.
  /// This is the projection from the view coordinates to the window coordinates.
  Transformer get _projection {
    final width = _width;
    final height = _height;
    double size = min(width, height);
    if (size <= 0.0) {
      size = 1.0;
    }
    return TransformerImpl(
      size,
      size,
      0.5 * width,
      0.5 * height,
    );
  }

  /// Gets the window size for the plot.
  Bounds get _window => BoundsImpl(0.0, 0.0, _width, _height);

  /// Creates a mouse event for a dart mouse event.
  PlotterMouseEvent _mouseLoc(
    final MouseEvent e,
  ) {
    final rect = _canvas.getBoundingClientRect();
    final localX = e.client.x - rect.left.toDouble();
    final localY = e.client.y - rect.top.toDouble();
    final viewProj = _projection.mul(plotter.windowToViewTransformer);
    return PlotterMouseEventImpl(
      _window,
      _projection,
      viewProj,
      localX,
      localY,
      PlotterMouseButtonStateImpl(
        button: e.button,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        altKey: e.altKey,
      ),
    );
  }
}
