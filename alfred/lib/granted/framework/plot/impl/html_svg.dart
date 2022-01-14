import 'dart:html';
import 'dart:math';
import 'dart:svg';

import '../../basic/bounds.dart';
import '../../basic/mouse_button_state.dart';
import '../../basic/mouse_event.dart';
import '../../basic/transformer.dart';
import '../../plotter_item/impl/plotter.dart';
import '../../render/impl/svg.dart';
import '../interface.dart';

// TODO hot to plot an svg from a file?
PlotHtmlSvg makePlotHtmlSvg({
  required final Element targetDiv,
  required final Plotter plot,
}) {
  final _svg = SvgSvgElement();
  _svg.style
    ..margin = "0px"
    ..padding = "0px"
    ..width = "100%"
    ..height = "100%";
  final renderer = SvgRenderer(
    renderReset: (final windows, final backgroundColorString) {
      _svg
        ..nodes.clear()
        ..attributes["viewBox"] = "0 0 " + windows.width.toString() + " " + windows.height.toString()
        ..style.backgroundColor = backgroundColorString;
    },
  );
  return PlotHtmlSvg(
    targetDiv: targetDiv,
    svg: _svg,
    plotter: plot,
    render: (final self) {
      renderer.reset(
        self._window,
        self.projection,
      );
      plot.renderPlotWithRenderer(renderer);
      return renderer.finalize();
    },
  );
}

/// Plotter renderer which outputs SVG.
class PlotHtmlSvg implements PlotterPlot {
  final Element targetDiv;
  final SvgSvgElement svg;
  final Plotter plotter;
  final String Function(PlotHtmlSvg) render;

  PlotHtmlSvg({
    required final this.targetDiv,
    required final this.svg,
    required final this.plotter,
    required final this.render,
  }) {
    svg
      ..onResize.listen(
        (final _) => _onSvgResize(),
      )
      ..onMouseDown.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          plotter.handleOnMouseDown(me);
          if (me.redraw) {
            _onSvgResize();
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
            _onSvgResize();
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
            _onSvgResize();
          }
        },
      )
      ..onMouseWheel.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          final dw = e.deltaY.toDouble() / 300;
          plotter.handleOnMouseWheel(me, dw);
          plotter.handleOnMouseMove(me);
          if (me.redraw) {
            _onSvgResize();
          }
        },
      );
    window.onResize.listen(
      (final _) => _onSvgResize(),
    );
    targetDiv.append(svg);
    _onSvgResize();
  }

  /// Refreshes the SVG drawing.
  @override
  void refresh() => _onSvgResize();

  /// Indicates that a refresh is pending.
  bool _isRenderingLock = false;

  void _onSvgResize() {
    if (!_isRenderingLock) {
      _isRenderingLock = true;
      window.requestAnimationFrame(
        (final t) {
          if (_isRenderingLock) {
            _isRenderingLock = false;
            // ignore: unsafe_html
            svg.setInnerHtml(
              render(this),
              treeSanitizer: NodeTreeSanitizer.trusted,
            );
          }
        },
      );
    }
  }

  /// The width of the div that is being plotted to.
  double get _width {
    final box = svg.getBoundingClientRect();
    return (box.right - box.left).toDouble();
  }

  /// The height of the div that is being plotted to.
  double get _height {
    final box = svg.getBoundingClientRect();
    return (box.bottom - box.top).toDouble();
  }

  /// Gets the transformer for the plot target div.
  /// This is the projection from the view coordinates to the window coordinates.
  Transformer get projection {
    final width = _width;
    final height = _height;
    final size = () {
      final _size = min(width, height);
      if (_size <= 0.0) {
        return 1.0;
      } else {
        return _size;
      }
    }();
    return TransformerImpl(
      size,
      size,
      0.5 * width,
      0.5 * height,
    );
  }

  /// Gets the window size for the plot.
  Bounds get _window => BoundsImpl(
        0.0,
        0.0,
        _width,
        _height,
      );

  /// Creates a mouse event for a dart mouse event.
  PlotterMouseEvent _mouseLoc(
    final MouseEvent e,
  ) {
    final pt = svg.createSvgPoint()
      ..x = e.client.x
      ..y = e.client.y;
    final local = pt.matrixTransform(
      svg.getScreenCtm().inverse(),
    );
    final viewProj = projection.mul(
      plotter.windowToViewTransformer,
    );
    return PlotterMouseEventImpl(
      _window,
      projection,
      viewProj,
      local.x!.toDouble(),
      local.y!.toDouble(),
      PlotterMouseButtonStateImpl(
        button: e.button,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        altKey: e.altKey,
      ),
    );
  }
}
