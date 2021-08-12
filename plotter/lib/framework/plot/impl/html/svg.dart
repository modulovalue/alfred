import 'dart:html';
import 'dart:math';
import 'dart:svg';

import '../../../events/events.dart';
import '../../../events/events_impl.dart';
import '../../../plotter/plotter_impl.dart';
import '../../../primitives/primitives.dart';
import '../../../primitives/primitives_impl.dart';
import '../../../render/impl/svg.dart';
import '../../interface.dart';

PlotHtmlSvg buildPlotHtmlSvg({
  required final String targetDivId,
  required final Plotter plot,
}) =>
    PlotHtmlSvg(
      querySelector('#' + targetDivId)!,
      plot,
    );

/// Plotter renderer which outputs SVG.
class PlotHtmlSvg implements PlotterPlot {
  /// The target html div to write to.
  final Element _targetDiv;

  /// The SVG element.
  final SvgSvgElement _svg;

  /// The plotter to render.
  final Plotter plotter;

  /// The renderer used to plot with.
  late SvgRenderer _renderer;

  /// Creates a plotter that outputs SVG.
  PlotHtmlSvg(
    final this._targetDiv,
    final this.plotter,
  ) : _svg = SvgSvgElement() {
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
      ..onResize.listen(
        (final _) => _onSvgResize(),
      )
      ..onMouseDown.listen(
        (final e) {
          e.stopPropagation();
          e.preventDefault();
          final me = _mouseLoc(e);
          plotter.onMouseDown(me);
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
          plotter.onMouseMove(me);
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
          plotter.onMouseUp(me);
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
          final dw = e.deltaY.toDouble() / 300.0;
          plotter.onMouseWheel(me, dw);
          plotter.onMouseMove(me);
          if (me.redraw) {
            _onSvgResize();
          }
        },
      );
    window.onResize.listen(
      (final _) => _onSvgResize(),
    );
    _targetDiv.append(_svg);
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
            // Draw.
            _renderer.reset(_window, _projection);
            plotter.render(_renderer);
            _renderer.finalize();
          }
        },
      );
    }
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
    final pt = _svg.createSvgPoint();
    pt.x = e.client.x;
    pt.y = e.client.y;
    final local = pt.matrixTransform(_svg.getScreenCtm().inverse());
    final viewProj = _projection.mul(plotter.view);
    return PlotterMouseEventImpl(
      _window,
      _projection,
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

_SvgValidator makeSvgValidator({
  required final SvgSvgElement svg,
  final bool validateSVG = false,
}) {
  if (validateSVG) {
    return _SvgValidator(
      NodeValidatorBuilder()..allowSvg(),
      null,
      svg,
    );
  } else {
    return _SvgValidator(
      null,
      NodeTreeSanitizer.trusted,
      svg,
    );
  }
}

class _SvgValidator {
  /// SVG validator for adding HTML.
  final NodeValidatorBuilder? _svgValidator;

  /// SVG tree sanitizer for adding HTML.
  final NodeTreeSanitizer? _treeSanitizer;

  /// The element to add graphics to.
  final SvgSvgElement _svg;

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
