library three_dart.test.test019;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 019")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of the Material Lighting shader with an alpha texture. ",
      "There are no mapped reflections, this is actually transparent."
    ])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final three_dart.Entity obj = three_dart.Entity()..shape = cube();

  final FrontTarget target = FrontTarget()..clearColor = false;

  final TextureCube environment = td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg");
  final Texture2D color = td.textureLoader.load2DFromFile("../resources/AlphaWeave.png");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, -2.0, -3.0), color: Color3.white()))
    ..ambient.color = Color3(0.5, 0.5, 0.5)
    ..diffuse.color = Color3(0.6, 0.6, 0.6)
    ..ambient.texture2D = color
    ..diffuse.texture2D = color
    ..alpha.texture2D = color;

  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(input: td.userInput, ctrl: true))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));

  final Perspective camera = Perspective(mover: mover);

  final CoverPass skybox = CoverPass.skybox(environment)
    ..target = target
    ..camera = camera;

  final EntityPass pass = EntityPass()
    ..camera = camera
    ..technique = tech
    ..target = target
    ..children.add(obj);

  td.scene = Compound(passes: [skybox, pass]);

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
