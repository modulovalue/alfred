library three_dart.test.test035;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/events.dart';
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 035")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "A test of the bending a shape with the Material Light Shader. ",
      "Not all of the shapes have predefined bend values."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity obj = three_dart.Entity()..mover = Constant();
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(
        mover: Constant.vectorTowards(1.0, 1.0, -3.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity)
    ..bendMatrices.add(Matrix4.identity);
  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Mover mover1 = Group()
    ..add(Constant.translate(0.5, 0.0, 0.0))
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: 1.7))
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.5, deltaRoll: 0.0))
    ..add(Constant.rotateX(0.35))
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: -0.5, deltaRoll: 0.0))
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: -1.7))
    ..add(Constant.translate(-0.5, 0.0, 0.0));
  final Mover mover2 = Group()
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: -1.4))
    ..add(Constant.translate(0.5, 0.0, 0.0))
    ..add(Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: 1.4));
  final EntityPass pass = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = camMover
    ..onPreUpdate.add((EventArgs args) {
      final three_dart.RenderState state = (args as three_dart.StateEventArgs).state;
      final Matrix4 mat1 = mover1.update(state, null);
      final Matrix4 mat2 = mover2.update(state, null);
      tech.bendMatrices[0] = mat1;
      tech.bendMatrices[1] = mat2;
      tech.bendMatrices[2] = mat1;
      tech.bendMatrices[3] = mat2;
      tech.bendMatrices[4] = mat1;
      tech.bendMatrices[5] = mat2;
      tech.bendMatrices[6] = mat1;
      tech.bendMatrices[7] = mat2;
    });
  td.scene = pass;
  void setShape(Shape shape) {
    shape.calculateNormals();
    obj.shape = shape;
  }

  common.RadioGroup("shapes")
    ..add("Cuboid", () {
      setShape(cuboid(widthDiv: 30, heightDiv: 30));
    }, true)
    ..add("Cylinder", () {
      setShape(cylinder(div: 100, sides: 20));
    })
    ..add("Cone", () {
      setShape(cylinder(topRadius: 0.0, sides: 12, capTop: false, div: 30));
    })
    ..add("Sphere", () {
      setShape(sphere(widthDiv: 20, heightDiv: 20));
    })
    ..add("Toroid", () {
      setShape(toroid(minorRadius: 0.25, majorRadius: 1.5));
    })
    ..add("Knot", () {
      setShape(knot(minorRadius: 0.1));
    })
    ..add("Grid", () {
      setShape(grid());
    });
  common.show_fps(td);
}
