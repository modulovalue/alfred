import 'dart:math';

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/events.dart';
import 'package:three_dart/input.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart' as shapes;
import 'package:three_dart/techniques.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Hypersphere")
    ..add_par([
      "This is a simple example to help demonstrate why a hypersphere takes up ",
      "so little space of the hypercube."
    ])
    ..add_header(3, "2D: circle and square")
    ..add_par([
      "Imagine taking slices out of a circle inscribed in a square. Each slice is ",
      "two lines, one from the circle and one from the square. When the slices ",
      "are near the top, the line caused by the circle is small compared to the square. ",
      "The corners of the square aren't covered by the circle."
    ])
    ..addLargeCanvas("target2D")
    ..add_par(["_Click and drag to move the location of the slice._"])
    ..add_header(3, "3D: sphere and cube")
    ..add_par([
      "Now imagine taking slices out of a sphere inscribed in a cube. Each slice is ",
      "a circle inside a square. When the slice is in the middle, the circle touches ",
      "the sides of the square. When the slice is near a side, the circle is almost a ",
      "point but the square is still the same size. That is a lot of extra space for ",
      "for the square not used by the circle."
    ])
    ..addLargeCanvas("target3D")
    ..add_par(["_Click and drag to move the location of the slice._"])
    ..add_header(3, "4D: hypersphere and hypercube")
    ..add_par([
      "Now imagine taking a slice out of a hypersphere inscribed in a hypercube. ",
      "Each slice is a sphere and a cube (as shown in the graphics below). ",
      "When the slice is near the edges, the sphere is a small point in the middle ",
      "of a cube. As the slice moves down the sphere gets bigger until it touches all ",
      "the sides of the cube, then it shrinks again. Once again, that's a lot of ",
      "space in the cube not filled by the sphere."
    ])
    ..addLargeCanvas("target4D")
    ..add_par([
      "_The shape on the left is an artistic representation of a 4D hypercube._ ",
      "_Click and drag on the left to move the location of the slice._",
      "_Click and drag on the right to rotate the resulting 3D slice._"
    ])
    ..add_par([
      "With each new dimension the hypersphere is small near the edges and only touching ",
      "the sides of the hypersphere in the very middle."
    ])
    ..add_par(["«[Back to Examples|../]"]);
  startup2D("target2D");
  startup3D("target3D");
  startup4D("target4D");
}

void startup2D(String targetName) {
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId(targetName);
  final MaterialLight squareTech = MaterialLight()..emission.color = Color3(0.4, 0.6, 0.8);
  final MaterialLight sliceTech = MaterialLight()
    ..emission.color = Color3(0.8, 0.6, 0.4)
    ..alpha.value = 0.3;
  final MaterialLight projTech = MaterialLight()
    ..emission.color = Color3(0.4, 0.6, 0.8)
    ..alpha.value = 0.3;
  final Constant sliceMover = Constant();
  final Constant sphereScalar = Constant();
  final three_dart.Entity squareCircle = three_dart.Entity()
    ..technique = squareTech
    ..shape = (shapes.Shape()..merge(shapes.square(frameOnly: true))..merge(shapes.disk(sides: 36, frameOnly: true)));
  final three_dart.Entity slice = three_dart.Entity()
    ..technique = sliceTech
    ..shape = shapes.line()
    ..mover = (Group()
      ..add(Constant.scale(1.3, 1.3, 1.3))
      ..add(Constant.rotateX(-PI_2))
      ..add(sliceMover));
  final three_dart.Entity squareLine = three_dart.Entity()
    ..shape = shapes.line()
    ..mover = (Group()..add(Constant.translate(0.0, 0.0, 0.1)));
  final three_dart.Entity circleLine = three_dart.Entity()
    ..shape = shapes.line()
    ..mover = (Group()..add(sphereScalar));
  // Create left pass
  final EntityPass slicePass = EntityPass()
    ..target = FrontTarget(clearColor: false)
    ..camera = (Perspective()
      ..premover = Constant.translate(-0.5, 0.0, 0.0)
      ..mover = Constant.translate(0.0, 0.0, 5.0))
    ..children.add(slice)
    ..children.add(squareCircle);
  // Create right pass
  final EntityPass projPass = EntityPass()
    ..camera = (Perspective()
      ..premover = Constant.translate(0.5, 0.0, 0.0)
      ..mover = Constant.translate(0.0, 0.0, 5.0))
    ..technique = projTech
    ..children.add(circleLine)
    ..children.add(squareLine);
  // Add the left side slider control.
  double wOffset = 0.5;
  bool startInside = false;
  td.userInput.mouse.down.add((_) {
    startInside = true;
  });
  td.userInput.mouse.up.add((_) {
    startInside = false;
  });
  td.userInput.mouse.move.add((EventArgs e) {
    final MouseEventArgs ms = e as MouseEventArgs;
    if (!startInside) {
      return;
    }
    wOffset += ms.adjustedDelta.dy;
    wOffset = clampVal(wOffset, -0.1, 1.1);
    sliceMover.matrix = Matrix4.translate(0.0, 1.0 - 2.0 * wOffset, 0.0);
    if ((wOffset <= 0.0) || (wOffset >= 1.0)) {
      squareLine.enabled = false;
      circleLine.enabled = false;
    } else {
      final double r = sin(wOffset * PI);
      sphereScalar.matrix = Matrix4.scale(r, r, r);
      squareLine.enabled = true;
      circleLine.enabled = true;
    }
  });
  // Add the two parts of the scene to the output.
  td.scene = Compound(passes: [projPass, slicePass]);
}

