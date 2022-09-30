import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/lights.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shaders.dart' as shaders;
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';
import 'package:three_dart/views.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 031")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "A test of the Distortion cover with a dynamic normal map. ",
      "The distortion map is generated into one back buffer. ",
      "The scene is generated into another back buffer. ",
      "The two parts are combined with a Distortion cover. ",
      "Use mouse to rotate cube in normal map and Ctrl plus mouse ",
      "to rotate scene."
    ])
    ..add_par(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity normalObj = three_dart.Entity()
    ..shape = cube()
    ..mover = (Group()..add(UserRotator(input: td.userInput))..add(UserZoom(input: td.userInput)));
  final Normal normalTech = Normal()
    ..bumpyTextureCube = td.textureLoader.loadCubeFromPath("../resources/diceBumpMap");
  final BackTarget normalTarget = BackTarget(autoResize: true, color: Color4(0.5, 0.5, 1.0, 1.0));
  final EntityPass normalPass = EntityPass()
    ..technique = normalTech
    ..target = normalTarget
    ..children.add(normalObj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  final Group secondMover = Group()
    ..add(UserRotator(ctrl: true, input: td.userInput))
    ..add(UserZoom(ctrl: true, input: td.userInput))
    ..add(Constant.translate(0.0, 0.0, 5.0));
  final Perspective userCamera = Perspective(mover: secondMover);
  final BackTarget colorTarget = BackTarget(autoResize: true, clearColor: false);
  final three_dart.Entity colorObj = three_dart.Entity()..shape = toroid();
  final MaterialLight colorTech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(0.0, -1.0, -1.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final CoverPass skybox =
      CoverPass.skybox(td.textureLoader.loadCubeFromPath("../resources/maskonaive", ext: ".jpg"))
        ..target = colorTarget
        ..camera = userCamera;
  final EntityPass colorPass = EntityPass()
    ..camera = userCamera
    ..technique = colorTech
    ..target = colorTarget
    ..children.add(colorObj);
  final Distort distortTech = Distort()
    ..colorTexture = colorTarget.colorTexture
    ..bumpTexture = normalTarget.colorTexture
    ..bumpMatrix = Matrix4.scale(0.05, 0.05, 0.05);
  final CoverPass distortPass = CoverPass()..technique = distortTech;
  final TextureLayout layoutTech = TextureLayout()
    ..blend = shaders.ColorBlendType.Overwrite
    ..entries.add(TextureLayoutEntry(
        texture: normalTarget.colorTexture, destination: Region2(0.0, 0.8, 0.2, 0.2), flip: true))
    ..entries.add(TextureLayoutEntry(
        texture: colorTarget.colorTexture, destination: Region2(0.0, 0.6, 0.2, 0.2)));
  final CoverPass layout = CoverPass()
    ..target = FrontTarget(clearColor: false)
    ..technique = layoutTech;
  td.scene = Compound(passes: [skybox, colorPass, normalPass, distortPass, layout]);
  common.show_fps(td);
}
