library three_dart.test.test024;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 024")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "Test of the Material Lighting shader with a simple spot light. ",
      "Use Ctrl plus the mouse to move the light."
    ])
    ..addControlBoxes(["shapes"])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final Group lightMover = Group()
    ..add(Constant.translate(0.0, 0.0, -2.5))
    ..add(UserRotator(input: td.userInput, ctrl: true));
  final Spot spot = Spot(
      mover: lightMover,
      color: Color3.white(),
      cutoff: 0.6,
      coneAngle: 0.5,
      attenuation0: 0.5,
      attenuation1: 0.05,
      attenuation2: 0.05);
  final MaterialLight tech = MaterialLight()
    ..lights.add(spot)
    ..emission.color = Color3.black()
    ..ambient.color = Color3.gray(0.0)
    ..diffuse.color = Color3.gray(0.7)
    ..specular.color = Color3.gray(0.3)
    ..specular.shininess = 100.0;
  final three_dart.Entity centerObj = three_dart.Entity()..shape = toroid();
  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (cube()..flip());
  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(Constant.rotateX(PI))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.1, 0.1, 0.1))..add(lightMover))
    ..shape = cylinder(bottomRadius: 0.0, sides: 40, capBottom: false)
    ..technique = MaterialLight.glow();
  td.scene = EntityPass()
    ..technique = tech
    ..children.add(centerObj)
    ..children.add(room)
    ..children.add(obj)
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
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
