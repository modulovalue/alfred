library three_dart.test.test018;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 018")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of the Material Lighting shader where a diffuse texture and ",
      "inverse diffuse texture are used. Grass is only shown in the dark. ",
      "Dirt is shown where the directional light is shining."
    ])
    ..addControlBoxes(["shapes"])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity obj = three_dart.Entity()
    ..shape = sphere()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  final Texture2D diffuse = td.textureLoader.load2DFromFile("../resources/Dirt.png");
  final Texture2D invDiffuse = td.textureLoader.load2DFromFile("../resources/Grass.png");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0), color: Color3.white()))
    ..diffuse.texture2D = diffuse
    ..invDiffuse.texture2D = invDiffuse;
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
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
