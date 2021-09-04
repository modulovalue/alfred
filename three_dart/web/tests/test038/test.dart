library three_dart.test.test038;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/events/events.dart' as events;
import 'package:three_dart/lights/lights.dart' as lights;
import 'package:three_dart/math/math.dart' as math;
import 'package:three_dart/movers/movers.dart' as movers;
import 'package:three_dart/scenes/scenes.dart' as scenes;
import 'package:three_dart/shapes/shapes.dart' as shapes;
import 'package:three_dart/techniques/techniques.dart' as techniques;
import 'package:three_dart/textures/textures.dart' as textures;

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 038")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of basic 3D movement around a room similar to a first person view. ",
      "A and D (left and right arrow keys) strifes left and right. ",
      "W and S (up and down arrow keys) moves forward and backward. ",
      "Q and E moves up and down. Mouse looks around with left mouse button pressed."
    ])
    ..addControlBoxes(["options"])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final three_dart.Entity group = three_dart.Entity()..children.add(createFloor(td))..children.add(createObjects(td));
  // Setup the First person camera
  final movers.UserTranslator trans = movers.UserTranslator(input: td.userInput);
  final movers.UserRotator rot = movers.UserRotator.flat(input: td.userInput);
  rot.changed.add((events.EventArgs args) {
    trans.velocityRotation = math.Matrix3.rotateY(-rot.yaw.location);
  });
  final movers.Group camera = movers.Group([trans, rot]);
  td.scene = scenes.EntityPass()
    ..children.add(group)
    ..camera?.mover = camera;
  common.CheckGroup("options").add("Mouse Locking", (bool enable) {
    td.userInput.lockOnClick = enable;
  }, false);
  common.showFPS(td);
}

three_dart.Entity createFloor(three_dart.ThreeDart td) {
  final textures.Texture2D floorTxt =
      td.textureLoader.load2DFromFile("../resources/Grass.png", wrapEdges: true, mipMap: true);
  final movers.Mover floorMover = movers.Constant(math.Matrix4.translate(0.0, -3.0, 0.0) *
      math.Matrix4.scale(1000.0, 1.0, 1000.0) *
      math.Matrix4.rotateX(-math.PI_2));
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..texture2DMatrix = math.Matrix3.scale(1000.0, 1000.0, 1.0)
    ..lights.add(lights.Directional(mover: movers.Constant.vectorTowards(1.0, -3.0, -1.0), color: math.Color3.white()))
    ..ambient.color = math.Color3(0.5, 0.5, 0.5)
    ..diffuse.color = math.Color3(0.5, 0.5, 0.5)
    ..ambient.texture2D = floorTxt
    ..diffuse.texture2D = floorTxt;
  return three_dart.Entity()
    ..shape = shapes.grid(widthDiv: 20, heightDiv: 20)
    ..mover = floorMover
    ..technique = tech;
}

three_dart.Entity createObjects(three_dart.ThreeDart td) {
  final techniques.MaterialLight tech = techniques.MaterialLight()
    ..lights.add(
        lights.Directional(mover: movers.Constant.vectorTowards(1.0, -3.0, -1.0), color: math.Color3(0.4, 0.4, 1.0)))
    ..lights
        .add(lights.Directional(mover: movers.Constant.vectorTowards(0.0, 1.0, 0.0), color: math.Color3(0.0, 0.2, 0.1)))
    ..ambient.color = math.Color3.gray(0.2)
    ..diffuse.color = math.Color3.gray(0.7)
    ..specular.color = math.Color3.white()
    ..specular.shininess = 10.0;
  final three_dart.Entity group = three_dart.Entity()..technique = tech;
  final shapes.Shape shape = shapes.cube();
  const double range = 60.0;
  const double spacing = 12.0;
  for (double x = -range; x <= range; x += spacing) {
    for (double z = -range; z <= range; z += spacing) {
      final three_dart.Entity obj = three_dart.Entity()
        ..shape = shape
        ..mover = movers.Group([
          movers.Rotator(yaw: x / 10.0, pitch: z / 10.0, deltaYaw: x / 10.0, deltaPitch: z / 10.0),
          movers.Constant.translate(x, 0.0, z)
        ]);
      group.children.add(obj);
    }
  }
  return group;
}
