library three_dart.test.test001;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 001")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "Test of the Depth shader with a single auto-rotating shape. ",
      "The striations are caused by the depth being stored across the RGB channels. ",
      "Depth can also be sent to all the channels causing a grey scale but at ",
      "lower quality depth. The depth can invert the face to use so that this can ",
      "be used for light shadow depth texture."
    ])
    ..addControlBoxes(["controls"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.Entity obj = three_dart.Entity()
    ..shape = toroid()
    ..mover = Rotator();

  final Depth tech = Depth(start: 2.0, stop: 8.0);
  final EntityPass pass = EntityPass()
    ..children.add(obj)
    ..technique = tech
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas")..scene = pass;

  common.CheckGroup("controls")
    ..add("grey", (bool enable) {
      tech.grey = enable;
    }, true)
    ..add("invert", (bool enable) {
      tech.invert = enable;
    });

  td.postrender.once((_) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
