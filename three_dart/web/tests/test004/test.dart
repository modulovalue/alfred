library three_dart.test.test004;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  final common.ShellPage page = common.ShellPage("Test 004")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "Test of repeat use of a single mover and shape. There are 9 rings ",
      "moving at the same speed, however the second one is attached to ",
      "the first, the third to the second, and so on."
    ])
    ..addPar(["«[Back to Tests|../]"]);
  final Rotator rotator = Rotator()
    ..deltaYaw = 0.51
    ..deltaPitch = 0.71
    ..deltaRoll = 0.92;
  final Group mover = Group()..add(Constant.scale(0.8, 0.8, 0.8))..add(rotator);
  final Shape shape = toroid(minorRadius: 0.2, majorRadius: 2.0);
  final three_dart.Entity obj0 = three_dart.Entity(shape: shape, mover: mover);
  final three_dart.Entity obj1 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj0);
  final three_dart.Entity obj2 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj1);
  final three_dart.Entity obj3 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj2);
  final three_dart.Entity obj4 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj3);
  final three_dart.Entity obj5 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj4);
  final three_dart.Entity obj6 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj5);
  final three_dart.Entity obj7 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj6);
  final three_dart.Entity obj8 = three_dart.Entity(shape: shape, mover: mover)..children.add(obj7);
  final Depth tech = Depth(start: 3.0, stop: 6.0, grey: true);
  final EntityPass pass = EntityPass()
    ..technique = tech
    ..children.add(obj8)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas")..scene = pass;
  td.postrender.once((final _) {
    page
      ..addCode("Vertex Shader", "glsl", 0, tech.vertexSourceCode.split("\n"))
      ..addCode("Fragment Shader", "glsl", 0, tech.fragmentSourceCode.split("\n"));
  });
  common.showFPS(td);
}
