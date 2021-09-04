library three_dart.test.test037;

import 'package:three_dart/core/core.dart' as three_dart;
import 'package:three_dart/data/data.dart';
import 'package:three_dart/lights/lights.dart';
import 'package:three_dart/math/math.dart';
import 'package:three_dart/movers/movers.dart';
import 'package:three_dart/scenes/scenes.dart';
import 'package:three_dart/shapes/shapes.dart';
import 'package:three_dart/techniques/techniques.dart';
import 'package:three_dart/textures/textures.dart';

import '../../common/common.dart' as common;

void main() {
  common.ShellPage("Test 037")
    ..addLargeCanvas("testCanvas")
    ..addPar([
      "A test of applying a height map to an image. ",
      "Some shapes will take a bit to calculate depending on quality of mapping."
    ])
    ..addControlBoxes(["heightMaps", "shapes", "scalars"])
    ..addPar(["«[Back to Tests|../]"]);
  final three_dart.ThreeDart td = three_dart.ThreeDart.fromId("testCanvas");
  final MaterialLight tech = MaterialLight()
    ..lights.add(Directional(mover: Constant.vectorTowards(1.0, 1.0, -3.0), color: Color3.white()))
    ..ambient.color = Color3(0.0, 0.0, 1.0)
    ..diffuse.color = Color3(0.0, 1.0, 0.0)
    ..specular.color = Color3(1.0, 0.0, 0.0)
    ..specular.shininess = 10.0;
  final three_dart.Entity objTech = three_dart.Entity()..technique = tech;
  final three_dart.Entity group = three_dart.Entity()
    ..children.add(objTech)
    ..mover = (Group()
      ..add(UserRotator(input: td.userInput))
      ..add(UserRoller(input: td.userInput, ctrl: true))
      ..add(UserZoom(input: td.userInput)));
  td.scene = EntityPass()
    ..children.add(group)
    ..camera?.mover = Constant.translate(0.0, 0.0, 5.0);
  Shape? baseShape;
  String textureFile = "";
  double scalar = 1.0;
  final updateShape = () {
    final Shape? localShape = baseShape;
    if ((localShape != null) && (textureFile.isNotEmpty)) {
      final Texture2D heightMap = td.textureLoader.load2DFromFile(textureFile);
      heightMap.changed.add((_) {
        final TextureReader heightReader = td.textureLoader.readAll(heightMap);
        final Shape shape = Shape.copy(localShape);
        shape.calculateNormals();
        shape.applyHeightMap(heightReader, scalar);
        shape.trimVertices(~VertexType.Norm);
        shape.trimFaces(norm: false);
        shape.calculateNormals();
        objTech.shape = shape;
      });
    }
  };
  final setTextureFile = (String fileName) {
    textureFile = fileName;
    updateShape();
  };
  common.Texture2DGroup("heightMaps", setTextureFile)
    ..add("../resources/HeightMap1.png", true)
    ..add("../resources/HeightMap2.png")
    ..add("../resources/HeightMap3.png")
    ..add("../resources/HeightMap4.png")
    ..add("../resources/ScrewHeightMap.png");
  final setShape = (Shape shape) {
    baseShape = shape;
    updateShape();
  };
  common.RadioGroup("shapes")
    ..add("Cuboid", () {
      setShape(cuboid(widthDiv: 50, heightDiv: 50));
    })
    ..add("Cylinder", () {
      setShape(cylinder(sides: 80, div: 80, capTop: false, capBottom: false));
    })
    ..add("LatLonSphere", () {
      setShape(latLonSphere(80, 80));
    })
    ..add("Sphere", () {
      setShape(sphere(widthDiv: 50, heightDiv: 50));
    })
    ..add("Toroid", () {
      setShape(toroid(minorCount: 50, majorCount: 50));
    })
    ..add("Grid Small", () {
      setShape(grid(widthDiv: 50, heightDiv: 50));
    })
    ..add("Grid Medium", () {
      setShape(grid(widthDiv: 100, heightDiv: 100));
    }, true)
    ..add("Grid Large", () {
      setShape(grid(widthDiv: 150, heightDiv: 150));
    });
  final setScalar = (double s) {
    scalar = s;
    updateShape();
  };
  common.RadioGroup("scalars")
    ..add("0.1", () {
      setScalar(0.1);
    })
    ..add("0.2", () {
      setScalar(0.2);
    })
    ..add("0.4", () {
      setScalar(0.4);
    })
    ..add("0.6", () {
      setScalar(0.6);
    }, true)
    ..add("0.8", () {
      setScalar(0.8);
    })
    ..add("1.0", () {
      setScalar(1.0);
    });
  common.showFPS(td);
}
