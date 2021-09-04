library three_dart.test.test021;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart' as shapes;
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 021")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "Test of the Material Lighting shader with multiple moving point lights. ",
      "Emissive spheres are added at the lights sources."
    ])
    ..addControlBoxes(["shapes"])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity centerObj = three_dart.Entity()
    ..mover = Constant.identity()
    ..shape = shapes.toroid();
  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (shapes.cube()..flip());
  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final MaterialLight tech = MaterialLight()
    ..ambient.color = Color3.gray(0.15)
    ..diffuse.color = Color3.gray(0.4)
    ..specular.color = Color3.gray(0.3)
    ..specular.shininess = 100.0;
  final EntityPass pass = EntityPass()
    ..technique = tech
    ..children.add(room)
    ..children.add(centerObj)
    ..camera?.mover = camMover;
  td.scene = pass;
  addLightBall(tech, pass, 1.0, 0.0, 0.0, 0.3, 0.0, 0.0);
  addLightBall(tech, pass, 0.0, 1.0, 0.0, 0.0, 0.4, 0.0);
  addLightBall(tech, pass, 0.0, 0.0, 1.0, 0.5, 0.5, 0.0);
  common.RadioGroup("shapes")
    ..add("Cube", () {
      centerObj.shape = shapes.cube();
    })
    ..add("Cylinder", () {
      centerObj.shape = shapes.cylinder(sides: 40);
    })
    ..add("Cone", () {
      centerObj.shape = shapes.cylinder(topRadius: 0.0, sides: 40, capTop: false);
    })
    ..add("Sphere", () {
      centerObj.shape = shapes.sphere(widthDiv: 6, heightDiv: 6);
    })
    ..add("Toroid", () {
      centerObj.shape = shapes.toroid();
    }, true)
    ..add("Knot", () {
      centerObj.shape = shapes.knot();
    });
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}

void addLightBall(
  MaterialLight tech,
  EntityPass pass,
  double r,
  double g,
  double b,
  double yaw,
  double pitch,
  double roll,
) {
  final Color3 clr = Color3(r, g, b);
  final mover = Group()
    ..add(Constant.translate(0.0, 0.0, 2.0))
    ..add(Rotator(deltaYaw: yaw, deltaPitch: pitch, deltaRoll: roll));
  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.1, 0.1, 0.1))..add(mover))
    ..shape = shapes.sphere()
    ..technique = (MaterialLight()..emission.color = clr);
  final Point point = Point(mover: mover, color: clr, attenuation0: 1.0, attenuation1: 0.5, attenuation2: 0.15);
  tech.lights.add(point);
  pass.children.add(obj);
}
