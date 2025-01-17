library three_dart.test.test016;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/textures.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 016")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "A test of the Material Lighting shader with cube texturing, ",
      "bump mapping, and a color directional light."
    ])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final FrontTarget target = FrontTarget()..clearColor = false;
  final three_dart.Entity obj = three_dart.Entity()..shape = cube();
  final TextureCube environment = td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg");
  final TextureCube color = td.textureLoader.loadCubeFromPath("../resources/diceColor");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, -1.0, -3.0), color: Color3.white()))
    ..ambient.color = Color3(0.2, 0.2, 0.2)
    ..diffuse.color = Color3(0.7, 0.7, 0.7)
    ..specular.color = Color3(0.7, 0.7, 0.7)
    ..ambient.textureCube = color
    ..diffuse.textureCube = color
    ..specular.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceSpecular")
    ..specular.shininess = 10.0
    ..bump.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap")
    ..environment = environment
    ..reflection.color = Color3(0.3, 0.3, 0.3);
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
  (pass.target as FrontTarget?)!.clearColor = false;
  td.scene = Compound(passes: [skybox, pass]);
  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
