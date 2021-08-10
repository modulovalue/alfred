import 'package:three_dart/core/core.dart';
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
  common.ShellPage("Test 033")
    ..addLargeCanvas("testCanvas")
    ..addPar(["Test of a Stereoscopic scene."])
    ..addPar(["«[Back to Tests|../]"]);

  final ThreeDart td = ThreeDart.fromId("testCanvas");

  final Entity cubeEntity = Entity(shape: cube());
  final Entity shapeEntity = Entity();
  for (double x = -1.6; x <= 1.7; x += 0.8) {
    for (double y = -1.6; y <= 1.7; y += 0.8) {
      for (double z = -1.6; z <= 1.7; z += 0.8) {
        final Matrix4 mat = Matrix4.translate(x, y, z) * Matrix4.scale(0.2, 0.2, 0.2);
        final Entity entity = Entity()
          ..mover = Constant(mat)
          ..children.add(cubeEntity);
        shapeEntity.children.add(entity);
      }
    }
  }

  final TextureCube color = td.textureLoader.loadCubeFromPath("../resources/diceColor");
  final MaterialLight colorTech = MaterialLight()
    ..lights.add(
        Directional(mover: Constant.vectorTowards(-1.0, -1.0, -1.0), color: Color3(1.0, 0.9, 0.9)))
    ..lights.add(
        Directional(mover: Constant.vectorTowards(1.0, 1.0, 2.0), color: Color3(0.2, 0.2, 0.35)))
    ..ambient.color = Color3(0.2, 0.2, 0.2)
    ..ambient.textureCube = color
    ..diffuse.color = Color3(0.8, 0.8, 0.8)
    ..diffuse.textureCube = color
    ..specular.color = Color3(0.7, 0.7, 0.7)
    ..specular.shininess = 10.0
    ..bump.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap");

  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 6.0));

  final FrontTarget target = FrontTarget()..clearColor = false;

  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"));

  final EntityPass pass = EntityPass()
    ..technique = colorTech
    ..children.add(shapeEntity);

  td.scene = Stereoscopic(mover: mover, passes: [skybox, pass], target: target);

  common.showFPS(td);
}
