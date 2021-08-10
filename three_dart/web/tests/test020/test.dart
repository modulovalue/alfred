library three_dart.test.test020;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 020")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of the Material Lighting shader with multiple moving directional lights."])
    ..addControlBoxes(["shapes"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final Directional redDir = Directional(
      mover: Rotator(deltaYaw: 0.3, deltaPitch: 0.0, deltaRoll: 0.0), color: Color3(1.0, 0.0, 0.0));

  final Directional greenDir = Directional(
      mover: Rotator(deltaYaw: 0.0, deltaPitch: 0.4, deltaRoll: 0.0), color: Color3(0.0, 1.0, 0.0));

  final Directional blueDir = Directional(
      mover: Rotator(deltaYaw: 0.5, deltaPitch: 0.5, deltaRoll: 0.0), color: Color3(0.0, 0.0, 1.0));

  final MaterialLight tech = MaterialLight()
    ..lights.add(redDir)
    ..lights.add(greenDir)
    ..lights.add(blueDir)
    ..emission.color = Color3.black()
    ..ambient.color = Color3.gray(0.1)
    ..diffuse.color = Color3.gray(0.7)
    ..specular.color = Color3.gray(0.3)
    ..specular.shininess = 100.0;

  final three_dart.Entity centerObj = three_dart.Entity()..shape = toroid();

  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (cube()..flip());

  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));

  td.scene = EntityPass()
    ..technique = tech
    ..children.add(centerObj)
    ..children.add(room)
    ..camera?.mover = camMover;

  common.RadioGroup("shapes")
    ..add("Cube", () {
      centerObj.shape = cube();
    })
    ..add("Cylinder", () {
      centerObj.shape = cylinder(sides: 40);
    })
    ..add("Cone", () {
      centerObj.shape = cylinder(topRadius: 0.0, sides: 40, capTop: false);
    })
    ..add("Sphere", () {
      centerObj.shape = sphere(widthDiv: 6, heightDiv: 6);
    })
    ..add("Toroid", () {
      centerObj.shape = toroid();
    }, true)
    ..add("Knot", () {
      centerObj.shape = knot();
    });

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
