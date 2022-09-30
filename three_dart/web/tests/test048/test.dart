library three_dart.test.test048;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 048")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "WIP ([Issue #120|https://github.com/Grant-Nelson/three_dart/issues/120]) ",
      "Test of the Material Lighting shader with a bar light. ",
      "The bar light hasn't been finished yet so this test is more of a ",
      "testbed for it's development."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity centerObj = three_dart.Entity()
    ..mover = (Group()..add(UserRotator(input: td.userInput, ctrl: true)))
    ..shape = toroid();

  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (cube()..flip());

  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
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

  final Color3 clr = Color3(1.0, 0.0, 0.0);

  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()..add(Constant.scale(0.01, 0.01, 3.0)))
    ..shape = cylinder()
    ..technique = (MaterialLight()..emission.color = clr);

  final Group startMover = Group()..add(Constant.translate(0.0, 0.0, 2.5));

  final Group endMover = Group()..add(Constant.translate(0.0, 0.0, -2.5));

  final Bar point = Bar(
      startMover: startMover, endMover: endMover, color: clr, attenuation0: 1.0, attenuation1: 0.5, attenuation2: 0.15);

  tech.lights.add(point);
  pass.children.add(obj);

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
  common.show_fps(td);
}