void startup3D(String targetName) {
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId(targetName);
  final Inspection cubeTech = Inspection()
    ..showWireFrame = true
    ..showFilled = true
    ..diffuse1 = Color4(0.2, 0.3, 0.4, 0.2)
    ..ambient1 = Color4(0.1, 0.2, 0.3, 0.2);
  final MaterialLight sliceTech = MaterialLight()
    ..emission.color = Color3(0.8, 0.6, 0.4)
    ..alpha.value = 0.3;
  final MaterialLight projTech = MaterialLight()..emission.color = Color3(0.4, 0.6, 0.8);
  final Constant sliceMover = Constant();
  final Constant sphereScalar = Constant();
  final Group sliceRotation = Group()..add(Constant.rotateX(0.4))..add(Constant.rotateY(0.4));
  final three_dart.Entity cubeSphere = three_dart.Entity()
    ..technique = cubeTech
    ..shape = (shapes.Shape()..merge(shapes.cube())..merge(shapes.isosphere(2)))
    ..mover = sliceRotation;
  final three_dart.Entity slice = three_dart.Entity()
    ..technique = sliceTech
    ..shape = shapes.square()
    ..mover = (Group()
      ..add(Constant.scale(1.3, 1.3, 1.3))
      ..add(Constant.rotateX(-PI_2))
      ..add(sliceMover)
      ..add(sliceRotation));
  final three_dart.Entity square = three_dart.Entity()..shape = shapes.square(frameOnly: true);
  final three_dart.Entity circle = three_dart.Entity()
    ..shape = shapes.disk(sides: 36, frameOnly: true)
    ..mover = (Group()..add(sphereScalar));
  // Create left pass
  final EntityPass slicePass = EntityPass()
    ..target = FrontTarget(clearColor: false)
    ..camera = (Perspective()
      ..premover = Constant.translate(-0.5, 0.0, 0.0)
      ..mover = Constant.translate(0.0, 0.0, 5.0))
    ..children.add(slice)
    ..children.add(cubeSphere);
  // Create right pass
  final EntityPass projPass = EntityPass()
    ..camera = (Perspective()
      ..premover = Constant.translate(0.5, 0.0, 0.0)
      ..mover = Constant.translate(0.0, 0.0, 5.0))
    ..technique = projTech
    ..children.add(circle)
    ..children.add(square);
  // Add the left side slider control.
  double wOffset = 0.5;
  bool startInside = false;
  td.userInput.mouse.down.add((_) {
    startInside = true;
  });
  td.userInput.mouse.up.add((_) {
    startInside = false;
  });
  td.userInput.mouse.move.add((EventArgs e) {
    final MouseEventArgs ms = e as MouseEventArgs;
    if (!startInside) {
      return;
    }
    wOffset += ms.adjustedDelta.dy;
    wOffset = clampVal(wOffset, -0.1, 1.1);
    sliceMover.matrix = Matrix4.translate(0.0, 1.0 - 2.0 * wOffset, 0.0);
    if ((wOffset <= 0.0) || (wOffset >= 1.0)) {
      square.enabled = false;
      circle.enabled = false;
    } else {
      final r = sin(wOffset * PI);
      sphereScalar.matrix = Matrix4.scale(r, r, r);
      square.enabled = true;
      circle.enabled = true;
    }
  });
  // Add the two parts of the scene to the output.
  td.scene = Compound(passes: [projPass, slicePass]);
}

