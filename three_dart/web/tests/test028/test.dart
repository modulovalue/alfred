library three_dart.test.test028;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shaders/shaders.dart' as shaders;
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';
import 'package:three_dart/views/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 028")
    ..addLargeCanvas("testCanvas")
    ..addPar(
        ["Test of a Gaussian blur cover pass. ", "Notice the depth of field causing things further away to be blurry."])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final Group secondMover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: secondMover);

  final three_dart.Entity cubeEntity = three_dart.Entity(shape: cube());
  final three_dart.Entity group = three_dart.Entity();
  for (double x = -1.6; x <= 1.7; x += 0.8) {
    for (double y = -1.6; y <= 1.7; y += 0.8) {
      for (double z = -1.6; z <= 1.7; z += 0.8) {
        final Matrix4 mat = Matrix4.translate(x, y, z) * Matrix4.scale(0.2, 0.2, 0.2);
        final three_dart.Entity entity = three_dart.Entity()
          ..mover = Constant(mat)
          ..children.add(cubeEntity);
        group.children.add(entity);
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

  final BackTarget colorTarget = BackTarget(autoResize: true, clearColor: false);

  final scenes.CoverPass skybox =
      scenes.CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..camera = userCamera
        ..target = colorTarget;

  final scenes.EntityPass colorPass = scenes.EntityPass()
    ..camera = userCamera
    ..target = colorTarget
    ..technique = colorTech
    ..children.add(group);

  final BackTarget depthTarget = BackTarget(autoResize: true, autoResizeScalarX: 0.5, autoResizeScalarY: 0.5);
  final scenes.EntityPass depthPass = scenes.EntityPass()
    ..camera = userCamera
    ..target = depthTarget
    ..technique = Depth(start: 3.5, stop: 5.5)
    ..children.add(group);

  final scenes.GaussianBlur blurPass = scenes.GaussianBlur(
      blurAdj: Vector4(-1.0, 0.0, 0.0, 1.0),
      colorTxt: colorTarget.colorTexture,
      blurTxt: depthTarget.colorTexture);

  final TextureLayout layoutTech = TextureLayout()
    ..blend = shaders.ColorBlendType.Overwrite
    ..entries.add(
        TextureLayoutEntry(texture: depthTarget.colorTexture, destination: Region2(0.0, 0.8, 0.2, 0.2)))
    ..entries.add(TextureLayoutEntry(
        texture: colorTarget.colorTexture, destination: Region2(0.0, 0.6, 0.2, 0.2)));
  final scenes.CoverPass layout = scenes.CoverPass()
    ..target = FrontTarget(clearColor: false)
    ..technique = layoutTech;

  td.scene = scenes.Compound(passes: [skybox, colorPass, depthPass, blurPass, layout]);

  common.showFPS(td);
}
