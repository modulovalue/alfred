library three_dart.test.test011;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 011")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "A test of the Material Lighting shader with cube textures and ",
      "a directional light. The cube textures are for ambient, diffuse, ",
      "and specular."
    ])
    ..addControlBoxes(["shapes"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity obj = three_dart.Entity()
    ..shape = sphere()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  final TextureCube color = td.textureLoader.loadCubeFromPath("../resources/earthColor");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.2, 0.2, 0.2)
    ..diffuse.color = Color3(0.8, 0.8, 0.8)
    ..ambient.textureCube = color
    ..diffuse.textureCube = color
    ..specular.textureCube = td.textureLoader.loadCubeFromPath("../resources/earthSpecular")
    ..specular.shininess = 10.0;
  td.scene = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 3.0);
  common.RadioGroup("shapes")
    ..add("Cube", () {
      obj.shape = cube();
    })
    ..add("Cuboid", () {
      obj.shape = cuboid();
    })
    ..add("Cylinder", () {
      obj.shape = cylinder(sides: 40);
    })
    ..add("Cone", () {
      obj.shape = cylinder(topRadius: 0.0, sides: 40, capTop: false);
    })
    ..add("LatLonSphere", () {
      obj.shape = latLonSphere(10, 20);
    })
    ..add("IsoSphere", () {
      obj.shape = isosphere(2);
    })
    ..add("Sphere", () {
      obj.shape = sphere(widthDiv: 6, heightDiv: 6);
    }, true)
    ..add("Toroid", () {
      obj.shape = toroid();
    })
    ..add("Knot", () {
      obj.shape = knot();
    });
  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
