library three_dart.test.test026;

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
  final common.ShellPage page = common.ShellPage("Test 026")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of the Material Lighting shader with a textured directional light. ",
      "The texturing of the directional light is being modified with a matrix. ",
      "The texture matrix is updated using the pre-update methods. ",
      "Use Ctrl plus the mouse to move the center object."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final Directional dir1 = Directional()..mover = Constant.vectorTowards(0.3, 0.4, 1.0);
  final Directional dir2 = Directional()
    ..mover = Constant.vectorTowards(-0.3, -0.4, -1.0)
    ..color = Color3(0.125, 0.125, 0.125);
  final MaterialLight tech = MaterialLight()
    ..lights.add(dir1)
    ..lights.add(dir2)
    ..emission.color = Color3.black()
    ..ambient.color = Color3.gray(0.1)
    ..diffuse.color = Color3.gray(0.8)
    ..specular.color = Color3.gray(0.2)
    ..specular.shininess = 100.0
    ..diffuse.texture2D = td.textureLoader.load2DFromFile("../resources/Test.png", wrapEdges: true);
  final three_dart.Entity centerObj = three_dart.Entity()
    ..mover = UserRotator(input: td.userInput, ctrl: true)
    ..shape = toroid();
  final three_dart.Entity room = three_dart.Entity()
    ..mover = Constant.scale(3.0, 3.0, 3.0)
    ..shape = (cube()..flip());
  final Group camMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(Constant.rotateX(PI))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Rotator colorMover = Rotator(deltaYaw: 0.3, deltaPitch: 0.5, deltaRoll: 0.7);
  final Rotator txtMover = Rotator(deltaYaw: 0.0, deltaPitch: 0.0, deltaRoll: 0.1);
  td.scene = EntityPass()
    ..technique = tech
    ..children.add(centerObj)
    ..children.add(room)
    ..camera?.mover = camMover
    ..onPreUpdate.add((EventArgs args) {
      final three_dart.RenderState state = (args as three_dart.StateEventArgs).state;
      tech.colorMatrix = colorMover.update(state, null);
      tech.texture2DMatrix = Matrix3.fromMatrix4(txtMover.update(state, null));
    });
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
  common.show_fps(td);
}
