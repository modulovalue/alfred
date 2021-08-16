library three_dart.test.test002;

import 'dart:math';

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';

import '../../common/common.dart';

void main() {
  ShellPage("Test 002")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "The inspection test is used to check that shapes are built correctly ",
      "and for checking the data provided by the shapes. ",
      "Also it is useful for testing out new generated shape configurations. ",
      "For loaded shape testing see test032."
    ])
    ..addControlBoxes(["controls", "shapes", "scalars"])
    ..addPar(["«[Back to Tests|../]"]);
  final td = three_dart.ThreeDart.fromId("testCanvas");
  final obj = three_dart.Entity()
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput, invertY: true))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  final tech = Inspection()..vectorScale = 0.4;
  td.scene = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  CheckGroup("controls")
    ..add(
      "Filled",
      (bool show) => tech.showFilled = show,
      true,
    )
    ..add(
      "Wire Frame",
      (bool show) => tech.showWireFrame = show,
      true,
    )
    ..add(
      "Vertices",
      (bool show) => tech.showVertices = show,
    )
    ..add(
      "Normals",
      (bool show) => tech.showNormals = show,
    )
    ..add(
      "Binormals",
      (bool show) => tech.showBinormals = show,
    )
    ..add(
      "Tangentals",
      (bool show) => tech.showTangentals = show,
    )
    ..add(
      "Face Centers",
      (bool show) => tech.showFaceCenters = show,
    )
    ..add(
      "Face Normals",
      (bool show) => tech.showFaceNormals = show,
    )
    ..add(
      "Face Binormals",
      (bool show) => tech.showFaceBinormals = show,
    )
    ..add(
      "Face Tangentals",
      (bool show) => tech.showFaceTangentals = show,
    )
    ..add(
      "Colors",
      (bool show) => tech.showColorFill = show,
    )
    ..add(
      "Textures2D",
      (bool show) => tech.showTxt2DColor = show,
    )
    ..add(
      "TexturesCube",
      (bool show) => tech.showTxtCube = show,
    )
    ..add(
      "Weight",
      (bool show) => tech.showWeight = show,
    )
    ..add(
      "Bend",
      (bool show) => tech.showBend = show,
    )
    ..add(
      "Axis",
      (bool show) => tech.showAxis = show,
      true,
    )
    ..add(
      "AABB",
      (bool show) => tech.showAABB = show,
    );
  void setShape(Shape shape) {
    shape.calculateWeights();
    obj.shape = shape;
  }

  RadioGroup("shapes")
    ..add("Square", () {
      setShape(square());
    }, true)
    ..add("Cube", () {
      setShape(cube());
    })
    ..add("Cuboid", () {
      setShape(cuboid());
    })
    ..add("Cuboid+", () {
      setShape(cuboid(
          widthDiv: 15,
          heightDiv: 15,
          vertexHndl: (Vertex ver, double u, double v) {
            final double height = cos(v * 4.0 * PI + PI) * 0.1 + cos(u * 4.0 * PI + PI) * 0.1;
            final loc = ver.location ?? Point3.zero;
            final Vector3 vec = Vector3.fromPoint3(loc).normal();
            ver.location = loc + Point3.fromVector3(vec * height);
          }));
    })
    ..add("Disk", () {
      setShape(disk());
    })
    ..add("Disk+", () {
      setShape(disk(sides: 30));
    })
    ..add("Cylinder", () {
      setShape(cylinder());
    })
    ..add("Cylinder+", () {
      setShape(cylinder(sides: 16, div: 8));
    })
    ..add("Cone", () {
      setShape(cylinder(topRadius: 0.0, sides: 12, capTop: false));
    })
    ..add("Cylindrical", () {
      setShape(cylindrical(
          sides: 50,
          div: 25,
          radiusHndl: (double u, double v) => cos(v * 4.0 * PI + PI) * 0.2 + cos(u * 6.0 * PI) * 0.3 + 0.8));
    })
    ..add("LatLonSphere", () {
      setShape(latLonSphere(10, 20));
    })
    ..add("LatLonSphere+", () {
      setShape(latLonSphere(20, 40));
    })
    ..add("IsoSphere", () {
      setShape(isosphere(2));
    })
    ..add("IsoSphere+", () {
      setShape(isosphere(3));
    })
    ..add("Sphere", () {
      setShape(sphere(widthDiv: 6, heightDiv: 6));
    })
    ..add("Sphere+", () {
      setShape(sphere(widthDiv: 10, heightDiv: 10));
    })
    ..add("Spherical", () {
      setShape(sphere(
          widthDiv: 10,
          heightDiv: 10,
          heightHndl: (double u, double v) => cos(sqrt((u - 0.5) * (u - 0.5) + (v - 0.5) * (v - 0.5)) * PI) * 0.3));
    })
    ..add("Toroid", () {
      setShape(toroid());
    })
    ..add("Knot", () {
      setShape(knot());
    })
    ..add("Grid", () {
      setShape(grid());
    })
    ..add("Grid+", () {
      setShape(
          grid(widthDiv: 16, heightDiv: 16, heightHndl: (double u, double v) => sin(u * 8.0) * cos(v * 8.0) * 0.3));
    });
  RadioGroup("scalars")
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
  showFPS(td);
}
