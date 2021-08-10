library three_dart.test.test032;

import 'dart:async';

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/io/io.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 032")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "The inspection test for shapes loaders. ",
      "For generated shapes see test002. ",
      "Note: Some shapes will take time to load."
    ])
    ..addControlBoxes(["controls", "shapes", "scalars"])
    ..addPar(["«[Back to Tests|../]"]);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");

  bool showMtrl = true;
  final three_dart.Entity obj = three_dart.Entity()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));

  final Inspection tech = Inspection()..vectorScale = 0.4;

  td.scene = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);

  common.CheckGroup("controls")
    ..add("Material", (bool show) {
      showMtrl = show;
      if (obj.children.length > 1) obj.children[0].enabled = showMtrl;
    }, true)
    ..add("Filled", (bool show) {
      tech.showFilled = show;
    })
    ..add("Wire Frame", (bool show) {
      tech.showWireFrame = show;
    }, true)
    ..add("Vertices", (bool show) {
      tech.showVertices = show;
    })
    ..add("Normals", (bool show) {
      tech.showNormals = show;
    })
    ..add("Binormals", (bool show) {
      tech.showBinormals = show;
    })
    ..add("Tangentals", (bool show) {
      tech.showTangentals = show;
    })
    ..add("Face Centers", (bool show) {
      tech.showFaceCenters = show;
    })
    ..add("Face Normals", (bool show) {
      tech.showFaceNormals = show;
    })
    ..add("Face Binormals", (bool show) {
      tech.showFaceBinormals = show;
    })
    ..add("Face Tangentals", (bool show) {
      tech.showFaceTangentals = show;
    })
    ..add("Colors", (bool show) {
      tech.showColorFill = show;
    })
    ..add("Textures2D", (bool show) {
      tech.showTxt2DColor = show;
    })
    ..add("TexturesCube", (bool show) {
      tech.showTxtCube = show;
    })
    ..add("Weight", (bool show) {
      tech.showWeight = show;
    })
    ..add("Axis", (bool show) {
      tech.showAxis = show;
    }, true)
    ..add("AABB", (bool show) {
      tech.showAABB = show;
    });

  three_dart.Entity copyEntity(three_dart.Entity entity) {
    final three_dart.Entity copy = three_dart.Entity();
    copy.shape = entity.shape;
    entity.children.forEach((three_dart.Entity child) {
      copy.children.add(copyEntity(child));
    });
    return copy;
  }

  Future<void> setEntity(String objFile) async {
    final three_dart.Entity entity = await ObjType.fromFile(objFile, td.textureLoader);
    entity.resizeCenter(3.5);
    obj.children.clear();
    obj.children.add(entity);
    entity.enabled = showMtrl;
    final three_dart.Entity other = copyEntity(entity);
    other.technique = tech;
    obj.children.add(other);
  }

  common.RadioGroup("shapes")
    ..add("Cube", () => setEntity("../resources/Cube.obj"), true)
    ..add("Low Poly Tree", () => setEntity("../resources/tree/tree.obj"))
    ..add("Low Poly Wolf", () => setEntity("../resources/Wolf.obj"))
    ..add("Plant", () => setEntity("../resources/plant/plant.obj"));

  common.RadioGroup("scalars")
    ..add("0.01", () {
      tech.vectorScale = 0.01;
    })
    ..add("0.02", () {
      tech.vectorScale = 0.02;
    })
    ..add("0.04", () {
      tech.vectorScale = 0.04;
    })
    ..add("0.06", () {
      tech.vectorScale = 0.06;
    })
    ..add("0.08", () {
      tech.vectorScale = 0.08;
    })
    ..add("0.1", () {
      tech.vectorScale = 0.1;
    })
    ..add("0.2", () {
      tech.vectorScale = 0.2;
    })
    ..add("0.4", () {
      tech.vectorScale = 0.4;
    }, true)
    ..add("0.6", () {
      tech.vectorScale = 0.6;
    })
    ..add("0.8", () {
      tech.vectorScale = 0.8;
    })
    ..add("1.0", () {
      tech.vectorScale = 1.0;
    });

  common.showFPS(td);
}
