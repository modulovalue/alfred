library three_dart.test.test025;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart' as lights;
import 'package:three_dart/math.dart' as math;
import 'package:three_dart/movers.dart' as movers;
import 'package:three_dart/scenes.dart' as scenes;
import 'package:three_dart/shapes.dart' as shapes;
import 'package:three_dart/techniques.dart' as techniques;

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 025")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of the Material Lighting shader with a textured spot light. ",
      "Use Ctrl plus the mouse to move the light."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final movers.Group lightMover = movers.Group()
    ..add(movers.Constant.translate(0.0, 0.0, -2.5))
    ..add(movers.UserRotator(input: td.userInput, ctrl: true));

  final lights.Spot spot = lights.Spot(
      mover: lightMover,
      color: math.Color3.white(),
      enableCutOff: true,
      fov: 0.5,
      ratio: 1.0,
      attenuation0: 0.5,
      attenuation1: 0.05,
      attenuation2: 0.05,
      texture: td.textureLoader.load2DFromFile("../resources/Test.png"));

  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(spot)
    ..ambient.color = math.Color3.gray(0.05)
    ..diffuse.color = math.Color3.gray(0.7)
    ..specular.color = math.Color3.gray(0.3)
    ..specular.shininess = 100.0;

  final three_dart.Entity centerObj = three_dart.Entity()..shape = shapes.toroid();

  final three_dart.Entity room = three_dart.Entity()
    ..mover = movers.Constant.scale(3.0, 3.0, 3.0)
    ..shape = (shapes.cube()..flip());

  final movers.Group camMover = movers.Group()
    ..add(movers.UserRotator(input: td.userInput))
    ..add(movers.Constant.rotateX(math.PI))
    ..add(movers.Constant.translate(0.0, 0.0, 5.0));

  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (movers.Group()..add(movers.Constant.scale(0.1, 0.1, 0.1))..add(lightMover))
    ..shape = shapes.cylinder(bottomRadius: 0.0, sides: 40, capBottom: false)
    ..technique = techniques.MaterialLight.glow();

  td.scene = scenes.EntityPass()
    ..technique = tech
    ..children.add(centerObj)
    ..children.add(room)
    ..children.add(obj)
    ..camera?.mover = camMover;

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

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
