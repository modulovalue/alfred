library three_dart.test.test001;

import 'package:three_dart/core.dart' as three_dart;
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final page = common.ShellPage("Test 001")
    ..addLargeCanvas("testCanvas")
    ..add_par([
      "Test of the Depth shader with a single auto-rotating shape. ",
      "The striations are caused by the depth being stored across the RGB channels. ",
      "Depth can also be sent to all the channels causing a grey scale but at ",
      "lower quality depth. The depth can invert the face to use so that this can ",
      "be used for light shadow depth texture."
    ])
    ..addControlBoxes(["controls"])
    ..add_par(["«[Back to Tests|../]"]);
  final obj = three_dart.Entity()
    ..shape = toroid()
    ..mover = Rotator();
  final tech = Depth(start: 2.0, stop: 8.0);
  final pass = EntityPass()
    ..children.add(obj)
    ..technique = tech
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  final td = three_dart.ThreeDart.fromId("testCanvas")..scene = pass;
  common.CheckGroup("controls")
    ..add("grey", (final bool enable) {
      tech.grey = enable;
    }, true)
    ..add("invert", (final bool enable) {
      tech.invert = enable;
    });
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.show_fps(td);
}