void startup4D(String targetName) {
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId(targetName);
  final MaterialLight hypercubeTech = MaterialLight()..emission.color = Color3(0.4, 0.6, 0.8);
  final MaterialLight sliceTech = MaterialLight()
    ..emission.color = Color3(0.8, 0.6, 0.4)
    ..alpha.value = 0.3;
  final Inspection projTech = Inspection()
    ..showWireFrame = true
    ..showFilled = true
    ..diffuse1 = Color4(0.2, 0.3, 0.4, 0.2)
    ..ambient1 = Color4(0.1, 0.2, 0.3, 0.2);
  final Constant sliceMover = Constant();
  final Constant sphereScalar = Constant();
  final Group sliceRotation = Group()..add(Constant.rotateX(0.4))..add(Constant.rotateY(0.4));
  final Group projUserMover = Group();
  final shapes.Shape shape = shapes.Shape();
  final shapes.Vertex v1 = shape.vertices.addNewLoc(1.0, -1.0, 1.0);
  final shapes.Vertex v2 = shape.vertices.addNewLoc(1.0, 1.0, 1.0);
  final shapes.Vertex v3 = shape.vertices.addNewLoc(1.0, 1.0, -1.0);
  final shapes.Vertex v4 = shape.vertices.addNewLoc(1.0, -1.0, -1.0);
  final shapes.Vertex v5 = shape.vertices.addNewLoc(-1.0, -1.0, 1.0);
  final shapes.Vertex v6 = shape.vertices.addNewLoc(-1.0, 1.0, 1.0);
  final shapes.Vertex v7 = shape.vertices.addNewLoc(-1.0, 1.0, -1.0);
  final shapes.Vertex v8 = shape.vertices.addNewLoc(-1.0, -1.0, -1.0);
  final shapes.Vertex v9 = shape.vertices.addNewLoc(0.5, -0.5, 0.5);
  final shapes.Vertex v10 = shape.vertices.addNewLoc(0.5, 0.5, 0.5);
  final shapes.Vertex v11 = shape.vertices.addNewLoc(0.5, 0.5, -0.5);
  final shapes.Vertex v12 = shape.vertices.addNewLoc(0.5, -0.5, -0.5);
  final shapes.Vertex v13 = shape.vertices.addNewLoc(-0.5, -0.5, 0.5);
  final shapes.Vertex v14 = shape.vertices.addNewLoc(-0.5, 0.5, 0.5);
  final shapes.Vertex v15 = shape.vertices.addNewLoc(-0.5, 0.5, -0.5);
  final shapes.Vertex v16 = shape.vertices.addNewLoc(-0.5, -0.5, -0.5);
  shape.lines.addLines([
    v1,
    v2,
    v2,
    v3,
    v3,
    v4,
    v4,
    v1,
    v5,
    v6,
    v6,
    v7,
    v7,
    v8,
    v8,
    v5,
    v9,
    v10,
    v10,
    v11,
    v11,
    v12,
    v12,
    v9,
    v13,
    v14,
    v14,
    v15,
    v15,
    v16,
    v16,
    v13,
    v1,
    v5,
    v2,
    v6,
    v3,
    v7,
    v4,
    v8,
    v9,
    v13,
    v10,
    v14,
    v11,
    v15,
    v12,
    v16,
    v1,
    v9,
    v2,
    v10,
    v3,
    v11,
    v4,
    v12,
    v5,
    v13,
    v6,
    v14,
    v7,
    v15,
    v8,
    v16
  ]);
  final three_dart.Entity hypercube = three_dart.Entity()
    ..technique = hypercubeTech
    ..shape = shape
    ..mover = sliceRotation;
  final three_dart.Entity slice = three_dart.Entity()
    ..technique = sliceTech
    ..shape = shapes.square()
    ..mover = (Group()
      ..add(Constant.scale(1.1, 1.1, 1.1))
      ..add(Constant.rotateX(-PI_2))
      ..add(sliceMover)
      ..add(sliceRotation));
  final three_dart.Entity cube = three_dart.Entity()
    ..shape = shapes.cube()
    ..mover = projUserMover;
  final three_dart.Entity sphere = three_dart.Entity()
    ..shape = shapes.isosphere(2)
    ..mover = (Group()..add(sphereScalar)..add(projUserMover));
  // Create left pass
  final EntityPass slicePass = EntityPass()
    ..target = FrontTarget(clearColor: false)
    ..camera = (Perspective()
      ..premover = Constant.translate(-0.5, 0.0, 0.0)
      ..mover = Constant.translate(0.0, 0.0, 5.0))
    ..children.add(hypercube)
    ..children.add(slice);
  // Create right pass
  final EntityPass projPass = EntityPass()
    ..camera = (Perspective()
      ..premover = Constant.translate(0.5, 0.0, 0.0)
      ..mover = Constant.translate(0.0, 0.0, 5.0))
    ..technique = projTech
    ..children.add(sphere)
    ..children.add(cube);
  // Add the left side slider control.
  double wOffset = 0.5;
  bool startInside = false;
  td.userInput.mouse.down.add((_) {
    startInside = true;
  });
  td.userInput.mouse.up.add((_) {
    startInside = false;
  });
  td.userInput.mouse.move.add((EventArgs e) {
    final MouseEventArgs ms = e as MouseEventArgs;
    if (!startInside) return;
    // If on the right size, don't move the slider.
    if (ms.adjustedPoint.x > 0.0) return;
    wOffset += ms.adjustedDelta.dy;
    wOffset = clampVal(wOffset, -0.1, 1.1);
    sliceMover.matrix = Matrix4.translate(0.0, 1.0 - 2.0 * wOffset, 0.0);
    if ((wOffset <= 0.0) || (wOffset >= 1.0)) {
      cube.enabled = false;
      sphere.enabled = false;
    } else {
      final double r = sin(wOffset * PI);
      sphereScalar.matrix = Matrix4.scale(r, r, r);
      cube.enabled = true;
      sphere.enabled = true;
    }
    // On the left side so don't let mouse move continue to rotator.
    ms.propagate = false;
  });
  // Add the right side user rotator after the left side.
  projUserMover
    ..add(UserRotator(input: td.userInput, invertY: true))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput));
  // Add the two parts of the scene to the output.
  td.scene = Compound(passes: [projPass, slicePass]);
}
