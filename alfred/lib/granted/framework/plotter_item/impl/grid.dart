import 'dart:math';

import '../../basic/bounds.dart';
import '../../basic/color.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';

/// A plotter item to draw a grid.
class Grid with PlotterItemMixin {
  /// The closest grid color to the background color.
  final Color _backClr;

  /// The heaviest grid color.
  final Color _foreClr;

  /// The axis grid color.
  final Color _axisClr;

  /// Creates a grid item.
  Grid()
      : _backClr = ColorImpl(0.9, 0.9, 1.0),
        _foreClr = ColorImpl(0.5, 0.5, 1.0),
        _axisClr = ColorImpl(1.0, 0.7, 0.7) {
    addColor(0.0, 0.0, 0.0);
  }

  /// Gets the smallest power of 10 which is greater than the given value.
  int _getMaxPow(
    final double value,
  ) =>
      (log(value) / ln10).ceil();

  /// Gets the number above the given value in multiples of the given power value.
  double _getUpper(
    final double value,
    final double pow,
  ) =>
      (value / pow).ceilToDouble() * pow;

  /// Gets the number below the given value in multiples of the given power value.
  double _getLower(
    final double value,
    final double pow,
  ) =>
      (value / pow).floorToDouble() * pow;

  /// Adds a horizontal line at the given offset to the given group.
  void _addHorz(
    final List<double> group,
    final double offset,
    final Bounds window,
    final Bounds view,
  ) {
    final y = (offset - view.ymin) * window.height / view.height;
    if ((y > 0.0) && (y < window.height)) {
      group.add(y);
    }
  }

  /// The recursive method used to get a horizontal grid line and children grid lines.
  /// [groups] is the group of horizontal line groups.
  /// [window] is the window being drawn into.
  /// [view] is the viewport of the render space.
  /// [pow] is the minimum power to draw at.
  /// [minOffset] is the minimum offset into the view.
  /// [maxOffset] is the maximum offset into the view.
  /// [rmdPow] is the current offset of the power to get the lines for.
  void _getHorzs(
    final List<List<double>> groups,
    final Bounds window,
    final Bounds view,
    final double pow,
    final double minOffset,
    final double maxOffset,
    final int rmdPow,
  ) {
    if (rmdPow > 0) {
      final lowPow = pow / 10.0;
      double offset = minOffset;
      _getHorzs(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
      if (offset + pow != offset) {
        final group = groups[rmdPow - 1];
        for (offset += pow; offset < maxOffset; offset += pow) {
          _addHorz(group, offset, window, view);
          _getHorzs(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
        }
      }
    }
  }

  /// Adds a vertical line at the given offset to the given group.
  void _addVert(
    final List<double> group,
    final double offset,
    final Bounds window,
    final Bounds view,
  ) {
    final x = (offset - view.xmin) * window.width / view.width;
    if ((x > 0.0) && (x < window.width)) {
      group.add(x);
    }
  }

  /// The recursive method used to get a vertical grid line and children grid lines.
  /// [groups] is the group of vertical line groups.
  /// [window] is the window being drawn into.
  /// [view] is the viewport of the render space.
  /// [pow] is the minimum power to draw at.
  /// [minOffset] is the minimum offset into the view.
  /// [maxOffset] is the maximum offset into the view.
  /// [rmdPow] is the current offset of the power to get the lines for.
  void _getVerts(
    final List<List<double>> groups,
    final Bounds window,
    final Bounds view,
    final double pow,
    final double minOffset,
    final double maxOffset,
    final int rmdPow,
  ) {
    if (rmdPow <= 0) {
      return;
    }
    final lowPow = pow / 10.0;
    double offset = minOffset;
    final group = groups[rmdPow - 1];
    _getVerts(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
    for (offset += pow; offset < maxOffset; offset += pow) {
      _addVert(group, offset, window, view);
      _getVerts(groups, window, view, lowPow, offset, offset + pow, rmdPow - 1);
    }
  }

  /// Sets the linearly interpolated color used for the grid lines to the renderer.
  void _setColor(
    final PlotterRenderer r,
    final int rmdPow,
    final int diff,
  ) {
    final fraction = rmdPow / diff;
    final red = _backClr.red + fraction * (_foreClr.red - _backClr.red);
    final green = _backClr.green + fraction * (_foreClr.green - _backClr.green);
    final blue = _backClr.blue + fraction * (_foreClr.blue - _backClr.blue);
    r.state.color = ColorImpl(red, green, blue);
  }

  /// Draws the grid lines.
  void _drawGrid(
    final PlotterRenderer r,
    final Bounds window,
    final Bounds view,
  ) {
    const minSpacing = 5.0;
    int maxPow = max(
      _getMaxPow(view.width),
      _getMaxPow(view.height),
    );
    int minPow = min(
      _getMaxPow(view.width * minSpacing / window.width),
      _getMaxPow(
        view.height * minSpacing / window.height,
      ),
    );
    int diff = maxPow - minPow;
    if (diff <= 0) {
      diff = 1;
      maxPow = 1;
      minPow = 0;
    }
    final _pow = pow(10, maxPow - 1).toDouble();
    final maxXOffset = _getUpper(view.xmax, _pow);
    final minXOffset = _getLower(view.xmin, _pow);
    final maxYOffset = _getUpper(view.ymax, _pow);
    final minYOffset = _getLower(view.ymin, _pow);
    final horzs = <List<double>>[];
    final verts = <List<double>>[];
    for (int i = 0; i < diff; ++i) {
      horzs.add(<double>[]);
      verts.add(<double>[]);
    }
    _getHorzs(horzs, window, view, _pow, minYOffset, maxYOffset, diff);
    _getVerts(verts, window, view, _pow, minXOffset, maxXOffset, diff);
    for (int i = 0; i < diff; ++i) {
      _setColor(r, i, diff);
      for (final y in horzs[i]) {
        r.actions.drawLine(window.xmin, y, window.xmax, y);
      }
      for (final x in verts[i]) {
        r.actions.drawLine(x, window.ymin, x, window.ymax);
      }
    }
  }

  /// Draws the axis grid lines.
  void _drawAxis(
    final PlotterRenderer r,
    final Bounds window,
    final Bounds view,
  ) {
    if ((view.xmin <= 0.0) && (view.xmax >= 0.0)) {
      final group = <double>[];
      _addVert(group, 0.0, window, view);
      if (group.length == 1) {
        r.state.color = _axisClr;
        final x = group[0];
        r.actions.drawLine(x, window.ymin, x, window.ymax);
      }
    }
    if ((view.ymin <= 0.0) && (view.ymax >= 0.0)) {
      final group = <double>[];
      _addHorz(group, 0.0, window, view);
      if (group.length == 1) {
        r.state.color = _axisClr;
        final y = group[0];
        r.actions.drawLine(window.xmin, y, window.xmax, y);
      }
    }
  }

  /// Draws the grid item.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) {
    final window = r.state.drawPanelBounds;
    final view = r.state.viewportIntoWindow;
    if (view.width > 0.0) {
      if (view.height > 0.0) {
        final last = r.state.transform;
        r.state.transform = TransformerImpl.identity();
        _drawGrid(r, window!, view);
        _drawAxis(r, window, view);
        r.state.transform = last;
      }
    }
  }

  /// Get the bounds for the grid.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) =>
      BoundsImpl.empty();
}
