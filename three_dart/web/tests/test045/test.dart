library three_dart.test.test045;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 045")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "WIP ([Issue #104|https://github.com/Grant-Nelson/three_dart/issues/104]) ",
      "Test of shadow projection with a spot light."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final BackTarget shadow = BackTarget();
  final Group lightMover = Group()
    ..add(Constant.translate(0.0, 0.0, -4.0))
    //..add(new Movers.Rotator())
    ..add(UserRotator(input: td.userInput, ctrl: true));
  final Spot spot = Spot(
    mover: lightMover,
    shadow: shadow.colorTexture,
    texture: td.textureLoader.load2DFromFile("../resources/Test.png"),
    color: Color3.white(),
    enableCutOff: false,
    fov: 0.5,
    ratio: 1.0,
    attenuation0: 0.0,
    attenuation1: 0.1,
    attenuation2: 0.0,
  );
  final MaterialLight tech = MaterialLight()
    ..lights.add(spot)
    ..ambient.color = Color3.gray(0.1)
    ..diffuse.color = Color3.gray(0.7)
    ..specular.color = Color3.gray(0.3)
    ..specular.shininess = 100.0;
  final three_dart.Entity centerObj = three_dart.Entity()..shape = toroid();
  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(5.0, 5.0, 5.0)
    ..shape = (cube()..flip());
  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(Constant.rotateX(PI))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final three_dart.Entity lightSource = three_dart.Entity()
    ..mover = (Group()
      ..add(Constant.scale(0.1, 0.1, 0.1))
      ..add(lightMover))
    ..shape = cylinder(bottomRadius: 0.0, sides: 40, capBottom: false)
    ..technique = MaterialLight.glow();
  final EntityPass colorPass = EntityPass()
    ..technique = tech
    ..children.add(centerObj)
    ..children.add(room)
    ..children.add(lightSource)
    ..camera?.mover = camMover;
  // TODO: Determine how to setup camera without the hardcoded constants.
  final Perspective shadowCam = Perspective(
      mover: (Group()
        ..add(Constant.scale(-1.0, 1.0, -1.0))
        ..add(Invert(lightMover))
        ..add(Constant.rotateZ(PI))
        ..add(Constant.translate(0.0, 0.0, 2.0))),
      fov: 0.5);
  final EntityPass shadowPass = EntityPass()
    ..target = shadow
    ..technique = Depth(start: 1.0, stop: 20.0, focus: true)
    ..children.add(centerObj)
    ..children.add(room)
    ..camera = shadowCam;
  td.scene = Compound(passes: [shadowPass, colorPass]);
  common.RadioGroup("shapes")
    ..add("Cube", () {
      centerObj.shape = cube();
    })
    ..add("Cylinder", () {
      centerObj.shape = cylinder(sides: 40);
    })
    ..add("Bar", () {
      centerObj.shape = cylinder(topRadius: 0.2, bottomRadius: 0.2, sides: 40);
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
  common.show_fps(td);
}
