library three_dart.test.test047;

import 'dart:math' as math;

import 'package:three_dart/audio.dart' as audio;
import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/events.dart' as events;
import 'package:three_dart/lights.dart' as lights;
import 'package:three_dart/math.dart' as math;
import 'package:three_dart/movers.dart' as movers;
import 'package:three_dart/scenes.dart' as scenes;
import 'package:three_dart/shapes.dart' as shapes;
import 'package:three_dart/techniques.dart' as techniques;
import 'package:three_dart/textures.dart' as textures;
import 'package:three_dart/views.dart' as views;

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 047")
    ..addLargeCanvas("testCanvas")
    ..add_par(["Test of the audio player. When you click on a cube it will ",
      "play the same audio at slightly different rate and volume."])
    ..add_par(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  final movers.Group mover = movers.Group()
    ..add(movers.UserRotator(input: td.userInput))
    ..add(movers.UserRoller(ctrl: true, input: td.userInput))
    ..add(movers.UserZoom(input: td.userInput))
    ..add(movers.Constant.translate(0.0, 0.0, 5.0));
  final views.Perspective userCamera = views.Perspective(mover: mover);

  final textures.TextureCube color = td.textureLoader.loadCubeFromPath("../resources/diceColor");
  final techniques.MaterialLight colorTech = techniques.MaterialLight()
    ..lights.add(lights.Directional(
          mover: movers.Constant.vectorTowards(-1.0, -1.0, -1.0),
          color: math.Color3(1.0, 0.9, 0.9)))
    ..lights.add(lights.Directional(
          mover: movers.Constant.vectorTowards(1.0, 1.0, 2.0),
          color: math.Color3(0.2, 0.2, 0.35)))
    ..ambient.color = math.Color3(0.2, 0.2, 0.2)
    ..ambient.textureCube = color
    ..diffuse.color = math.Color3(0.8, 0.8, 0.8)
    ..diffuse.textureCube = color
    ..specular.color = math.Color3(0.7, 0.7, 0.7)
    ..specular.shininess = 10.0
    ..bump.textureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap");
  final audio.Player tink = td.audioLoader.loadFromFile("../resources/tink.mp3");
  final List<movers.Rotator> cubeMovers = [];
  final List<math.Color4> pickerColors = [];
  const int cubeCount = 125;
  final three_dart.Entity cubeEntity  = three_dart.Entity(shape: shapes.cube());
  final three_dart.Entity colorGroup  = three_dart.Entity();
  final three_dart.Entity pickerGroup = three_dart.Entity();
  for (double x = -1.6; x <= 1.7; x += 0.8) {
    for (double y = -1.6; y <= 1.7; y += 0.8) {
      for (double z = -1.6; z <= 1.7; z += 0.8) {
        final math.Matrix4 mat = math.Matrix4.translate(x, y, z)*
                           math.Matrix4.scale(0.2, 0.2, 0.2);
        final movers.Rotator mover = movers.Rotator(deltaPitch: 0.0, deltaRoll: 0.0, deltaYaw: 0.0);
        cubeMovers.add(mover);

        final movers.Group group = movers.Group()
          ..add(mover)
          ..add(movers.Constant(mat));
        
        final three_dart.Entity colorEntity = three_dart.Entity()
          ..technique = colorTech
          ..mover = group
          ..children.add(cubeEntity);
        colorGroup.children.add(colorEntity);
        
        final math.Color4 color = math.Color4.fromHVS(pickerColors.length/cubeCount, 1.0, 1.0).trim32();
        pickerColors.add(color);

        final three_dart.Entity pickEntity = three_dart.Entity()
          ..technique = techniques.SolidColor(color: color)
          ..mover = group
          ..children.add(cubeEntity);
        pickerGroup.children.add(pickEntity);
      }
    }
  }

  final views.BackTarget backTarget = views.BackTarget(
    autoResizeScalarX: 0.5, autoResizeScalarY: 0.5, autoResize: true);
  final scenes.EntityPass pickerPass = scenes.EntityPass()
    ..children.add(pickerGroup)
    ..target = backTarget
    ..camera = userCamera;

  final views.FrontTarget frontTarget = views.FrontTarget(clearColor: false);
  final scenes.EntityPass colorPass = scenes.EntityPass()
    ..children.add(colorGroup)
    ..target = frontTarget
    ..camera = userCamera;

  final scenes.CoverPass skybox = scenes.CoverPass.skybox(
    td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
    ..target = frontTarget
    ..camera = userCamera;

  td.prerender.add((_) {
      for (int i = 0; i < cubeMovers.length; ++i) {
        final movers.Rotator mover = cubeMovers[i];
        mover.deltaPitch = 0.99*mover.deltaPitch;
        mover.deltaRoll = 0.99*mover.deltaRoll;
      }
  });
    
  textures.ColorPicker(td.textureLoader, input: td.userInput, txt: backTarget.colorTexture)
    .colorPicked.add((events.EventArgs args) {
      final textures.ColorPickerEventArgs pickArgs = args as textures.ColorPickerEventArgs;
      final math.Color4 color = pickArgs.color.trim32();
      for (int i = 0; i < pickerColors.length; ++i) {
        if (pickerColors[i] == color) {
          final movers.Rotator mover = cubeMovers[i];
          mover.deltaPitch = 1.21;
          mover.deltaRoll = 1.31;

          tink.rate = math.Random().nextDouble()*2.8+0.2;
          tink.volume = math.Random().nextDouble()*0.8+0.2;
          tink.play();
          break;
        }
      }
    });

  td.scene = scenes.Compound(passes: [pickerPass, skybox, colorPass]);

  common.show_fps(td);
}
