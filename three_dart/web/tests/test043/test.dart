library three_dart.test.test043;

import 'package:three_dart/core.dart';
import 'package:three_dart/events.dart';
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
  common.ShellPage("Test 043")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of the color picker, used to read the color of a pixel from a texture. " +
          "It uses a back buffer with solid colored entities to pick which one to move. " +
          "Also testing out the ability to screen shot a back buffer."
    ])
    ..addControlBoxes(["buttons"])
    ..add_par(["«[Back to Tests|../]"]);
  final ThreeDart td = ThreeDart.fromId("testCanvas");
  final Group mover = Group()
    ..add(UserRotator(input: td.userInput))
    ..add(UserRoller(ctrl: true, input: td.userInput))
    ..add(UserZoom(input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: mover);
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
  final List<Rotator> cubeMovers = [];
  final List<Color4> pickerColors = [];
  const int cubeCount = 125;
  final Entity cubeEntity = Entity(shape: cube());
  final Entity colorGroup = Entity();
  final Entity pickerGroup = Entity();
  for (double x = -1.6; x <= 1.7; x += 0.8) {
    for (double y = -1.6; y <= 1.7; y += 0.8) {
      for (double z = -1.6; z <= 1.7; z += 0.8) {
        final Matrix4 mat = Matrix4.translate(x, y, z) * Matrix4.scale(0.2, 0.2, 0.2);
        final Rotator mover = Rotator(deltaPitch: 0.0, deltaRoll: 0.0, deltaYaw: 0.0);
        cubeMovers.add(mover);
        final Group group = Group()..add(mover)..add(Constant(mat));
        final Entity colorEntity = Entity()
          ..technique = colorTech
          ..mover = group
          ..children.add(cubeEntity);
        colorGroup.children.add(colorEntity);
        final Color4 color = Color4.fromHVS(pickerColors.length / cubeCount, 1.0, 1.0).trim32();
        pickerColors.add(color);
        final Entity pickEntity = Entity()
          ..technique = SolidColor(color: color)
          ..mover = group
          ..children.add(cubeEntity);
        pickerGroup.children.add(pickEntity);
      }
    }
  }
  final BackTarget backTarget = BackTarget(autoResizeScalarX: 0.5, autoResizeScalarY: 0.5, autoResize: true);
  final EntityPass pickerPass = EntityPass()
    ..children.add(pickerGroup)
    ..target = backTarget
    ..camera = userCamera;
  final FrontTarget frontTarget = FrontTarget(clearColor: false);
  final EntityPass colorPass = EntityPass()
    ..children.add(colorGroup)
    ..target = frontTarget
    ..camera = userCamera;
  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = frontTarget
        ..camera = userCamera;
  final TextureLayout layout = TextureLayout();
  layout.entries.add(TextureLayoutEntry()
    ..destination = Region2(0.0, 0.75, 0.25, 0.25)
    ..texture = backTarget.colorTexture);
  final CoverPass layoutCover = CoverPass()
    ..technique = layout
    ..target = frontTarget;
  td.prerender.add((final _) {
    for (int i = 0; i < cubeMovers.length; ++i) {
      final Rotator mover = cubeMovers[i];
      mover.deltaPitch = 0.99 * mover.deltaPitch;
      mover.deltaRoll = 0.99 * mover.deltaRoll;
    }
  });
  ColorPicker(td.textureLoader, input: td.userInput, txt: backTarget.colorTexture)
    .colorPicked.add((EventArgs args) {
      final ColorPickerEventArgs pickArgs = args as ColorPickerEventArgs;
      final Color4 color = pickArgs.color.trim32();
      for (int i = 0; i < pickerColors.length; ++i) {
        if (pickerColors[i] == color) {
          final Rotator mover = cubeMovers[i];
          mover.deltaPitch = 1.21;
          mover.deltaRoll = 1.31;
          break;
        }
      }
    });
  td.scene = Compound(passes: [pickerPass, skybox, colorPass, layoutCover]);
  common.ButtonGroup("buttons").add("Back target snapshot", () {
    td.textureLoader.readAll(backTarget.colorTexture, true).savePng("backBuffer.png");
  });
  common.show_fps(td);
}
