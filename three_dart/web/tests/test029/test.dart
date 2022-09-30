library three_dart.test.test029;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart' as lights;
import 'package:three_dart/math.dart' as math;
import 'package:three_dart/movers.dart' as movers;
import 'package:three_dart/scenes.dart' as scenes;
import 'package:three_dart/shapes.dart' as shapes;
import 'package:three_dart/techniques.dart' as techniques;
import 'package:three_dart/views.dart' as views;

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 029")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of bump distort pass. It renders the scene to a back buffer then ",
      "paints that back buffer texture to the front buffer with a distortion."
    ])
    ..addControlBoxes(["bumpMaps"])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final movers.Group mover = movers.Group()
    ..add(movers.UserRotator(input: td.userInput))
    ..add(movers.UserRoller(ctrl: true, input: td.userInput))
    ..add(movers.UserZoom(input: td.userInput))
    ..add(movers.Constant.translate(0.0, 0.0, 5.0));
  final views.Perspective userCamera = views.Perspective(mover: mover);
  final views.BackTarget colorTarget = views.BackTarget(autoResize: true, clearColor: false);
  final three_dart.Entity obj = three_dart.Entity()..shape = shapes.toroid();
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(lights.Directional(mover: movers.Constant.vectorTowards(0.0, -1.0, -1.0), color: math.Color3.white()))
    ..ambient.color = math.Color3(0.0, 0.0, 1.0)
    ..diffuse.color = math.Color3(0.0, 1.0, 0.0)
    ..specular.color = math.Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final scenes.CoverPass skybox =
      scenes.CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = colorTarget
        ..camera = userCamera;
  final scenes.EntityPass pass = scenes.EntityPass()
    ..camera = userCamera
    ..technique = tech
    ..target = colorTarget
    ..children.add(obj);
  final techniques.Distort distortTech = techniques.Distort()
    ..colorTexture = colorTarget.colorTexture
    ..bumpMatrix = math.Matrix4.scale(0.05, 0.05, 0.05);
  final scenes.CoverPass distortPass = scenes.CoverPass()..technique = distortTech;
  td.scene = scenes.Compound(passes: [skybox, pass, distortPass]);
  common.Texture2DGroup("bumpMaps", (String fileName) {
    distortTech.bumpTexture = td.textureLoader.load2DFromFile(fileName);
  })
    ..add("../resources/BumpMap1.png", true)
    ..add("../resources/BumpMap2.png")
    ..add("../resources/BumpMap3.png")
    ..add("../resources/BumpMap4.png")
    ..add("../resources/BumpMap5.png")
    ..add("../resources/ScrewBumpMap.png")
    ..add("../resources/CtrlPnlBumpMap.png");
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader for distort", "glsl", 0, distortTech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader for distort", "glsl", 0, distortTech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
