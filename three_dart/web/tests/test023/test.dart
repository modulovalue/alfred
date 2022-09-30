library three_dart.test.test023;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 023")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of the Material Lighting shader with a textured directional ",
      "light. Use Ctrl plus the mouse to move the light."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final UserRotator viewRotator = UserRotator(input: td.userInput);
  final UserRotator objRotator = UserRotator(input: td.userInput, ctrl: true);

  final Directional txtDir = Directional(
      mover: objRotator,
      color: Color3(0.6, 0.9, 1.0),
      texture: td.textureLoader.load2DFromFile("../resources/Test.png", wrapEdges: true));

  final MaterialLight tech = MaterialLight()
    ..lights.add(txtDir)
    ..emission.color = Color3.black()
    ..ambient.color = Color3.gray(0.01)
    ..diffuse.color = Color3.gray(0.7)
    ..specular.color = Color3.gray(0.3)
    ..specular.shininess = 100.0;

  final three_dart.Entity centerObj = three_dart.Entity()..shape = toroid();

  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (cube()..flip());

  final Group camMover = Group()
    ..add(viewRotator)
    ..add(Constant.rotateX(PI))
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
  common.show_fps(td);
}
