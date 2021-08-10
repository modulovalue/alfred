import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:svg' as svg;

import '../framework/events/events.dart';
import '../framework/events/events_impl.dart';
import '../framework/plotter/plotter.dart';
import '../framework/plotter/plotter_impl.dart';
import '../framework/primitives/primitives.dart';
import '../framework/primitives/primitives_impl.dart';
import 'svg_renderer.dart';

PlotSvg buildPlotSvg({
  required final String targetDivId,
  required final Plotter plot,
}) =>
    PlotSvg.fromElem(
      html.querySelector('#' + targetDivId)!,
      plot,
    );

/// Plotter renderer which outputs SVG.
class PlotSvg implements PlotterPlot {
  /// The target html div to write to.
  final html.Element _targetDiv;

  /// The SVG element.
  final svg.SvgSvgElement _svg;

  /// The plotter to render.
  final Plotter plotter;

  /// The renderer used to plot with.
  late SvgRenderer _renderer;

  /// Indicates that a refresh is pending.
  bool _pendingRender;

  /// Creates a plotter that outputs SVG.
  PlotSvg.fromElem(
    final this._targetDiv,
    final this.plotter,
  )   : _svg = svg.SvgSvgElement(),
        _pendingRender = false {
    final validator = makeSvgValidator(
      svg: _svg,
    );
    _renderer = SvgRenderer(
      (final svg) => _renderSvgValidator(
        validator: validator,
        svg: svg,
      ),
      (final windows, final backgroundColorString) => _resetSvgValidator(
        validator: validator,
        window: windows,
        backgroundColorString: backgroundColorString,
      ),
    );
    _svg.style
      ..margin = "0px"
      ..padding = "0px"
      ..width = "100%"
      ..height = "100%";
    _svg
      ..onResize.listen(_resize)
      ..onMouseDown.listen(_mouseDown)
      ..onMouseMove.listen(_mouseMove)
      ..onMouseUp.listen(_mouseUp)
      ..onMouseWheel.listen(_mouseWheelMoved);
    html.window.onResize.listen(_resize);
    _targetDiv.append(_svg);
    refresh();
  }

  /// Refreshes the SVG drawing.
  @override
  void refresh() {
    if (!_pendingRender) {
      _pendingRender = true;
      html.window.requestAnimationFrame(
        (final t) {
          if (_pendingRender) {
            _pendingRender = false;
            _draw();
          }
        },
      );
    }
  }

  /// Draws to the target with SVG.
  void _draw() {
    _renderer.reset(_window, _projection);
    plotter.render(_renderer);
    _renderer.finalize();
  }

  /// The width of the div that is being plotted to.
  double get _width {
    final box = _svg.getBoundingClientRect();
    return (box.right - box.left).toDouble();
  }

  /// The height of the div that is being plotted to.
  double get _height {
    final box = _svg.getBoundingClientRect();
    return (box.bottom - box.top).toDouble();
  }

  /// Gets the transformer for the plot target div.
  /// This is the projection from the view coordinates to the window coordinates.
  Transformer get _projection {
    final width = _width;
    final height = _height;
    double size = math.min(width, height);
    if (size <= 0.0) size = 1.0;
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

  /// Called when the svg is resized.
  void _resize(
    final html.Event _,
  ) =>
      refresh();

  /// Creates a mouse event for a dart mouse event.
  MouseEvent _mouseLoc(
    final html.MouseEvent e,
  ) {
    final pt = _svg.createSvgPoint();
    pt.x = e.client.x;
    pt.y = e.client.y;
    final local = pt.matrixTransform(_svg.getScreenCtm().inverse());
    final viewProj = _projection.mul(plotter.view);
    return MouseEventImpl(
      _window,
      _projection,
      viewProj,
      (local.x as double?)!,
      (local.y as double?)!,
      MouseButtonStateImpl(
        button: e.button,
        shiftKey: e.shiftKey,
        ctrlKey: e.ctrlKey,
        altKey: e.altKey,
      ),
    );
  }

  /// Called when the mouse button is pressed on the panel.
  void _mouseDown(
    final html.MouseEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    plotter.onMouseDown(me);
    if (me.redraw) {
      refresh();
    }
  }

  /// Called when the mouse is moved with the button down.
  void _mouseMove(
    final html.MouseEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    plotter.onMouseMove(me);
    if (me.redraw) {
      refresh();
    }
  }

  /// Called when the mouse button is released.
  void _mouseUp(
    final html.MouseEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    plotter.onMouseUp(me);
    if (me.redraw) {
      refresh();
    }
  }

  /// Called when the mouse wheel is moved.
  void _mouseWheelMoved(
    final html.WheelEvent e,
  ) {
    e.stopPropagation();
    e.preventDefault();
    final me = _mouseLoc(e);
    final dw = e.deltaY.toDouble() / -300.0;
    plotter.onMouseWheel(me, dw);
    plotter.onMouseMove(me);
    if (me.redraw) {
      refresh();
    }
  }
}

_SvgValidator makeSvgValidator({
  required final svg.SvgSvgElement svg,
  final bool validateSVG = false,
}) {
  if (validateSVG) {
    return _SvgValidator(
      html.NodeValidatorBuilder()..allowSvg(),
      null,
      svg,
    );
  } else {
    return _SvgValidator(
      null,
      html.NodeTreeSanitizer.trusted,
      svg,
    );
  }
}

class _SvgValidator {
  /// SVG validator for adding HTML.
  final html.NodeValidatorBuilder? _svgValidator;

  /// SVG tree sanitizer for adding HTML.
  final html.NodeTreeSanitizer? _treeSanitizer;

  /// The element to add graphics to.
  final svg.SvgSvgElement _svg;

  const _SvgValidator(
    final this._svgValidator,
    final this._treeSanitizer,
    final this._svg,
  );
}

void _resetSvgValidator({
  required final _SvgValidator validator,
  required final Bounds window,
  required final String backgroundColorString,
}) =>
    validator
      .._svg.nodes.clear()
      .._svg.attributes["viewBox"] = "0 0 " + window.width.toString() + " " + window.height.toString()
      .._svg.style.backgroundColor = backgroundColorString;

void _renderSvgValidator({
  required final _SvgValidator validator,
  required final String svg,
}) =>
    // ignore: unsafe_html
    validator._svg.setInnerHtml(
      svg,
      validator: validator._svgValidator,
      treeSanitizer: validator._treeSanitizer,
    );
