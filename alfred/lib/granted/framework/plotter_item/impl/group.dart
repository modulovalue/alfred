import '../../basic/bounds.dart';
import '../../basic/transformer.dart';
import '../../render/interface.dart';
import '../base_mixin.dart';
import '../plotter_item.dart';
import 'circle_group.dart';
import 'circles.dart';
import 'ellipse_group.dart';
import 'ellipses.dart';
import 'line_strip.dart';
import 'lines.dart';
import 'points.dart';
import 'polygon.dart';
import 'rectangle_group.dart';
import 'rectangles.dart';
import 'text.dart';

/// A group is a collection of items. The attributes applied to the group
/// will be applied to the internal items unless overwritten by an attribute
/// on the contained item. The plotter is an extension of a group. Groups
/// also provide several methods for easily adding items. A group may also
/// contain a label for easily identifying.
///
/// A group for plotter items.
class Group with PlotterItemMixin {
  /// The label for the group.
  String label;

  /// Indicates if the item is enabled or disabled.
  @override
  // ignore: overridden_fields
  bool enabled;

  /// The plotter items in this group.
  final List<PlotterItem> _items;

  /// Creates a new plotter item group.
  Group([
    final this.label = "",
    final this.enabled = true,
  ]) : _items = <PlotterItem>[];

  /// The number of items in the group.
  int get count => _items.length;

  /// The list of items in the group.
  List<PlotterItem> get items => _items;

  /// Adds plotter items to the group.
  void addItems(
    final List<PlotterItem> items,
  ) {
    // ignore: prefer_foreach
    for (final item in items) {
      _items.add(item);
    }
  }

  /// Adds a text plotter item with the given data.
  Text addText(
    final double x,
    final double y,
    final double size,
    final String text, [
    final bool scale = false,
  ]) {
    final item = Text(x, y, size, text, scale);
    addItems([item]);
    return item;
  }

  /// Adds a points plotter item with the given data.
  Points addPoints(
    final List<double> val,
  ) {
    final item = Points()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a lines plotter item with the given data.
  Lines addLines(
    final List<double> val,
  ) {
    final item = Lines()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a line strip plotter item with the given data.
  LineStrip addLineStrip(
    final List<double> val,
  ) {
    final item = LineStrip()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a polygon plotter item with the given data.
  Polygon addPolygon(
    final List<double> val,
  ) {
    final item = Polygon()..add(val);
    addItems([item]);
    return item;
  }

  /// Adds a rectangles plotter item with the given data.
  Rectangles addRects(
    final List<double> items,
  ) {
    final item = Rectangles()..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a circles plotter item with the given data.
  Circles addCircles(
    final List<double> items,
  ) {
    final item = Circles()..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a ellipses plotter item with the given data.
  Ellipses addEllipses(
    final List<double> items,
  ) {
    final item = Ellipses()..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a rectangle group plotter item with the given data.
  RectangleGroup addRectGroup(
    final double width,
    final double height,
    final List<double> items,
  ) {
    final item = RectangleGroup(width, height)..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a circle group plotter item with the given data.
  CircleGroup addCircleGroup(
    final double radius,
    final List<double> items,
  ) {
    final item = CircleGroup(radius)..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a ellipse group plotter item with the given data.
  EllipseGroup addEllipseGroup(
    final double width,
    final double height,
    final List<double> items,
  ) {
    final item = EllipseGroup(width, height)..add(items);
    addItems([item]);
    return item;
  }

  /// Adds a child group item with the given items.
  Group addGroup([
    final String label = "",
    final List<PlotterItem>? items,
    final bool enabled = true,
  ]) {
    final item = Group()
      ..label = label
      ..enabled = enabled;
    if (items != null) {
      item.addItems(items);
    }
    addItems([item]);
    return item;
  }

  /// Draws the group to the panel.
  @override
  void onDraw(
    final PlotterRenderer r,
  ) {
    if (enabled) {
      for (final item in _items) {
        item.draw(r);
      }
    }
  }

  /// Gets the bounds for the item.
  @override
  Bounds onGetBounds(
    final Transformer trans,
  ) {
    final b = BoundsImpl.empty();
    if (enabled) {
      for (final item in _items) {
        b.union(item.getBounds(trans));
      }
    }
    return b;
  }
}
