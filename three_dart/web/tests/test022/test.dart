library three_dart.test.test022;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart' as shapes;
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 022")
    ..addLargeCanvas("testCanvas")
    ..add_par(["Test of the Material Lighting shader with a textured point light."])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final TextureCube texture = td.textureLoader.loadCubeFromPath("../resources/earthColor");

  final Group mover = Group()
    ..add(Constant.translate(0.0, 0.0, 2.0))
    ..add(Rotator(deltaYaw: 0.5, deltaPitch: 0.5, deltaRoll: 0.0));

  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.2, 0.2, 0.2))..add(mover))
    ..shape = shapes.sphere()
    ..technique = (MaterialLight()..emission.textureCube = texture);

  final Point objPoint =
      Point(mover: mover, texture: texture, attenuation0: 1.0, attenuation1: 0.15, attenuation2: 0.05);

  final MaterialLight tech = MaterialLight()
    ..lights.add(objPoint)
    ..ambient.color = Color3.gray(0.1)
    ..diffuse.color = Color3.gray(1.0)
    ..specular.color = Color3.gray(1.0)
    ..specular.shininess = 100.0;

  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (shapes.cube()..flip());

  final three_dart.Entity centerObj = three_dart.Entity()..shape = shapes.toroid();

  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));

  final EntityPass pass = EntityPass()
    ..technique = tech
    ..children.add(room)
    ..children.add(centerObj)
    ..children.add(obj)
    ..camera?.mover = camMover;
  td.scene = pass;

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
