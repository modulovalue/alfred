import '../framework/mouse/impl/arrow_adder.dart';
import '../framework/mouse/impl/crosshairs.dart';
import '../framework/mouse/impl/mouse_coordinates.dart';
import '../framework/mouse/impl/point_adder.dart';
import '../framework/plotter_item/impl/group.dart';
import '../framework/plotter_item/impl/plotter.dart';

// TODO make this work with alfred.
Plotter makeExamplePlotter() {
  final plot = makePlotter();
  {
    final group = _createBox(plot, 0.0, 0.0, "Circle Group");
    group.addCircleGroup(1.5, [10, 20, 20, 40, 30, 60]);
    group.addCircleGroup(3.5, [30, 20, 40, 40, 50, 60])
      ..addColor(1.0, 1.0, 1.0)
      ..addFillColor(0.0, 0.0, 1.0);
  }
  {
    final group = _createBox(plot, 100.0, 0.0, "Circles");
    group.addCircles([10, 20, 1.0, 20, 40, 3.0, 30, 60, 5.0]);
    group.addCircles([30, 20, 2.5, 40, 40, 4.5, 50, 60, 6.5])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 200.0, 0.0, "Ellipse Group");
    group.addEllipseGroup(4.0, 2.0, [10, 20, 20, 40, 30, 60]);
    group.addEllipseGroup(4.0, 8.0, [30, 20, 40, 40, 50, 60])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 300.0, 0.0, "Ellipses");
    group.addEllipses([10, 20, 4.0, 2.0, 20, 40, 3.0, 3.0, 30, 60, 2.0, 4.0]);
    group.addEllipses([30, 20, 4.0, 8.0, 40, 40, 6.0, 6.0, 50, 60, 8.0, 4.0])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 0.0, -100.0, "Line Strip");
    group.addLineStrip([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]);
  }
  {
    final group = _createBox(plot, 100.0, -100.0, "Lines");
    group.addLines([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]);
  }
  {
    final group = _createBox(plot, 200.0, -100.0, "Directed Lines");
    group
        .addLines([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addDirected(true);
  }
  {
    final group = _createBox(plot, 300.0, -100.0, "Pointed Lines");
    group
        .addLines([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addPointSize(3.0);
  }
  {
    final group = _createBox(plot, 0.0, -200.0, "Points");
    group.addPoints([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addPointSize(
        3.0);
  }
  {
    final group = _createBox(plot, 0.0, -200.0, "Points");
    group.addPoints([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addPointSize(
      3.0,
    );
  }
  {
    final group = _createBox(plot, 100.0, -200.0, "Polygon");
    group.addPolygon([20.0, 20.0, 30.0, 45.0, 50.0, 55.0, 55.0, 45.5, 20.0, 60.0, 60.0, 20.0]).addFillColor(
      0.0,
      0.0,
      1.0,
      0.5,
    );
  }
  {
    final group = _createBox(plot, 200.0, -200.0, "Rectangle Group");
    group.addRectGroup(8.0, 4.0, [10, 20, 20, 40, 30, 60]);
    group.addRectGroup(8.0, 16.0, [30, 20, 40, 40, 50, 60])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 300.0, -200.0, "Rectangles");
    group.addRects([10, 20, 8.0, 4.0, 20, 40, 6.0, 6.0, 30, 60, 4.0, 8.0]);
    group.addRects([30, 20, 8.0, 16.0, 40, 40, 12.0, 12.0, 50, 60, 16.0, 8.0])
      ..addColor(0.0, 0.0, 1.0)
      ..addFillColor(0.0, 1.0, 0.0);
  }
  {
    final group = _createBox(plot, 0.0, -300.0, "Text");
    group.addText(10.0, 70.0, 4.0, "Small", true);
    group.addText(10.0, 60.0, 6.0, "Courier", true).addFont("Courier");
    group.addText(10.0, 50.0, 6.0, "Colored", true)
      ..addColor(1.0, 0.0, 0.0)
      ..addFillColor(0.0, 0.0, 1.0);
    group.addText(10.0, 30.0, 16.0, "Large", true)
      ..addColor(0.0, 0.0, 0.0)
      ..addFillColor(1.0, 1.0, 1.0, 0.5);
  }
  {
    final group = _createBox(plot, 100.0, -300.0, "Mouse Examples");
    group.addText(10.0, 70.0, 6.0, "Hold shift while clicking", true).addFillColor(0.0, 0.0, 0.0);
    group.addText(20.0, 60.0, 6.0, "to add red points.", true).addFillColor(0.0, 0.0, 0.0);
    group.addText(10.0, 40.0, 6.0, "Hold ctrl while clicking", true).addFillColor(0.0, 0.0, 0.0);
    group.addText(20.0, 30.0, 6.0, "to add red arrows.", true).addFillColor(0.0, 0.0, 0.0);
  }
  return plot
    ..updateDataBounds()
    ..focusOnData()
    ..mouseHandles.add(makePointAdder(plot))
    ..mouseHandles.add(makeArrowAdder(plot))
    ..mouseHandles.add(makeMouseCoords(plot))
    ..mouseHandles.add(makeMouseCrosshairs(plot));
}

Group _createBox(
  final Plotter plot,
  final double x,
  final double y,
  final String title,
) =>
    plot.addGroup()
      ..addOffset(x, y)
      ..addRects([0, 10, 90, 80])
      ..addRects([0, 90, 90, 10]).addFillColor(0.0, 0.0, 0.0, 0.75)
      ..addText(5, 92, 8, title, true)
      ..addColor(0.7, 0.7, 0.7)
      ..addFillColor(1.0, 1.0, 1.0);
