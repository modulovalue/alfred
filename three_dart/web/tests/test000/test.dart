import 'dart:async' as asy;
import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:three_dart/collisions.dart';
import 'package:three_dart/core.dart';
import 'package:three_dart/data.dart';
import 'package:three_dart/debug.dart';
import 'package:three_dart/math.dart';
import 'package:three_dart/movers.dart';
import 'package:three_dart/scenes.dart';
import 'package:three_dart/shapes.dart';
import 'package:three_dart/techniques.dart';

import '../../common/common.dart';
import '../../examples/chess/game.dart' as chess;
import '../../examples/craft/main.dart' as craft;

void main() {
  final elem = DivElement();
  final tests = TestManager(elem);
  addBench(tests);
  addVertexTypeTests(tests);
  addMatrix2Tests(tests);
  addMatrix3Tests(tests);
  addMatrix4Tests(tests);
  addRegion2Tests(tests);
  addRegion3Tests(tests);
  addCollisionTests(tests);
  addTechniqueTests(tests);
  addCraftTests(tests);
  addChessTests(tests);
  ShellPage("Unit-tests", false)
    ..addElem(elem)
    ..add_par(["«[Back to Tests|../]"]);
}

void addBench(TestManager tests) {
  tests.add("Benchmark Uint8List timing", (TestArgs args) {
    final Uint8List temp = Uint8List(1000);
    args.bench(1.0, () {
      for (int k = 0; k < 1000; k++) {
        temp[k] = 0;
      }
      for (int j = 0; j < 100; j++) {
        for (int k = 0; k < 1000; k++) {
          temp[k]++;
        }
      }
    });
    args.info("\n$temp");
  });
  tests.add("Benchmark List int timing", (TestArgs args) {
    final temp = List<int>.filled(1000, 0);
    args.bench(1.0, () {
      for (int k = 0; k < 1000; k++) {
        temp[k] = 0;
      }
      for (int j = 0; j < 100; j++) {
        for (int k = 0; k < 1000; k++) {
          temp[k]++;
        }
      }
    });
    args.info("\n$temp");
  });
  tests.add("Benchmark cuboid building", (TestArgs args) {
    Shape shape; // ignore: unused_local_variable
    args.bench(1.0, () {
      shape = cuboid();
    });
    //shape.validate(args);
  });
  tests.add("Benchmark cuboid building and getting normals", (TestArgs args) {
    Shape shape;
    args.bench(1.0, () {
      shape = sphere();
      shape.calculateNormals();
    });
    //shape.validate(args);
  });
  tests.add("Benchmark cuboid building and join seams", (TestArgs args) {
    Shape shape;
    args.bench(1.0, () {
      shape = sphere();
      shape.joinSeams(VertexLocationMatcher());
    });
    //shape.validate(args);
  });
  tests.add("Benchmark sphere building", (TestArgs args) {
    Shape shape; // ignore: unused_local_variable
    args.bench(1.0, () {
      shape = sphere();
    });
    //shape.validate(args);
  });
}

void addVertexTypeTests(TestManager tests) {
  tests.add("VertexTypes and Groups", (TestArgs args) {
    _checkVertexType(args, VertexType.None, "None", 0x0000, 0, 0);
    _checkVertexType(args, VertexType.Pos, "Pos", 0x0001, 1, 3);
    _checkVertexType(args, VertexType.Norm, "Norm", 0x0002, 1, 3);
    _checkVertexType(args, VertexType.Binm, "Binm", 0x0004, 1, 3);
    _checkVertexType(args, VertexType.Txt2D, "Txt2D", 0x0008, 1, 2);
    _checkVertexType(args, VertexType.TxtCube, "TxtCube", 0x0010, 1, 3);
    _checkVertexType(args, VertexType.Clr3, "Clr3", 0x0020, 1, 3);
    _checkVertexType(args, VertexType.Clr4, "Clr4", 0x0040, 1, 4);
    _checkVertexType(args, VertexType.Weight, "Weight", 0x0080, 1, 1);
    _checkVertexType(args, VertexType.Bending, "Bending", 0x0100, 1, 4);
    _checkVertexType(args, VertexType.Pos | VertexType.Norm, "Pos|Norm", 0x0003, 2, 6);
    _checkVertexType(args, VertexType.Pos | VertexType.Txt2D, "Pos|Txt2D", 0x0009, 2, 5);
    _checkVertexType(args, VertexType.Pos | VertexType.Norm | VertexType.Binm | VertexType.Txt2D | VertexType.Clr3,
        "Pos|Norm|Binm|Txt2D|Clr3", 0x002F, 5, 14);
    _checkVertexType(args, VertexType.Txt2D | VertexType.Weight, "Txt2D|Weight", 0x0088, 2, 3);
    _checkVertexType(args, VertexType.TxtCube | VertexType.Bending, "TxtCube|Bending", 0x0110, 2, 7);
  });
  tests.add("VertexTypes from Type Groups 1", (TestArgs args) {
    final group =
        VertexType.Pos | VertexType.Norm | VertexType.Binm | VertexType.Txt2D | VertexType.TxtCube | VertexType.Clr3;
    _checkSubVertexType(args, group, VertexType.Pos, true, 0, 0);
    _checkSubVertexType(args, group, VertexType.Norm, true, 1, 3);
    _checkSubVertexType(args, group, VertexType.Binm, true, 2, 6);
    _checkSubVertexType(args, group, VertexType.Txt2D, true, 3, 9);
    _checkSubVertexType(args, group, VertexType.TxtCube, true, 4, 11);
    _checkSubVertexType(args, group, VertexType.Clr3, true, 5, 14);
    _checkSubVertexType(args, group, VertexType.Clr4, false, -1, -1);
    _checkSubVertexType(args, group, VertexType.Weight, false, -1, -1);
    _checkSubVertexType(args, group, VertexType.Bending, false, -1, -1);
  });
  // Another test of getting vertex types from vertex type groups.
  tests.add("VertexType from Type Groups 2", (TestArgs args) {
    final VertexType group =
        VertexType.Pos | VertexType.Binm | VertexType.Clr4 | VertexType.Weight | VertexType.Bending;
    _checkSubVertexType(args, group, VertexType.Pos, true, 0, 0);
    _checkSubVertexType(args, group, VertexType.Norm, false, -1, -1);
    _checkSubVertexType(args, group, VertexType.Binm, true, 1, 3);
    _checkSubVertexType(args, group, VertexType.Txt2D, false, -1, -1);
    _checkSubVertexType(args, group, VertexType.Clr3, false, -1, -1);
    _checkSubVertexType(args, group, VertexType.Clr4, true, 2, 6);
    _checkSubVertexType(args, group, VertexType.Weight, true, 3, 10);
    _checkSubVertexType(args, group, VertexType.Bending, true, 4, 11);
  });
}

// Checks a vertex types and group for expected values.
void _checkVertexType(TestArgs args, VertexType type, String expName, int expValue, int expCount, int expSize) {
  args.info("Checking vertex type ${type.toString()}:\n");
  final resultName = type.toString();
  if (resultName != expName) {
    args.error("Error: Got the wrong name for a vertex type:\n");
    args.error("   Gotten:   $resultName\n");
    args.error("   Expected: $expName\n");
  }
  final resultValue = type.value;
  if (resultValue != expValue) {
    args.error("Error: Got the wrong value for a vertex type:\n");
    args.error("   Gotten:   $resultValue\n");
    args.error("   Expected: $expValue\n");
  }
  final resultCount = type.count;
  if (resultCount != expCount) {
    args.error("Error: Got the wrong count for a vertex type:\n");
    args.error("   Gotten:   $resultCount\n");
    args.error("   Expected: $expCount\n");
  }
  final resultSize = type.size;
  if (resultSize != expSize) {
    args.error("Error: Got the wrong size for a vertex type:\n");
    args.error("   Gotten:   $resultSize\n");
    args.error("   Expected: $expSize\n");
  }
}

// Checks a vertex group for expected values regarding a vertex type.
void _checkSubVertexType(TestArgs args, VertexType group, VertexType type, bool expHas, int expIndex, int expOffset) {
  args.info("Checking vertex type ${type.toString()} in ${group.toString()}:\n");
  final resultHas = group.has(type);
  if (resultHas != expHas) {
    args.error("Error: Got the wrong result from has for a vertex type in a group:\n");
    args.error("   Gotten:   $resultHas\n");
    args.error("   Expected: $expHas\n");
  }
  final resultIndex = group.indexOf(type);
  if (resultIndex != expIndex) {
    args.error("Error: Got the wrong index for a vertex type in a group:\n");
    args.error("   Gotten:   $resultIndex\n");
    args.error("   Expected: $expIndex\n");
  }
  final expType = expHas ? type : VertexType.None;
  final resultType = group.at(expIndex);
  if (resultType != expType) {
    args.error("Error: Got the wrong index for a vertex type in a group:\n");
    args.error("   Gotten:   ${resultType.toString()}\n");
    args.error("   Expected: ${expType.toString()}\n");
  }
  final resultOffset = group.offset(type);
  if (resultOffset != expOffset) {
    args.error("Error: Got the wrong offset for a vertex type in a group:\n");
    args.error("   Gotten:   $resultOffset\n");
    args.error("   Expected: $expOffset\n");
  }
}

void addMatrix2Tests(TestManager tests) {
  tests.add("Matrix2 Point Transposition Test", (TestArgs args) {
    const Matrix2 mat = Matrix2(2.0, 3.0, 4.0, 5.0);
    _matrix2String(args, mat, "[2.000, 3.000,", " 4.000, 5.000]");
    _transPnt2Matrix2(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transPnt2Matrix2(args, mat, 1.0, 0.0, 2.0, 4.0);
    _transPnt2Matrix2(args, mat, 0.0, 1.0, 3.0, 5.0);
    _transPnt2Matrix2(args, mat, 1.0, 1.0, 5.0, 9.0);
  });
  tests.add("Matrix2 Vector Transposition Test", (TestArgs args) {
    const Matrix2 mat = Matrix2(2.0, 3.0, 4.0, 5.0);
    _matrix2String(args, mat, "[2.000, 3.000,", " 4.000, 5.000]");
    _transVec2Matrix2(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transVec2Matrix2(args, mat, 1.0, 0.0, 2.0, 4.0);
    _transVec2Matrix2(args, mat, 0.0, 1.0, 3.0, 5.0);
    _transVec2Matrix2(args, mat, 1.0, 1.0, 5.0, 9.0);
  });
  tests.add("Matrix2 Identity Test", (TestArgs args) {
    final Matrix2 mat = Matrix2.identity;
    _matrix2String(args, mat, "[1.000, 0.000,", " 0.000, 1.000]");
    _transPnt2Matrix2(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transPnt2Matrix2(args, mat, 1.0, 0.0, 1.0, 0.0);
    _transPnt2Matrix2(args, mat, -1.0, 0.0, -1.0, 0.0);
    _transPnt2Matrix2(args, mat, 1.0, 1.0, 1.0, 1.0);
    _transPnt2Matrix2(args, mat, -1.0, -1.0, -1.0, -1.0);
    _transPnt2Matrix2(args, mat, 0.0, 1.0, 0.0, 1.0);
    _transPnt2Matrix2(args, mat, 0.0, -1.0, 0.0, -1.0);
    _transPnt2Matrix2(args, mat, 2.3, -4.2, 2.3, -4.2);
    _transPnt2Matrix2(args, mat, -1.5, 7.3, -1.5, 7.3);
  });
  tests.add("Matrix2 Scalar Test", (TestArgs args) {
    final Matrix2 mat = Matrix2.scale(2.0, 3.0);
    _matrix2String(args, mat, "[2.000, 0.000,", " 0.000, 3.000]");
    _transPnt2Matrix2(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transPnt2Matrix2(args, mat, 1.0, 0.0, 2.0, 0.0);
    _transPnt2Matrix2(args, mat, -1.0, 0.0, -2.0, 0.0);
    _transPnt2Matrix2(args, mat, 1.0, 1.0, 2.0, 3.0);
    _transPnt2Matrix2(args, mat, -1.0, -1.0, -2.0, -3.0);
    _transPnt2Matrix2(args, mat, 0.0, 1.0, 0.0, 3.0);
    _transPnt2Matrix2(args, mat, 0.0, -1.0, 0.0, -3.0);
    _transPnt2Matrix2(args, mat, 2.3, -4.2, 4.6, -12.6);
    _transPnt2Matrix2(args, mat, -1.5, 7.3, -3.0, 21.9);
  });
  tests.add("Matrix2 Basic Rotate Test", (TestArgs args) {
    final Matrix2 mat = Matrix2.rotate(PI / 4.0);
    _matrix2String(args, mat, "[0.707, -0.707,", " 0.707,  0.707]");
    const val = 0.70710678118; // sqrt(2)/2
    _transPnt2Matrix2(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transPnt2Matrix2(args, mat, 1.0, 0.0, val, val);
    _transPnt2Matrix2(args, mat, val, val, 0.0, 1.0);
    _transPnt2Matrix2(args, mat, 0.0, 1.0, -val, val);
    _transPnt2Matrix2(args, mat, -val, val, -1.0, 0.0);
    _transPnt2Matrix2(args, mat, -1.0, 0.0, -val, -val);
    _transPnt2Matrix2(args, mat, -val, -val, 0.0, -1.0);
    _transPnt2Matrix2(args, mat, 0.0, -1.0, val, -val);
    _transPnt2Matrix2(args, mat, val, -val, 1.0, 0.0);
  });
  tests.add("Matrix2 Rotate Test", (TestArgs args) {
    _matrix2String(args, Matrix2.rotate(-PI / 4.0), "[ 0.707, 0.707,", " -0.707, 0.707]");
    _matrix2String(args, Matrix2.rotate(PI / 2.0), "[0.000, -1.000,", " 1.000,  0.000]");
    _matrix2String(args, Matrix2.rotate(-PI), "[-1.000,  0.000,", "  0.000, -1.000]");
    _matrix2String(args, Matrix2.rotate(PI), "[-1.000,  0.000,", "  0.000, -1.000]");
    _matrix2String(args, Matrix2.rotate(PI * 3.0 / 8.0), "[0.383, -0.924,", " 0.924,  0.383]");
  });
  tests.add("Matrix2 Miscellaneous Test", (TestArgs args) {
    const Matrix2 mat = Matrix2(1.0, 2.0, 3.0, 4.0);
    _matrix2String(args, mat, "[1.000, 2.000,", " 3.000, 4.000]");
    _matrix2String(args, Matrix2.fromList(mat.toList()), "[1.000, 2.000,", " 3.000, 4.000]");
    _matrix2String(args, mat.transpose(), "[1.000, 3.000,", " 2.000, 4.000]");
    _doubleCheck(args, mat.m11, 1.0, "m11");
    _doubleCheck(args, mat.m21, 2.0, "m21");
    _doubleCheck(args, mat.m12, 3.0, "m12");
    _doubleCheck(args, mat.m22, 4.0, "m22");
    _matrix2String(args, Matrix2.fromMatrix3(Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)), "[1.000, 2.000,",
        " 4.000, 5.000]");
    _matrix2String(
        args,
        Matrix2.fromMatrix4(
            Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0)),
        "[1.000, 2.000,",
        " 5.000, 6.000]");
  });
  tests.add("Matrix2 Inverse Test", (TestArgs args) {
    _invsMatrix2(args, Matrix2.identity, "[1.000, 0.000,", " 0.000, 1.000]");
    _invsMatrix2(args, Matrix2.scale(2.0, 3.0), "[0.500, 0.000,", " 0.000, 0.333]");
    _invsMatrix2(args, Matrix2.rotate(PI / 4.0), "[ 0.707, 0.707,", " -0.707, 0.707]");
    _matrix2String(args, const Matrix2(0.0, 0.0, 0.0, 0.0).inverse(), "[1.000, 0.000,", " 0.000, 1.000]");
  });
  tests.add("Matrix2 Multiplication Test", (TestArgs args) {
    // [1, 2, * [5, 6, = [ 5+14,  6+16  = [19, 22,
    //  3, 4]    7, 8]    15+28, 18+32]    43, 50]
    _matrix2String(args, const Matrix2(1.0, 2.0, 3.0, 4.0) * const Matrix2(5.0, 6.0, 7.0, 8.0), "[19.000, 22.000,",
        " 43.000, 50.000]");
    // [5, 6, * [1, 2, = [ 5+18, 10+24  = [23, 34,
    //  7, 8]    3, 4]     7+24, 14+32]    31, 46]
    _matrix2String(args, const Matrix2(5.0, 6.0, 7.0, 8.0) * const Matrix2(1.0, 2.0, 3.0, 4.0), "[23.000, 34.000,",
        " 31.000, 46.000]");
  });
}

void _doubleCheck(TestArgs args, double value, double exp, String name) {
  if (value != exp) {
    args.error("Unexpected result from $name: " + "\n   Expected: $exp" + "\n   Gotten:   $value\n\n");
    args.fail();
  } else {
    args.info("Checked $name is $value\n\n");
  }
}

void _matrix2String(TestArgs args, Matrix2 mat, String exp1, String exp2) {
  final String exp = exp1 + "\n             " + exp2;
  final String result = mat.format("             ");
  if (result != exp) {
    args.error("Unexpected result from Matrix2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n");
    args.fail();
  } else {
    args.info("Checking: " + mat.format("          ") + "\n\n");
  }
}

void _invsMatrix2(TestArgs args, Matrix2 mat, String exp1, String exp2) {
  final Matrix2 inv = mat.inverse();
  _matrix2String(args, inv, exp1, exp2);
  final Matrix2 result = inv.inverse();
  if (result != mat) {
    args.error("Unexpected result from Matrix2.inverse().inverse(): " +
        "\n   Expected: " +
        mat.format("             ") +
        "\n   Gotten:   " +
        result.format("             ") +
        "\n");
    args.fail();
  }
  final Matrix2 ident1 = mat * inv;
  if (ident1 != Matrix2.identity) {
    args.error("Unexpected result from Matrix2*Matrix2.inverse(): " +
        "\n   Matrix:   " +
        mat.format("             ") +
        "\n   Inverted: " +
        inv.format("             ") +
        "\n   Expected: " +
        Matrix2.identity.format("             ") +
        "\n   Gotten:   " +
        ident1.format("             ") +
        "\n");
    args.fail();
  }
  final Matrix2 ident2 = mat * inv;
  if (ident2 != Matrix2.identity) {
    args.error("Unexpected result from Matrix2*Matrix2.inverse(): " +
        "\n   Matrix:   " +
        mat.format("             ") +
        "\n   Inverted: " +
        inv.format("             ") +
        "\n   Expected: " +
        Matrix2.identity.format("             ") +
        "\n   Gotten:   " +
        ident2.format("             ") +
        "\n");
    args.fail();
  }
}

void _transPnt2Matrix2(TestArgs args, Matrix2 mat, double pntX, double pntY, double expX, double expY) {
  final Point2 pnt = Point2(pntX, pntY);
  final Point2 exp = Point2(expX, expY);
  final Point2 result = mat.transPnt2(pnt);
  args.info("Checking Matrix2.transPnt2: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix2.transPnt2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec2Matrix2(TestArgs args, Matrix2 mat, double vecX, double vecY, double expX, double expY) {
  final Vector2 vec = Vector2(vecX, vecY);
  final Vector2 exp = Vector2(expX, expY);
  final Vector2 result = mat.transVec2(vec);
  args.info("Checking Matrix2.transVec2: " + "\n   Matrix:   " + mat.format("             ") + "\n   Vector:   $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix2.transVec2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void addMatrix3Tests(TestManager tests) {
  tests.add("Matrix3 Point Transposition Test", (TestArgs args) {
    final Matrix3 mat = Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    _matrix3String(args, mat, "[1.000, 2.000, 3.000,", " 4.000, 5.000, 6.000,", " 7.000, 8.000, 9.000]");
    _transPnt3Matrix3(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transPnt3Matrix3(args, mat, 1.0, 0.0, 0.0, 1.0, 4.0, 7.0);
    _transPnt3Matrix3(args, mat, 0.0, 1.0, 0.0, 2.0, 5.0, 8.0);
    _transPnt3Matrix3(args, mat, 0.0, 0.0, 1.0, 3.0, 6.0, 9.0);
    _transPnt3Matrix3(args, mat, 1.0, 1.0, 0.0, 3.0, 9.0, 15.0);
    _transPnt3Matrix3(args, mat, 1.0, 0.0, 1.0, 4.0, 10.0, 16.0);
    _transPnt3Matrix3(args, mat, 0.0, 1.0, 1.0, 5.0, 11.0, 17.0);
    _transPnt3Matrix3(args, mat, 1.0, 1.0, 1.0, 6.0, 15.0, 24.0);
  });
  tests.add("Matrix3 Vector Transposition Test", (TestArgs args) {
    final Matrix3 mat = Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    _matrix3String(args, mat, "[1.000, 2.000, 3.000,", " 4.000, 5.000, 6.000,", " 7.000, 8.000, 9.000]");
    _transVec3Matrix3(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transVec3Matrix3(args, mat, 1.0, 0.0, 0.0, 1.0, 4.0, 7.0);
    _transVec3Matrix3(args, mat, 0.0, 1.0, 0.0, 2.0, 5.0, 8.0);
    _transVec3Matrix3(args, mat, 0.0, 0.0, 1.0, 3.0, 6.0, 9.0);
    _transVec3Matrix3(args, mat, 1.0, 1.0, 0.0, 3.0, 9.0, 15.0);
    _transVec3Matrix3(args, mat, 1.0, 0.0, 1.0, 4.0, 10.0, 16.0);
    _transVec3Matrix3(args, mat, 0.0, 1.0, 1.0, 5.0, 11.0, 17.0);
    _transVec3Matrix3(args, mat, 1.0, 1.0, 1.0, 6.0, 15.0, 24.0);
  });
  tests.add("Matrix3 Identity Test", (TestArgs args) {
    final Matrix3 mat = Matrix3.identity;
    _matrix3String(args, mat, "[1.000, 0.000, 0.000,", " 0.000, 1.000, 0.000,", " 0.000, 0.000, 1.000]");
    _transPnt3Matrix3(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transPnt3Matrix3(args, mat, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _transPnt3Matrix3(args, mat, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0);
    _transPnt3Matrix3(args, mat, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0);
    _transPnt3Matrix3(args, mat, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0);
    _transPnt3Matrix3(args, mat, -1.0, 0.0, 1.0, -1.0, 0.0, 1.0);
    _transPnt3Matrix3(args, mat, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
    _transPnt3Matrix3(args, mat, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0);
    _transPnt3Matrix3(args, mat, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0);
    _transPnt3Matrix3(args, mat, 0.0, -1.0, -1.0, 0.0, -1.0, -1.0);
    _transPnt3Matrix3(args, mat, 2.3, -4.2, -0.2, 2.3, -4.2, -0.2);
    _transPnt3Matrix3(args, mat, -1.5, 7.3, 4.8, -1.5, 7.3, 4.8);
  });
  tests.add("Matrix3 Scalar Test", (TestArgs args) {
    final Matrix3 mat = Matrix3.scale(2.0, 3.0, 4.0);
    _matrix3String(args, mat, "[2.000, 0.000, 0.000,", " 0.000, 3.000, 0.000,", " 0.000, 0.000, 4.000]");
    _transPnt3Matrix3(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transPnt3Matrix3(args, mat, 1.0, 1.0, 1.0, 2.0, 3.0, 4.0);
    _transPnt3Matrix3(args, mat, -1.0, -1.0, -1.0, -2.0, -3.0, -4.0);
    _transPnt3Matrix3(args, mat, 2.3, -4.2, -0.2, 4.6, -12.6, -0.8);
    _transPnt3Matrix3(args, mat, -1.5, 7.3, 4.8, -3.0, 21.9, 19.2);
  });
  tests.add("Matrix3 Basic Rotate X Test", (TestArgs args) {
    final Matrix3 mat = Matrix3.rotateX(PI / 4.0);
    _matrix3String(args, mat, "[1.000, 0.000,  0.000,", " 0.000, 0.707, -0.707,", " 0.000, 0.707,  0.707]");
    const val = 0.70710678118; // sqrt(2)/2
    _transPnt3Matrix3(args, mat, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _transPnt3Matrix3(args, mat, 2.0, 1.0, 0.0, 2.0, val, val);
    _transPnt3Matrix3(args, mat, 3.0, val, val, 3.0, 0.0, 1.0);
    _transPnt3Matrix3(args, mat, 4.0, 0.0, 1.0, 4.0, -val, val);
    _transPnt3Matrix3(args, mat, 5.0, -val, val, 5.0, -1.0, 0.0);
    _transPnt3Matrix3(args, mat, 6.0, -1.0, 0.0, 6.0, -val, -val);
    _transPnt3Matrix3(args, mat, 7.0, -val, -val, 7.0, 0.0, -1.0);
    _transPnt3Matrix3(args, mat, 8.0, 0.0, -1.0, 8.0, val, -val);
    _transPnt3Matrix3(args, mat, 9.0, val, -val, 9.0, 1.0, 0.0);
  });
  tests.add("Matrix3 Rotate X Test", (TestArgs args) {
    _matrix3String(
        args, Matrix3.rotateX(-PI / 4.0), "[1.000,  0.000, 0.000,", " 0.000,  0.707, 0.707,", " 0.000, -0.707, 0.707]");
    _matrix3String(
        args, Matrix3.rotateX(PI / 2.0), "[1.000, 0.000,  0.000,", " 0.000, 0.000, -1.000,", " 0.000, 1.000,  0.000]");
    _matrix3String(
        args, Matrix3.rotateX(-PI), "[1.000,  0.000,  0.000,", " 0.000, -1.000,  0.000,", " 0.000,  0.000, -1.000]");
    _matrix3String(
        args, Matrix3.rotateX(PI), "[1.000,  0.000,  0.000,", " 0.000, -1.000,  0.000,", " 0.000,  0.000, -1.000]");
    _matrix3String(args, Matrix3.rotateX(PI * 3.0 / 8.0), "[1.000, 0.000,  0.000,", " 0.000, 0.383, -0.924,",
        " 0.000, 0.924,  0.383]");
  });
  tests.add("Matrix3 Basic Rotate Y Test", (TestArgs args) {
    final Matrix3 mat = Matrix3.rotateY(PI / 4.0);
    _matrix3String(args, mat, "[0.707, 0.000, -0.707,", " 0.000, 1.000,  0.000,", " 0.707, 0.000,  0.707]");
    const double val = 0.70710678118; // sqrt(2)/2
    _transPnt3Matrix3(args, mat, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0);
    _transPnt3Matrix3(args, mat, 1.0, 2.0, 0.0, val, 2.0, val);
    _transPnt3Matrix3(args, mat, val, 3.0, val, 0.0, 3.0, 1.0);
    _transPnt3Matrix3(args, mat, 0.0, 4.0, 1.0, -val, 4.0, val);
    _transPnt3Matrix3(args, mat, -val, 5.0, val, -1.0, 5.0, 0.0);
    _transPnt3Matrix3(args, mat, -1.0, 6.0, 0.0, -val, 6.0, -val);
    _transPnt3Matrix3(args, mat, -val, 7.0, -val, 0.0, 7.0, -1.0);
    _transPnt3Matrix3(args, mat, 0.0, 8.0, -1.0, val, 8.0, -val);
    _transPnt3Matrix3(args, mat, val, 9.0, -val, 1.0, 9.0, 0.0);
  });
  tests.add("Matrix3 Rotate Y Test", (TestArgs args) {
    _matrix3String(
        args, Matrix3.rotateY(-PI / 4.0), "[ 0.707, 0.000, 0.707,", "  0.000, 1.000, 0.000,", " -0.707, 0.000, 0.707]");
    _matrix3String(
        args, Matrix3.rotateY(PI / 2.0), "[0.000, 0.000, -1.000,", " 0.000, 1.000,  0.000,", " 1.000, 0.000,  0.000]");
    _matrix3String(
        args, Matrix3.rotateY(-PI), "[-1.000, 0.000,  0.000,", "  0.000, 1.000,  0.000,", "  0.000, 0.000, -1.000]");
    _matrix3String(
        args, Matrix3.rotateY(PI), "[-1.000, 0.000,  0.000,", "  0.000, 1.000,  0.000,", "  0.000, 0.000, -1.000]");
    _matrix3String(args, Matrix3.rotateY(PI * 3.0 / 8.0), "[0.383, 0.000, -0.924,", " 0.000, 1.000,  0.000,",
        " 0.924, 0.000,  0.383]");
  });
  tests.add("Matrix3 Basic Rotate Z Test", (TestArgs args) {
    final Matrix3 mat = Matrix3.rotateZ(PI / 4.0);
    _matrix3String(args, mat, "[0.707, -0.707, 0.000,", " 0.707,  0.707, 0.000,", " 0.000,  0.000, 1.000]");
    const double val = 0.70710678118; // sqrt(2)/2
    _transPnt3Matrix3(args, mat, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0);
    _transPnt3Matrix3(args, mat, 1.0, 0.0, 2.0, val, val, 2.0);
    _transPnt3Matrix3(args, mat, val, val, 3.0, 0.0, 1.0, 3.0);
    _transPnt3Matrix3(args, mat, 0.0, 1.0, 4.0, -val, val, 4.0);
    _transPnt3Matrix3(args, mat, -val, val, 5.0, -1.0, 0.0, 5.0);
    _transPnt3Matrix3(args, mat, -1.0, 0.0, 6.0, -val, -val, 6.0);
    _transPnt3Matrix3(args, mat, -val, -val, 7.0, 0.0, -1.0, 7.0);
    _transPnt3Matrix3(args, mat, 0.0, -1.0, 8.0, val, -val, 8.0);
    _transPnt3Matrix3(args, mat, val, -val, 9.0, 1.0, 0.0, 9.0);
  });
  tests.add("Matrix3 Rotate Z Test", (TestArgs args) {
    _matrix3String(
        args, Matrix3.rotateZ(-PI / 4.0), "[ 0.707, 0.707, 0.000,", " -0.707, 0.707, 0.000,", "  0.000, 0.000, 1.000]");
    _matrix3String(
        args, Matrix3.rotateZ(PI / 2.0), "[0.000, -1.000, 0.000,", " 1.000,  0.000, 0.000,", " 0.000,  0.000, 1.000]");
    _matrix3String(
        args, Matrix3.rotateZ(-PI), "[-1.000,  0.000, 0.000,", "  0.000, -1.000, 0.000,", "  0.000,  0.000, 1.000]");
    _matrix3String(
        args, Matrix3.rotateZ(PI), "[-1.000,  0.000, 0.000,", "  0.000, -1.000, 0.000,", "  0.000,  0.000, 1.000]");
    _matrix3String(args, Matrix3.rotateZ(PI * 3.0 / 8.0), "[0.383, -0.924, 0.000,", " 0.924,  0.383, 0.000,",
        " 0.000,  0.000, 1.000]");
  });
  tests.add("Matrix3 Miscellaneous Test", (TestArgs args) {
    final Matrix3 mat = Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    _matrix3String(args, mat, "[1.000, 2.000, 3.000,", " 4.000, 5.000, 6.000,", " 7.000, 8.000, 9.000]");
    _matrix3String(args, Matrix3.fromList(mat.toList()), "[1.000, 2.000, 3.000,", " 4.000, 5.000, 6.000,",
        " 7.000, 8.000, 9.000]");
    _matrix3String(args, mat.transpose(), "[1.000, 4.000, 7.000,", " 2.000, 5.000, 8.000,", " 3.000, 6.000, 9.000]");
    _doubleCheck(args, mat.m11, 1.0, "m11");
    _doubleCheck(args, mat.m21, 2.0, "m21");
    _doubleCheck(args, mat.m31, 3.0, "m31");
    _doubleCheck(args, mat.m12, 4.0, "m12");
    _doubleCheck(args, mat.m22, 5.0, "m22");
    _doubleCheck(args, mat.m32, 6.0, "m32");
    _doubleCheck(args, mat.m13, 7.0, "m13");
    _doubleCheck(args, mat.m23, 8.0, "m23");
    _doubleCheck(args, mat.m33, 9.0, "m33");
    _matrix3String(
        args, Matrix3.translate(1.2, 3.4), "[1.000, 0.000, 1.200,", " 0.000, 1.000, 3.400,", " 0.000, 0.000, 1.000]");
    _matrix3String(args, Matrix3.fromMatrix2(const Matrix2(1.0, 2.0, 3.0, 4.0)), "[1.000, 2.000, 0.000,",
        " 3.000, 4.000, 0.000,", " 0.000, 0.000, 1.000]");
    _matrix3String(
        args,
        Matrix3.fromMatrix4(
            Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0)),
        "[1.000,  2.000,  3.000,",
        " 5.000,  6.000,  7.000,",
        " 9.000, 10.000, 11.000]");
  });
  tests.add("Matrix3 Inverse Test", (TestArgs args) {
    _invsMatrix3(args, Matrix3.identity, "[1.000, 0.000, 0.000,", " 0.000, 1.000, 0.000,", " 0.000, 0.000, 1.000]");
    _invsMatrix3(
        args, Matrix3.scale(2.0, 3.0, 4.0), "[0.500, 0.000, 0.000,", " 0.000, 0.333, 0.000,", " 0.000, 0.000, 0.250]");
    _invsMatrix3(
        args, Matrix3.rotateX(PI / 4.0), "[1.000,  0.000, 0.000,", " 0.000,  0.707, 0.707,", " 0.000, -0.707, 0.707]");
    _invsMatrix3(
        args, Matrix3.rotateY(PI / 4.0), "[ 0.707, 0.000, 0.707,", "  0.000, 1.000, 0.000,", " -0.707, 0.000, 0.707]");
    _invsMatrix3(
        args, Matrix3.rotateZ(PI / 4.0), "[ 0.707, 0.707, 0.000,", " -0.707, 0.707, 0.000,", "  0.000, 0.000, 1.000]");
    _matrix3String(args, Matrix3(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0).inverse(), "[1.000, 0.000, 0.000,",
        " 0.000, 1.000, 0.000,", " 0.000, 0.000, 1.000]");
  });
  tests.add("Matrix3 Multiplication Test", (TestArgs args) {
    // [1.0, 2.0, 3.0, * [0.1, 0.2, 0.3, = [0.1+0.8+2.1, 0.2+1.0+2.4, 0.3+1.2+2.7, = [ 3.0,  3.6,  4.2,
    //  4.0, 5.0, 6.0,    0.4, 0.5, 0.6,    0.4+2.0+4.2, 0.8+2.5+4.8, 1.2+3.0+5.4,     6.6,  8.1,  9.6,
    //  7.0, 8.0, 9.0]    0.7, 0.8, 0.9]    0.7+3.2+6.3, 1.4+4.0+7.2, 2.1+4.8+8.1]    10.2, 12.6, 15.0]
    _matrix3String(
        args,
        Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0) * Matrix3(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9),
        "[ 3.000,  3.600,  4.200,",
        "  6.600,  8.100,  9.600,",
        " 10.200, 12.600, 15.000]");
    _matrix3String(
        args,
        Matrix3(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9) * Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0),
        "[ 3.000,  3.600,  4.200,",
        "  6.600,  8.100,  9.600,",
        " 10.200, 12.600, 15.000]");
  });
  tests.add("Matrix3 Point2 Transposition Test", (TestArgs args) {
    final Matrix3 mat = Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    _matrix3String(args, mat, "[1.000, 2.000, 3.000,", " 4.000, 5.000, 6.000,", " 7.000, 8.000, 9.000]");
    _transPnt2Matrix3(args, mat, 0.0, 0.0, 3.0, 6.0);
    _transPnt2Matrix3(args, mat, 1.0, 0.0, 4.0, 10.0);
    _transPnt2Matrix3(args, mat, 0.0, 1.0, 5.0, 11.0);
    _transPnt2Matrix3(args, mat, 1.0, 1.0, 6.0, 15.0);
  });
  tests.add("Matrix3 Vector2 Transposition Test", (TestArgs args) {
    final Matrix3 mat = Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0);
    _matrix3String(args, mat, "[1.000, 2.000, 3.000,", " 4.000, 5.000, 6.000,", " 7.000, 8.000, 9.000]");
    _transVec2Matrix3(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transVec2Matrix3(args, mat, 1.0, 0.0, 1.0, 4.0);
    _transVec2Matrix3(args, mat, 0.0, 1.0, 2.0, 5.0);
    _transVec2Matrix3(args, mat, 1.0, 1.0, 3.0, 9.0);
  });
  // TODO: A unit-test for Quaternion/matrix3 tests.
}

void _matrix3String(TestArgs args, Matrix3 mat, String exp1, String exp2, String exp3) {
  final String exp = exp1 + "\n             " + exp2 + "\n             " + exp3;
  final String result = mat.format("             ");
  if (result != exp) {
    args.error("Unexpected result from Matrix3: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n");
    args.fail();
  } else {
    args.info("Checking: " + mat.format("          ") + "\n\n");
  }
}

void _invsMatrix3(TestArgs args, Matrix3 mat, String exp1, String exp2, String exp3) {
  final Matrix3 inv = mat.inverse();
  _matrix3String(args, inv, exp1, exp2, exp3);
  final Matrix3 result = inv.inverse();
  if (result != mat) {
    args.error("Unexpected result from Matrix3.inverse().inverse(): " +
        "\n   Expected: " +
        mat.format("             ") +
        "\n   Gotten:   " +
        result.format("             ") +
        "\n");
    args.fail();
  }
  final Matrix3 ident1 = mat * inv;
  if (ident1 != Matrix3.identity) {
    args.error("Unexpected result from Matrix3*Matrix3.inverse(): " +
        "\n   Matrix:   " +
        mat.format("             ") +
        "\n   Inverted: " +
        inv.format("             ") +
        "\n   Expected: " +
        Matrix3.identity.format("             ") +
        "\n   Gotten:   " +
        ident1.format("             ") +
        "\n");
    args.fail();
  }
  final Matrix3 ident2 = mat * inv;
  if (ident2 != Matrix3.identity) {
    args.error("Unexpected result from Matrix3*Matrix3.inverse(): " +
        "\n   Matrix:   " +
        mat.format("             ") +
        "\n   Inverted: " +
        inv.format("             ") +
        "\n   Expected: " +
        Matrix3.identity.format("             ") +
        "\n   Gotten:   " +
        ident2.format("             ") +
        "\n");
    args.fail();
  }
}

void _transPnt3Matrix3(
    TestArgs args, Matrix3 mat, double pntX, double pntY, double pntZ, double expX, double expY, double expZ) {
  final Point3 pnt = Point3(pntX, pntY, pntZ);
  final Point3 exp = Point3(expX, expY, expZ);
  final Point3 result = mat.transPnt3(pnt);
  args.info("Checking Matrix3.transPnt3: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix3.transPnt3: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec3Matrix3(
    TestArgs args, Matrix3 mat, double vecX, double vecY, double vecZ, double expX, double expY, double expZ) {
  final Vector3 vec = Vector3(vecX, vecY, vecZ);
  final Vector3 exp = Vector3(expX, expY, expZ);
  final Vector3 result = mat.transVec3(vec);
  args.info("Checking Matrix3.transVec3: " + "\n   Matrix:   " + mat.format("             ") + "\n   Vector:   $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix3.transVec3: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transPnt2Matrix3(TestArgs args, Matrix3 mat, double pntX, double pntY, double expX, double expY) {
  final Point2 pnt = Point2(pntX, pntY);
  final Point2 exp = Point2(expX, expY);
  final Point2 result = mat.transPnt2(pnt);
  args.info("Checking Matrix3.transPnt2: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix3.transPnt2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec2Matrix3(TestArgs args, Matrix3 mat, double vecX, double vecY, double expX, double expY) {
  final Vector2 vec = Vector2(vecX, vecY);
  final Vector2 exp = Vector2(expX, expY);
  final Vector2 result = mat.transVec2(vec);
  args.info("Checking Matrix3.transVec2: " + "\n   Matrix:   " + mat.format("             ") + "\n   Vector:   $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix3.transVec2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void addMatrix4Tests(TestManager tests) {
  tests.add("Matrix4 Point Transposition Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 0.0, 0.0, 1.0, 5.0, 9.0, 13.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 0.0, 0.0, 2.0, 6.0, 10.0, 14.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 0.0, 0.0, 3.0, 11.0, 19.0, 27.0);
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 1.0, 0.0, 3.0, 7.0, 11.0, 15.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 1.0, 0.0, 4.0, 12.0, 20.0, 28.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 1.0, 0.0, 5.0, 13.0, 21.0, 29.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 1.0, 0.0, 6.0, 18.0, 30.0, 42.0);
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 0.0, 1.0, 4.0, 8.0, 12.0, 16.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 0.0, 1.0, 5.0, 13.0, 21.0, 29.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 0.0, 1.0, 6.0, 14.0, 22.0, 30.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 0.0, 1.0, 7.0, 19.0, 31.0, 43.0);
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 1.0, 1.0, 7.0, 15.0, 23.0, 31.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 1.0, 1.0, 8.0, 20.0, 32.0, 44.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 1.0, 1.0, 9.0, 21.0, 33.0, 45.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 1.0, 1.0, 10.0, 26.0, 42.0, 58.0);
  });
  tests.add("Matrix4 Vector Transposition Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _transVec4Matrix4(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transVec4Matrix4(args, mat, 1.0, 0.0, 0.0, 0.0, 1.0, 5.0, 9.0, 13.0);
    _transVec4Matrix4(args, mat, 0.0, 1.0, 0.0, 0.0, 2.0, 6.0, 10.0, 14.0);
    _transVec4Matrix4(args, mat, 1.0, 1.0, 0.0, 0.0, 3.0, 11.0, 19.0, 27.0);
    _transVec4Matrix4(args, mat, 0.0, 0.0, 1.0, 0.0, 3.0, 7.0, 11.0, 15.0);
    _transVec4Matrix4(args, mat, 1.0, 0.0, 1.0, 0.0, 4.0, 12.0, 20.0, 28.0);
    _transVec4Matrix4(args, mat, 0.0, 1.0, 1.0, 0.0, 5.0, 13.0, 21.0, 29.0);
    _transVec4Matrix4(args, mat, 1.0, 1.0, 1.0, 0.0, 6.0, 18.0, 30.0, 42.0);
    _transVec4Matrix4(args, mat, 0.0, 0.0, 0.0, 1.0, 4.0, 8.0, 12.0, 16.0);
    _transVec4Matrix4(args, mat, 1.0, 0.0, 0.0, 1.0, 5.0, 13.0, 21.0, 29.0);
    _transVec4Matrix4(args, mat, 0.0, 1.0, 0.0, 1.0, 6.0, 14.0, 22.0, 30.0);
    _transVec4Matrix4(args, mat, 1.0, 1.0, 0.0, 1.0, 7.0, 19.0, 31.0, 43.0);
    _transVec4Matrix4(args, mat, 0.0, 0.0, 1.0, 1.0, 7.0, 15.0, 23.0, 31.0);
    _transVec4Matrix4(args, mat, 1.0, 0.0, 1.0, 1.0, 8.0, 20.0, 32.0, 44.0);
    _transVec4Matrix4(args, mat, 0.0, 1.0, 1.0, 1.0, 9.0, 21.0, 33.0, 45.0);
    _transVec4Matrix4(args, mat, 1.0, 1.0, 1.0, 1.0, 10.0, 26.0, 42.0, 58.0);
  });
  tests.add("Matrix4 Identity Test", (TestArgs args) {
    final Matrix4 mat = Matrix4.identity;
    _matrix4String(args, mat, "[1.000, 0.000, 0.000, 0.000,", " 0.000, 1.000, 0.000, 0.000,",
        " 0.000, 0.000, 1.000, 0.000,", " 0.000, 0.000, 0.000, 1.000]");
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0);
    _transPnt4Matrix4(args, mat, -1.0, 0.0, 1.0, 0.0, -1.0, 0.0, 1.0, 0.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 0.0);
    _transPnt4Matrix4(args, mat, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0);
    _transPnt4Matrix4(args, mat, 2.3, -4.2, -0.2, 3.3, 2.3, -4.2, -0.2, 3.3);
    _transPnt4Matrix4(args, mat, -1.5, 7.3, 4.8, -9.1, -1.5, 7.3, 4.8, -9.1);
  });
  tests.add("Matrix4 Scalar Test", (TestArgs args) {
    final mat = Matrix4.scale(2.0, 3.0, 4.0, 5.0);
    _matrix4String(args, mat, "[2.000, 0.000, 0.000, 0.000,", " 0.000, 3.000, 0.000, 0.000,",
        " 0.000, 0.000, 4.000, 0.000,", " 0.000, 0.000, 0.000, 5.000]");
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transPnt4Matrix4(args, mat, 1.0, 1.0, 1.0, 1.0, 2.0, 3.0, 4.0, 5.0);
    _transPnt4Matrix4(args, mat, -1.0, -1.0, -1.0, -1.0, -2.0, -3.0, -4.0, -5.0);
    _transPnt4Matrix4(args, mat, 2.3, -4.2, -0.2, 3.3, 4.6, -12.6, -0.8, 16.5);
    _transPnt4Matrix4(args, mat, -1.5, 7.3, 4.8, -9.1, -3.0, 21.9, 19.2, -45.5);
  });
  tests.add("Matrix4 Basic Rotate X Test", (TestArgs args) {
    final mat = Matrix4.rotateX(PI / 4.0);
    _matrix4String(args, mat, "[1.000, 0.000,  0.000, 0.000,", " 0.000, 0.707, -0.707, 0.000,",
        " 0.000, 0.707,  0.707, 0.000,", " 0.000, 0.000,  0.000, 1.000]");
    const val = 0.70710678118; // sqrt(2)/2
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 0.0, 9.0, 1.0, 0.0, 0.0, 9.0);
    _transPnt4Matrix4(args, mat, 2.0, 1.0, 0.0, 8.0, 2.0, val, val, 8.0);
    _transPnt4Matrix4(args, mat, 3.0, val, val, 7.0, 3.0, 0.0, 1.0, 7.0);
    _transPnt4Matrix4(args, mat, 4.0, 0.0, 1.0, 6.0, 4.0, -val, val, 6.0);
    _transPnt4Matrix4(args, mat, 5.0, -val, val, 5.0, 5.0, -1.0, 0.0, 5.0);
    _transPnt4Matrix4(args, mat, 6.0, -1.0, 0.0, 4.0, 6.0, -val, -val, 4.0);
    _transPnt4Matrix4(args, mat, 7.0, -val, -val, 3.0, 7.0, 0.0, -1.0, 3.0);
    _transPnt4Matrix4(args, mat, 8.0, 0.0, -1.0, 2.0, 8.0, val, -val, 2.0);
    _transPnt4Matrix4(args, mat, 9.0, val, -val, 1.0, 9.0, 1.0, 0.0, 1.0);
  });
  tests.add("Matrix4 Rotate X Test", (TestArgs args) {
    _matrix4String(args, Matrix4.rotateX(-PI / 4.0), "[1.000,  0.000, 0.000, 0.000,", " 0.000,  0.707, 0.707, 0.000,",
        " 0.000, -0.707, 0.707, 0.000,", " 0.000,  0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateX(PI / 2.0), "[1.000, 0.000,  0.000, 0.000,", " 0.000, 0.000, -1.000, 0.000,",
        " 0.000, 1.000,  0.000, 0.000,", " 0.000, 0.000,  0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateX(-PI), "[1.000,  0.000,  0.000, 0.000,", " 0.000, -1.000,  0.000, 0.000,",
        " 0.000,  0.000, -1.000, 0.000,", " 0.000,  0.000,  0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateX(PI), "[1.000,  0.000,  0.000, 0.000,", " 0.000, -1.000,  0.000, 0.000,",
        " 0.000,  0.000, -1.000, 0.000,", " 0.000,  0.000,  0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateX(PI * 3.0 / 8.0), "[1.000, 0.000,  0.000, 0.000,",
        " 0.000, 0.383, -0.924, 0.000,", " 0.000, 0.924,  0.383, 0.000,", " 0.000, 0.000,  0.000, 1.000]");
  });
  tests.add("Matrix4 Basic Rotate Y Test", (TestArgs args) {
    final mat = Matrix4.rotateY(PI / 4.0);
    _matrix4String(args, mat, "[0.707, 0.000, -0.707, 0.000,", " 0.000, 1.000,  0.000, 0.000,",
        " 0.707, 0.000,  0.707, 0.000,", " 0.000, 0.000,  0.000, 1.000]");
    const val = 0.70710678118; // sqrt(2)/2
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 0.0, 9.0, 0.0, 1.0, 0.0, 9.0);
    _transPnt4Matrix4(args, mat, 1.0, 2.0, 0.0, 8.0, val, 2.0, val, 8.0);
    _transPnt4Matrix4(args, mat, val, 3.0, val, 7.0, 0.0, 3.0, 1.0, 7.0);
    _transPnt4Matrix4(args, mat, 0.0, 4.0, 1.0, 6.0, -val, 4.0, val, 6.0);
    _transPnt4Matrix4(args, mat, -val, 5.0, val, 5.0, -1.0, 5.0, 0.0, 5.0);
    _transPnt4Matrix4(args, mat, -1.0, 6.0, 0.0, 4.0, -val, 6.0, -val, 4.0);
    _transPnt4Matrix4(args, mat, -val, 7.0, -val, 3.0, 0.0, 7.0, -1.0, 3.0);
    _transPnt4Matrix4(args, mat, 0.0, 8.0, -1.0, 2.0, val, 8.0, -val, 2.0);
    _transPnt4Matrix4(args, mat, val, 9.0, -val, 1.0, 1.0, 9.0, 0.0, 1.0);
  });
  tests.add("Matrix4 Rotate Y Test", (TestArgs args) {
    _matrix4String(args, Matrix4.rotateY(-PI / 4.0), "[ 0.707, 0.000, 0.707, 0.000,", "  0.000, 1.000, 0.000, 0.000,",
        " -0.707, 0.000, 0.707, 0.000,", "  0.000, 0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateY(PI / 2.0), "[0.000, 0.000, -1.000, 0.000,", " 0.000, 1.000,  0.000, 0.000,",
        " 1.000, 0.000,  0.000, 0.000,", " 0.000, 0.000,  0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateY(-PI), "[-1.000, 0.000,  0.000, 0.000,", "  0.000, 1.000,  0.000, 0.000,",
        "  0.000, 0.000, -1.000, 0.000,", "  0.000, 0.000,  0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateY(PI), "[-1.000, 0.000,  0.000, 0.000,", "  0.000, 1.000,  0.000, 0.000,",
        "  0.000, 0.000, -1.000, 0.000,", "  0.000, 0.000,  0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateY(PI * 3.0 / 8.0), "[0.383, 0.000, -0.924, 0.000,",
        " 0.000, 1.000,  0.000, 0.000,", " 0.924, 0.000,  0.383, 0.000,", " 0.000, 0.000,  0.000, 1.000]");
  });
  tests.add("Matrix4 Basic Rotate Z Test", (TestArgs args) {
    final Matrix4 mat = Matrix4.rotateZ(PI / 4.0);
    _matrix4String(args, mat, "[0.707, -0.707, 0.000, 0.000,", " 0.707,  0.707, 0.000, 0.000,",
        " 0.000,  0.000, 1.000, 0.000,", " 0.000,  0.000, 0.000, 1.000]");
    const val = 0.70710678118; // sqrt(2)/2
    _transPnt4Matrix4(args, mat, 0.0, 0.0, 1.0, 9.0, 0.0, 0.0, 1.0, 9.0);
    _transPnt4Matrix4(args, mat, 1.0, 0.0, 2.0, 8.0, val, val, 2.0, 8.0);
    _transPnt4Matrix4(args, mat, val, val, 3.0, 7.0, 0.0, 1.0, 3.0, 7.0);
    _transPnt4Matrix4(args, mat, 0.0, 1.0, 4.0, 6.0, -val, val, 4.0, 6.0);
    _transPnt4Matrix4(args, mat, -val, val, 5.0, 5.0, -1.0, 0.0, 5.0, 5.0);
    _transPnt4Matrix4(args, mat, -1.0, 0.0, 6.0, 4.0, -val, -val, 6.0, 4.0);
    _transPnt4Matrix4(args, mat, -val, -val, 7.0, 3.0, 0.0, -1.0, 7.0, 3.0);
    _transPnt4Matrix4(args, mat, 0.0, -1.0, 8.0, 2.0, val, -val, 8.0, 2.0);
    _transPnt4Matrix4(args, mat, val, -val, 9.0, 1.0, 1.0, 0.0, 9.0, 1.0);
  });
  tests.add("Matrix4 Rotate Z Test", (TestArgs args) {
    _matrix4String(args, Matrix4.rotateZ(-PI / 4.0), "[ 0.707, 0.707, 0.000, 0.000,", " -0.707, 0.707, 0.000, 0.000,",
        "  0.000, 0.000, 1.000, 0.000,", "  0.000, 0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateZ(PI / 2.0), "[0.000, -1.000, 0.000, 0.000,", " 1.000,  0.000, 0.000, 0.000,",
        " 0.000,  0.000, 1.000, 0.000,", " 0.000,  0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateZ(-PI), "[-1.000,  0.000, 0.000, 0.000,", "  0.000, -1.000, 0.000, 0.000,",
        "  0.000,  0.000, 1.000, 0.000,", "  0.000,  0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateZ(PI), "[-1.000,  0.000, 0.000, 0.000,", "  0.000, -1.000, 0.000, 0.000,",
        "  0.000,  0.000, 1.000, 0.000,", "  0.000,  0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.rotateZ(PI * 3.0 / 8.0), "[0.383, -0.924, 0.000, 0.000,",
        " 0.924,  0.383, 0.000, 0.000,", " 0.000,  0.000, 1.000, 0.000,", " 0.000,  0.000, 0.000, 1.000]");
  });
  tests.add("Matrix4 Miscellaneous Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _matrix4String(args, Matrix4.fromList(mat.toList()), "[ 1.000,  2.000,  3.000,  4.000,",
        "  5.000,  6.000,  7.000,  8.000,", "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _matrix4String(args, mat.transpose(), "[1.000, 5.000,  9.000, 13.000,", " 2.000, 6.000, 10.000, 14.000,",
        " 3.000, 7.000, 11.000, 15.000,", " 4.000, 8.000, 12.000, 16.000]");
    _doubleCheck(args, mat.m11, 1.0, "m11");
    _doubleCheck(args, mat.m21, 2.0, "m21");
    _doubleCheck(args, mat.m31, 3.0, "m31");
    _doubleCheck(args, mat.m41, 4.0, "m41");
    _doubleCheck(args, mat.m12, 5.0, "m12");
    _doubleCheck(args, mat.m22, 6.0, "m22");
    _doubleCheck(args, mat.m32, 7.0, "m32");
    _doubleCheck(args, mat.m42, 8.0, "m42");
    _doubleCheck(args, mat.m13, 9.0, "m13");
    _doubleCheck(args, mat.m23, 10.0, "m23");
    _doubleCheck(args, mat.m33, 11.0, "m33");
    _doubleCheck(args, mat.m43, 12.0, "m43");
    _doubleCheck(args, mat.m14, 13.0, "m14");
    _doubleCheck(args, mat.m24, 14.0, "m24");
    _doubleCheck(args, mat.m34, 15.0, "m34");
    _doubleCheck(args, mat.m44, 16.0, "m44");
    _matrix4String(args, Matrix4.translate(1.2, 3.4, 5.6), "[1.000, 0.000, 0.000, 1.200,",
        " 0.000, 1.000, 0.000, 3.400,", " 0.000, 0.000, 1.000, 5.600,", " 0.000, 0.000, 0.000, 1.000]");
    _matrix4String(args, Matrix4.fromMatrix2(const Matrix2(1.0, 2.0, 3.0, 4.0)), "[1.000, 2.000, 0.000, 0.000,",
        " 3.000, 4.000, 0.000, 0.000,", " 0.000, 0.000, 1.000, 0.000,", " 0.000, 0.000, 0.000, 1.000]");
    _matrix4String(
        args,
        Matrix4.fromMatrix3(Matrix3(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)),
        "[1.000, 2.000, 3.000, 0.000,",
        " 4.000, 5.000, 6.000, 0.000,",
        " 7.000, 8.000, 9.000, 0.000,",
        " 0.000, 0.000, 0.000, 1.000]");
  });
  tests.add("Matrix4 Inverse Test", (TestArgs args) {
    _invsMatrix4(args, Matrix4.identity, "[1.000, 0.000, 0.000, 0.000,", " 0.000, 1.000, 0.000, 0.000,",
        " 0.000, 0.000, 1.000, 0.000,", " 0.000, 0.000, 0.000, 1.000]");
    _invsMatrix4(args, Matrix4.scale(2.0, 3.0, 4.0), "[0.500, 0.000, 0.000, 0.000,", " 0.000, 0.333, 0.000, 0.000,",
        " 0.000, 0.000, 0.250, 0.000,", " 0.000, 0.000, 0.000, 1.000]");
    _invsMatrix4(args, Matrix4.rotateX(PI / 4.0), "[1.000,  0.000, 0.000, 0.000,", " 0.000,  0.707, 0.707, 0.000,",
        " 0.000, -0.707, 0.707, 0.000,", " 0.000,  0.000, 0.000, 1.000]");
    _invsMatrix4(args, Matrix4.rotateY(PI / 4.0), "[ 0.707, 0.000, 0.707, 0.000,", "  0.000, 1.000, 0.000, 0.000,",
        " -0.707, 0.000, 0.707, 0.000,", "  0.000, 0.000, 0.000, 1.000]");
    _invsMatrix4(args, Matrix4.rotateZ(PI / 4.0), "[ 0.707, 0.707, 0.000, 0.000,", " -0.707, 0.707, 0.000, 0.000,",
        "  0.000, 0.000, 1.000, 0.000,", "  0.000, 0.000, 0.000, 1.000]");
    _matrix4String(
        args,
        Matrix4(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0).inverse(),
        "[1.000, 0.000, 0.000, 0.000,",
        " 0.000, 1.000, 0.000, 0.000,",
        " 0.000, 0.000, 1.000, 0.000,",
        " 0.000, 0.000, 0.000, 1.000]");
  });
  tests.add("Matrix4 Multiplication Test", (TestArgs args) {
    _matrix4String(
        args,
        Matrix4(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6) *
            Matrix4(1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6),
        "[ 1.900,  2.000,  2.100,  2.200,",
        "  4.620,  4.880,  5.140,  5.400,",
        "  7.340,  7.760,  8.180,  8.600,",
        " 10.060, 10.640, 11.220, 11.800]");
    _matrix4String(
        args,
        Matrix4(1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6) *
            Matrix4(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6),
        "[3.700, 4.200, 4.700,  5.200,",
        " 4.820, 5.480, 6.140,  6.800,",
        " 5.940, 6.760, 7.580,  8.400,",
        " 7.060, 8.040, 9.020, 10.000]");
  });
  tests.add("Matrix4 Point3 Transposition Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _transPnt3Matrix4(args, mat, 0.0, 0.0, 0.0, 4.0, 8.0, 12.0);
    _transPnt3Matrix4(args, mat, 1.0, 0.0, 0.0, 5.0, 13.0, 21.0);
    _transPnt3Matrix4(args, mat, 0.0, 1.0, 0.0, 6.0, 14.0, 22.0);
    _transPnt3Matrix4(args, mat, 1.0, 1.0, 0.0, 7.0, 19.0, 31.0);
    _transPnt3Matrix4(args, mat, 0.0, 0.0, 1.0, 7.0, 15.0, 23.0);
    _transPnt3Matrix4(args, mat, 1.0, 0.0, 1.0, 8.0, 20.0, 32.0);
    _transPnt3Matrix4(args, mat, 0.0, 1.0, 1.0, 9.0, 21.0, 33.0);
    _transPnt3Matrix4(args, mat, 1.0, 1.0, 1.0, 10.0, 26.0, 42.0);
  });
  tests.add("Matrix4 Vector3 Transposition Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _transVec3Matrix4(args, mat, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _transVec3Matrix4(args, mat, 1.0, 0.0, 0.0, 1.0, 5.0, 9.0);
    _transVec3Matrix4(args, mat, 0.0, 1.0, 0.0, 2.0, 6.0, 10.0);
    _transVec3Matrix4(args, mat, 1.0, 1.0, 0.0, 3.0, 11.0, 19.0);
    _transVec3Matrix4(args, mat, 0.0, 0.0, 1.0, 3.0, 7.0, 11.0);
    _transVec3Matrix4(args, mat, 1.0, 0.0, 1.0, 4.0, 12.0, 20.0);
    _transVec3Matrix4(args, mat, 0.0, 1.0, 1.0, 5.0, 13.0, 21.0);
    _transVec3Matrix4(args, mat, 1.0, 1.0, 1.0, 6.0, 18.0, 30.0);
  });
  tests.add("Matrix4 Point2 Transposition Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _transPnt2Matrix4(args, mat, 0.0, 0.0, 4.0, 8.0);
    _transPnt2Matrix4(args, mat, 1.0, 0.0, 5.0, 13.0);
    _transPnt2Matrix4(args, mat, 0.0, 1.0, 6.0, 14.0);
    _transPnt2Matrix4(args, mat, 1.0, 1.0, 7.0, 19.0);
  });
  tests.add("Matrix4 Vector2 Transposition Test", (TestArgs args) {
    final Matrix4 mat = Matrix4(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0);
    _matrix4String(args, mat, "[ 1.000,  2.000,  3.000,  4.000,", "  5.000,  6.000,  7.000,  8.000,",
        "  9.000, 10.000, 11.000, 12.000,", " 13.000, 14.000, 15.000, 16.000]");
    _transVec2Matrix4(args, mat, 0.0, 0.0, 0.0, 0.0);
    _transVec2Matrix4(args, mat, 1.0, 0.0, 1.0, 5.0);
    _transVec2Matrix4(args, mat, 0.0, 1.0, 2.0, 6.0);
    _transVec2Matrix4(args, mat, 1.0, 1.0, 3.0, 11.0);
  });
  // TODO: A unit-tests for Check custom rotation on vector.
  // TODO: A unit-tests for Perspective, ortho, lookTowards, and lookAtTarget.
}

void _matrix4String(TestArgs args, Matrix4 mat, String exp1, String exp2, String exp3, String exp4) {
  final String exp = exp1 + "\n             " + exp2 + "\n             " + exp3 + "\n             " + exp4;
  final String result = mat.format("             ");
  if (result != exp) {
    args.error("Unexpected result from Matrix4: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n");
    args.fail();
  } else {
    args.info("Checking: " + mat.format("          ") + "\n\n");
  }
}

void _invsMatrix4(TestArgs args, Matrix4 mat, String exp1, String exp2, String exp3, String exp4) {
  final Matrix4 inv = mat.inverse();
  _matrix4String(args, inv, exp1, exp2, exp3, exp4);
  final Matrix4 result = inv.inverse();
  if (result != mat) {
    args.error("Unexpected result from Matrix4.inverse().inverse(): " +
        "\n   Expected: " +
        mat.format("             ") +
        "\n   Gotten:   " +
        result.format("             ") +
        "\n");
    args.fail();
  }
  final Matrix4 ident1 = mat * inv;
  if (ident1 != Matrix4.identity) {
    args.error("Unexpected result from Matrix4*Matrix4.inverse(): " +
        "\n   Matrix:   " +
        mat.format("             ") +
        "\n   Inverted: " +
        inv.format("             ") +
        "\n   Expected: " +
        Matrix4.identity.format("             ") +
        "\n   Gotten:   " +
        ident1.format("             ") +
        "\n");
    args.fail();
  }
  final Matrix4 ident2 = mat * inv;
  if (ident2 != Matrix4.identity) {
    args.error("Unexpected result from Matrix4*Matrix4.inverse(): " +
        "\n   Matrix:   " +
        mat.format("             ") +
        "\n   Inverted: " +
        inv.format("             ") +
        "\n   Expected: " +
        Matrix4.identity.format("             ") +
        "\n   Gotten:   " +
        ident2.format("             ") +
        "\n");
    args.fail();
  }
}

void _transPnt4Matrix4(TestArgs args, Matrix4 mat, double pntX, double pntY, double pntZ, double pntW, double expX,
    double expY, double expZ, double expW) {
  final Point4 pnt = Point4(pntX, pntY, pntZ, pntW);
  final Point4 exp = Point4(expX, expY, expZ, expW);
  final Point4 result = mat.transPnt4(pnt);
  args.info("Checking Matrix4.transPnt4: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix4.transPnt4: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec4Matrix4(TestArgs args, Matrix4 mat, double vecX, double vecY, double vecZ, double vecW, double expX,
    double expY, double expZ, double expW) {
  final Vector4 vec = Vector4(vecX, vecY, vecZ, vecW);
  final Vector4 exp = Vector4(expX, expY, expZ, expW);
  final Vector4 result = mat.transVec4(vec);
  args.info("Checking Matrix4.transVec4: " + "\n   Matrix:   " + mat.format("             ") + "\n   Vector:   $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix4.transVec4: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transPnt3Matrix4(
    TestArgs args, Matrix4 mat, double pntX, double pntY, double pntZ, double expX, double expY, double expZ) {
  final Point3 pnt = Point3(pntX, pntY, pntZ);
  final Point3 exp = Point3(expX, expY, expZ);
  final Point3 result = mat.transPnt3(pnt);
  args.info("Checking Matrix4.transPnt3: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix4.transPnt3: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec3Matrix4(
    TestArgs args, Matrix4 mat, double vecX, double vecY, double vecZ, double expX, double expY, double expZ) {
  final Vector3 vec = Vector3(vecX, vecY, vecZ);
  final Vector3 exp = Vector3(expX, expY, expZ);
  final Vector3 result = mat.transVec3(vec);
  args.info("Checking Matrix4.transVec3: " + "\n   Matrix:   " + mat.format("             ") + "\n   Vector:   $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix4.transVec3: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transPnt2Matrix4(TestArgs args, Matrix4 mat, double pntX, double pntY, double expX, double expY) {
  final Point2 pnt = Point2(pntX, pntY);
  final Point2 exp = Point2(expX, expY);
  final Point2 result = mat.transPnt2(pnt);
  args.info("Checking Matrix4.transPnt2: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix4.transPnt2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec2Matrix4(TestArgs args, Matrix4 mat, double vecX, double vecY, double expX, double expY) {
  final Vector2 vec = Vector2(vecX, vecY);
  final Vector2 exp = Vector2(expX, expY);
  final Vector2 result = mat.transVec2(vec);
  args.info("Checking Matrix4.transVec2: " + "\n   Matrix:   " + mat.format("             ") + "\n   Point:    $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix4.transVec2: " + "\n   Expected: $exp" + "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void addRegion2Tests(TestManager tests) {
  tests.add("Region2 Point Expand Test", (TestArgs args) {
    final Region2 reg1 = Region2.zero;
    _expandReg2(args, reg1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _expandReg2(args, reg1, 1.0, 2.0, 0.0, 0.0, 1.0, 2.0);
    _expandReg2(args, reg1, -1.0, -2.0, -1.0, -2.0, 1.0, 2.0);
    final Region2 reg2 = Region2(0.0, 0.0, 1.0, 2.0);
    _expandReg2(args, reg2, -1.0, -2.0, -1.0, -2.0, 2.0, 4.0);
    final Region2 reg3 = Region2(-1.0, -2.0, 2.0, 4.0);
    _expandReg2(args, reg3, 1.0, 1.0, -1.0, -2.0, 2.0, 4.0);
    _expandReg2(args, reg3, 4.0, 4.0, -1.0, -2.0, 5.0, 6.0);
  });
}

Region2 _expandReg2(TestArgs args, Region2 reg, double newX, double newY, double x, double y, double dx, double dy) {
  final Point2 input = Point2(newX, newY);
  final Region2 newReg = reg.expandWithPoint(input);
  final Region2 expReg = Region2(x, y, dx, dy);
  if (newReg != expReg) {
    args.error("Unexpected result from expand:\n" +
        "   Original: $reg\n" +
        "   Point:    $input\n" +
        "   Expected: $expReg\n" +
        "   Result:   $newReg\n");
  } else {
    args.info("$reg + $input => $newReg\n");
  }
  return newReg;
}

void addRegion3Tests(TestManager tests) {
  tests.add("Region3 Point Expand Test", (TestArgs args) {
    final Region3 reg1 = Region3.zero;
    _expandReg3(args, reg1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
    _expandReg3(args, reg1, 1.0, 2.0, 3.0, 0.0, 0.0, 0.0, 1.0, 2.0, 3.0);
    _expandReg3(args, reg1, -1.0, -2.0, -3.0, -1.0, -2.0, -3.0, 1.0, 2.0, 3.0);
    final Region3 reg2 = Region3(0.0, 0.0, 0.0, 1.0, 2.0, 3.0);
    _expandReg3(args, reg2, -1.0, -2.0, -3.0, -1.0, -2.0, -3.0, 2.0, 4.0, 6.0);
    final Region3 reg3 = Region3(-1.0, -2.0, -3.0, 2.0, 4.0, 6.0);
    _expandReg3(args, reg3, 1.0, 1.0, 1.0, -1.0, -2.0, -3.0, 2.0, 4.0, 6.0);
    _expandReg3(args, reg3, 4.0, 4.0, 4.0, -1.0, -2.0, -3.0, 5.0, 6.0, 7.0);
  });
}

Region3 _expandReg3(TestArgs args, Region3 reg, double newX, double newY, double newZ, double x, double y, double z,
    double dx, double dy, double dz) {
  final Point3 input = Point3(newX, newY, newZ);
  final Region3 newReg = reg.expandWithPoint(input);
  final Region3 expReg = Region3(x, y, z, dx, dy, dz);
  if (newReg != expReg) {
    args.error("Unexpected result from expand:\n" +
        "   Original: $reg\n" +
        "   Point:    $input\n" +
        "   Expected: $expReg\n" +
        "   Result:   $newReg\n");
  } else {
    args.info("[$reg] + [$input] => [$newReg]\n");
  }
  return newReg;
}

void addCollisionTests(TestManager tests) {
  tests.add("Collision Between Two AABB Test", (TestArgs args) {
    _aabb3Collision1(args, "Not moving, not touching", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0), Vector3(0.0, 0.0, 0.0), Type.NoCollision, 0.0, HitRegion.None);
    _aabb3Collision1(args, "Moving right but not enough to touch", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0), Vector3(0.5, 0.0, 0.0), Type.NoCollision, 0.0, HitRegion.None);
    _aabb3Collision1(args, "Moving right until they just touch on edge", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0), Vector3(1.0, 0.0, 0.0), Type.Collision, 1.0, HitRegion.XNeg);
    _aabb3Collision1(args, "Moving to pass eachother and hit early", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0), Vector3(4.0, 0.0, 0.0), Type.Collision, 0.25, HitRegion.XNeg);
    _aabb3Collision1(args, "Moving away from eachother backwards", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0), Vector3(-4.0, 0.0, 0.0), Type.NoCollision, 0.0, HitRegion.None);
    _aabb3Collision1(args, "Moving away from eachother already passed", Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0), Vector3(4.0, 0.0, 0.0), Type.NoCollision, 0.0, HitRegion.None);
    _aabb3Collision1(args, "Moving backwards past eachother and hit early", Region3(2.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0), Vector3(-4.0, 0.0, 0.0), Type.Collision, 0.25, HitRegion.XPos);
    _aabb3Collision1(args, "Moving right but offset to pass eachother", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0), Vector3(4.0, 0.0, 0.0), Type.NoCollision, 0.0, HitRegion.None);
    _aabb3Collision1(args, "Moving almost diagnally at an angle to collide", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0), Vector3(2.0, 2.4, 2.8), Type.Collision, 0.5, HitRegion.XNeg);
    _aabb3Collision1(
        args,
        "Moving almost diagnally at a different angle to collide",
        Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
        Vector3(2.8, 2.0, 2.4),
        Type.Collision,
        0.5,
        HitRegion.YNeg);
    _aabb3Collision1(
        args,
        "Moving almost diagnally at another different angle to collide",
        Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0),
        Vector3(2.4, 2.8, 2.0),
        Type.Collision,
        0.5,
        HitRegion.ZNeg);
    _aabb3Collision1(args, "Moving diagnally to collide", Region3(0.0, 0.0, 0.0, 1.0, 1.0, 1.0),
        Region3(2.0, 2.0, 2.0, 1.0, 1.0, 1.0), Vector3(2.0, 2.0, 2.0), Type.Collision, 0.5, HitRegion.XNeg);
    _aabb3Collision1(
        args,
        "Moving down and colliding",
        Region3(0.0, 11.13, 0.0, 0.0, 1.5, 0.0),
        Region3(0.0, 8.0, 0.0, 0.0, 1.0, 0.0),
        Vector3(0.0, -2.45, 0.0),
        Type.Collision,
        0.869387755102041,
        HitRegion.YPos);
    _aabb3Collision1(
        args,
        "Moving up at an agle and already touching on edge",
        Region3(0.25, 10.0, 0.1, 0.25, 2.0, 0.25),
        Region3(0.0, 9.0, 0.0, 1.0, 1.0, 1.0),
        Vector3(0.0, -1.0, -0.3),
        Type.Collision,
        0.0,
        HitRegion.YPos);
    _aabb3Collision1(args, "One already contains the other", Region3(-2.0, -2.0, -2.0, 4.0, 4.0, 4.0),
        Region3(-1.0, -1.0, -1.0, 2.0, 2.0, 2.0), Vector3(2.0, 2.0, 2.0), Type.Intesected, 0.0, HitRegion.None);
    _aabb3Collision1(args, "Partually overlapping", Region3(-2.0, -2.0, -2.0, 2.0, 2.0, 2.0),
        Region3(-1.0, -1.0, -1.0, 2.0, 2.0, 2.0), Vector3(2.0, 2.0, 2.0), Type.Intesected, 0.0, HitRegion.None);
  });
  tests.add("Collision Between Two Spheres Test", (TestArgs args) {
    _twoSphereCollision(args, "Same sized spheres colliding after B moves left", Sphere(0.0, 0.0, 0.0, 1.0),
        Sphere(3.0, 0.0, 0.0, 1.0), Vector3.zero, Vector3(-1.0, 0.0, 0.0), Type.Collision, 1.0);
    _twoSphereCollision(args, "Same sized spheres colliding after A moves left", Sphere(3.0, 0.0, 0.0, 1.0),
        Sphere(0.0, 0.0, 0.0, 1.0), Vector3(-1.0, 0.0, 0.0), Vector3.zero, Type.Collision, 1.0);
    _twoSphereCollision(args, "Same sized spheres already touching and A moves left", Sphere(0.0, 0.0, 0.0, 1.0),
        Sphere(2.0, 0.0, 0.0, 1.0), Vector3(-1.0, 0.0, 0.0), Vector3.zero, Type.NoCollision, 0.0);
    _twoSphereCollision(args, "Same sized spheres already touching and A moves right", Sphere(0.0, 0.0, 0.0, 1.0),
        Sphere(2.0, 0.0, 0.0, 1.0), Vector3.zero, Vector3(-1.0, 0.0, 0.0), Type.Collision, 0.0);
  });
}

void _aabb3Collision1(TestArgs args, String msg, Region3 reg, Region3 target, Vector3 vec, Type expType,
    double expParametric, HitRegion expHit) {
  final TwoAABB3Result result = twoAABB3(reg, target, vec, Vector3.zero);
  if ((result.type != expType) || !Comparer.equals(result.parametric, expParametric) || (result.region != expHit)) {
    args.error("Unexpected result from twoAABB3 collision:\n" +
        "   Message:  $msg\n" +
        "   Original: $reg\n" +
        "   Target:   $target\n" +
        "   Vector:   $vec\n" +
        "   Expected: $expType $expParametric $expHit\n" +
        "   Result:   $result\n");
  } else {
    args.info("Results from twoAABB3 collision:\n" +
        "   Message:  $msg\n" +
        "   Original: $reg\n" +
        "   Target:   $target\n" +
        "   Vector:   $vec\n" +
        "   Result:   $result\n");
  }
}

void _twoSphereCollision(TestArgs args, String msg, Sphere sphereA, Sphere sphereB, Vector3 vecA, Vector3 vecB,
    Type expType, double expParametric) {
  final TwoSphereResult result = twoSphere(sphereA, sphereB, vecA, vecB);
  if ((result.type != expType) || !Comparer.equals(result.parametric, expParametric)) {
    args.error("Unexpected result from twoSphere collision:\n" +
        "   Message:  $msg\n" +
        "   Sphere A: $sphereA\n" +
        "   Sphere B: $sphereB\n" +
        "   Vector A: $vecA\n" +
        "   Vector B: $vecB\n" +
        "   Expected: $expType $expParametric\n" +
        "   Result:   ${result.type} ${result.parametric}\n" +
        "   ResultOb: $result\n");
  } else {
    args.info("Results from twoSphere collision:\n" +
        "   Message:  $msg\n" +
        "   Sphere A: $sphereA\n" +
        "   Sphere B: $sphereB\n" +
        "   Vector A: $vecA\n" +
        "   Vector B: $vecB\n" +
        "   Result:   $result\n");
  }
}

void addTechniqueTests(TestManager tests) {
  tests.add("Matrix4 Point Transposition Test", (TestArgs args) {
    testTechnique(args, Matrix4.identity, Matrix4.translate(0.0, 0.0, -5.0), [
      pointPair(0.0, 0.0, 0.0, 0.0, 0.0, 1.020051002550127),
      pointPair(1.0, 0.0, 0.0, -0.3464101615137755, 0.0, 1.020051002550127),
      pointPair(-1.0, 0.0, 0.0, 0.3464101615137755, 0.0, 1.020051002550127),
      pointPair(0.0, 1.0, 0.0, 0.0, -0.3464101615137755, 1.020051002550127),
      pointPair(0.0, -1.0, 0.0, 0.0, 0.3464101615137755, 1.020051002550127),
      pointPair(0.0, 0.0, 1.0, 0.0, 0.0, 1.016717502541794),
      pointPair(0.0, 0.0, -1.0, 0.0, 0.0, 1.025051252562628),
      pointPair(1.0, 1.0, 1.0, -0.2886751345948129, -0.2886751345948129, 1.016717502541794),
      pointPair(1.0, -1.0, 1.0, -0.2886751345948129, 0.2886751345948129, 1.016717502541794),
      pointPair(1.0, 1.0, -1.0, -0.4330127018922194, -0.4330127018922194, 1.025051252562628),
      pointPair(1.0, -1.0, -1.0, -0.4330127018922194, 0.4330127018922194, 1.025051252562628),
      pointPair(-1.0, 1.0, 1.0, 0.2886751345948129, -0.2886751345948129, 1.016717502541794),
      pointPair(-1.0, -1.0, 1.0, 0.2886751345948129, 0.2886751345948129, 1.016717502541794),
      pointPair(-1.0, 1.0, -1.0, 0.4330127018922194, -0.4330127018922194, 1.025051252562628),
      pointPair(-1.0, -1.0, -1.0, 0.4330127018922194, 0.4330127018922194, 1.025051252562628)
    ]);
  });
}

class pointPair {
  Point3 inPoint;
  Point3 outPoint;

  pointPair(double inX, double inY, double inZ, double outX, double outY, double outZ)
      : this.inPoint = Point3(inX, inY, inZ),
        this.outPoint = Point3(outX, outY, outZ);
}

void testTechnique(TestArgs args, Matrix4 objMat, Matrix4 camMat, List<pointPair> pairs) {
  final shape = Shape();
  for (int i = 0; i < pairs.length; i++) {
    shape.vertices.addNew(loc: pairs[i].inPoint);
  }
  final Entity obj = Entity()
    ..shape = shape
    ..mover = Constant(objMat);
  final buf = StringBuffer();
  final tech = Debugger(buf);
  final pass = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant(camMat);
  final td = ThreeDart.fromCanvas(CanvasElement())
    ..autoRefresh = false
    ..scene = pass;
  td.render();
  args.info(buf.toString());
  if (tech.results.length != pairs.length) {
    String result = "";
    for (int i = 0; i < tech.results.length; i++) {
      // ignore: use_string_buffers
      result += "\n   " + tech.results[i].format(1, 3);
    }
    String expStr = "";
    for (int i = 0; i < pairs.length; i++) {
      // ignore: use_string_buffers
      expStr += "\n   " + pairs[i].outPoint.format(1, 3);
    }
    args.error("Unexpected number of results from debugging technique: " +
        "\n   Expected: $expStr" +
        "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    for (int i = 0; i < tech.results.length; i++) {
      final Point3 expPnt = pairs[i].outPoint;
      final Point3 result = tech.results[i];
      if (expPnt != result) {
        args.error("Unexpected result from debugging technique at $i: " +
            "\n   Expected: $expPnt" +
            "\n   Gotten:   ${result.x}, ${result.y}, ${result.z}\n\n");
      }
    }
  }
}

void addCraftTests(TestManager tests) {
  tests.add("Test of craft example world getBlock", (TestArgs args) {
    final craft.World world = craft.World(null, craft.CheckersGenerator());
    //                            start location         exp chunk   exp block
    //                           z       y       z         x    z    x   y   z
    _checkGetBlock(args, world, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.001, 0.0, 0.0, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.001, 0.0, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, 0.001, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.999, 0.0, 0.0, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.999, 0.0, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, 0.999, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.999, 0.999, 0.999, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, -0.001, 0.0, 0.0, -16, 0, 15, 0, 0);
    _checkGetBlock(args, world, -0.999, 0.0, 0.0, -16, 0, 15, 0, 0);
    _checkGetBlock(args, world, -0.001, 0.0, 0.0, -16, 0, 15, 0, 0);
    _checkGetBlock(args, world, -0.001, 0.0, 0.001, -16, 0, 15, 0, 0);
    _checkGetBlock(args, world, -0.999, 0.0, 0.999, -16, 0, 15, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, -0.001, 0, -16, 0, 0, 15);
    _checkGetBlock(args, world, 0.001, 0.0, -0.001, 0, -16, 0, 0, 15);
    _checkGetBlock(args, world, 0.0, 0.0, -0.999, 0, -16, 0, 0, 15);
    _checkGetBlock(args, world, 0.999, 0.0, -0.999, 0, -16, 0, 0, 15);
    _checkGetBlock(args, world, -0.001, 0.0, -0.001, -16, -16, 15, 0, 15);
    _checkGetBlock(args, world, -0.999, 0.0, -0.999, -16, -16, 15, 0, 15);
    _checkGetBlock(args, world, -0.999, 0.0, -0.001, -16, -16, 15, 0, 15);
    _checkGetBlock(args, world, -0.001, 0.0, -0.999, -16, -16, 15, 0, 15);
    _checkGetBlock(args, world, 1.0, 0.0, 0.0, 0, 0, 1, 0, 0);
    _checkGetBlock(args, world, 0.0, 1.0, 0.0, 0, 0, 0, 1, 0);
    _checkGetBlock(args, world, 0.0, 0.0, 1.0, 0, 0, 0, 0, 1);
    _checkGetBlock(args, world, 1.001, 0.0, 0.0, 0, 0, 1, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, 1.001, 0, 0, 0, 0, 1);
    _checkGetBlock(args, world, -1.0, 0.0, 0.0, -16, 0, 15, 0, 0);
    _checkGetBlock(args, world, 0.0, -1.0, 0.0, 0, 0, 0, -1, 0);
    _checkGetBlock(args, world, 0.0, 0.0, -1.0, 0, -16, 0, 0, 15);
    _checkGetBlock(args, world, -1.001, 0.0, 0.0, -16, 0, 14, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, -1.001, 0, -16, 0, 0, 14);
    _checkGetBlock(args, world, 0.0, 0.0, -14.157, 0, -16, 0, 0, 1);
    _checkGetBlock(args, world, 0.0, 0.0, -15.157, 0, -16, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, -16.157, 0, -32, 0, 0, 15);
    _checkGetBlock(args, world, 0.0, 0.0, 18.0, 0, 16, 0, 0, 2);
    _checkGetBlock(args, world, 0.0, 0.0, 17.0, 0, 16, 0, 0, 1);
    _checkGetBlock(args, world, 0.0, 0.0, 16.0, 0, 16, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, 15.0, 0, 0, 0, 0, 15);
    _checkGetBlock(args, world, 0.0, 0.0, 14.0, 0, 0, 0, 0, 14);
    _checkGetBlock(args, world, 0.0, 0.0, 13.0, 0, 0, 0, 0, 13);
    _checkGetBlock(args, world, 0.0, 0.0, 12.0, 0, 0, 0, 0, 12);
    _checkGetBlock(args, world, 0.0, 0.0, 11.0, 0, 0, 0, 0, 11);
    _checkGetBlock(args, world, 0.0, 0.0, 10.0, 0, 0, 0, 0, 10);
    _checkGetBlock(args, world, 0.0, 0.0, 9.0, 0, 0, 0, 0, 9);
    _checkGetBlock(args, world, 0.0, 0.0, 8.0, 0, 0, 0, 0, 8);
    _checkGetBlock(args, world, 0.0, 0.0, 7.0, 0, 0, 0, 0, 7);
    _checkGetBlock(args, world, 0.0, 0.0, 6.0, 0, 0, 0, 0, 6);
    _checkGetBlock(args, world, 0.0, 0.0, 5.0, 0, 0, 0, 0, 5);
    _checkGetBlock(args, world, 0.0, 0.0, 4.0, 0, 0, 0, 0, 4);
    _checkGetBlock(args, world, 0.0, 0.0, 3.0, 0, 0, 0, 0, 3);
    _checkGetBlock(args, world, 0.0, 0.0, 2.0, 0, 0, 0, 0, 2);
    _checkGetBlock(args, world, 0.0, 0.0, 1.0, 0, 0, 0, 0, 1);
    _checkGetBlock(args, world, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, -1.0, 0, -16, 0, 0, 15);
    _checkGetBlock(args, world, 0.0, 0.0, -2.0, 0, -16, 0, 0, 14);
    _checkGetBlock(args, world, 0.0, 0.0, -3.0, 0, -16, 0, 0, 13);
    _checkGetBlock(args, world, 0.0, 0.0, -4.0, 0, -16, 0, 0, 12);
    _checkGetBlock(args, world, 0.0, 0.0, -5.0, 0, -16, 0, 0, 11);
    _checkGetBlock(args, world, 0.0, 0.0, -6.0, 0, -16, 0, 0, 10);
    _checkGetBlock(args, world, 0.0, 0.0, -7.0, 0, -16, 0, 0, 9);
    _checkGetBlock(args, world, 0.0, 0.0, -8.0, 0, -16, 0, 0, 8);
    _checkGetBlock(args, world, 0.0, 0.0, -9.0, 0, -16, 0, 0, 7);
    _checkGetBlock(args, world, 0.0, 0.0, -10.0, 0, -16, 0, 0, 6);
    _checkGetBlock(args, world, 0.0, 0.0, -11.0, 0, -16, 0, 0, 5);
    _checkGetBlock(args, world, 0.0, 0.0, -12.0, 0, -16, 0, 0, 4);
    _checkGetBlock(args, world, 0.0, 0.0, -13.0, 0, -16, 0, 0, 3);
    _checkGetBlock(args, world, 0.0, 0.0, -14.0, 0, -16, 0, 0, 2);
    _checkGetBlock(args, world, 0.0, 0.0, -15.0, 0, -16, 0, 0, 1);
    _checkGetBlock(args, world, 0.0, 0.0, -16.0, 0, -16, 0, 0, 0);
    _checkGetBlock(args, world, 0.0, 0.0, -17.0, 0, -32, 0, 0, 15);
    _checkGetBlock(args, world, 0.0, 0.0, -18.0, 0, -32, 0, 0, 14);
    _checkGetBlock(args, world, 0.0, 0.0, -19.0, 0, -32, 0, 0, 13);
  });
  tests.add("Test of craft example world collide with floor", (TestArgs args) {
    final craft.World world = craft.World(null, craft.FlatGenerator(8, 9));
    world.prepareChunk(0, 0);
    // Falling straight down to the ground and standing on ground.
    _checkCollide(args, world, 0.5, 12.0, 0.5, 0.0, -5.0, 0.0, 0.5, 11.5, 0.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 14.0, 0.5, 0.0, -5.0, 0.0, 0.5, 11.5, 0.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 14.0, 0.5, 0.0, -1.0, 0.0, 0.5, 13.0, 0.5, HitRegion.None);
    _checkCollide(args, world, 0.5, 11.5, 0.5, 0.0, -5.0, 0.0, 0.5, 11.5, 0.5, HitRegion.YPos);
    // Falling at an angle and moving on the ground.
    _checkCollide(args, world, 0.5, 12.0, 0.5, 1.0, -5.0, 1.0, 1.5, 11.5, 1.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 11.5, 0.5, 1.0, -5.0, 1.0, 1.5, 11.5, 1.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 12.0, 0.5, 1.0, -5.0, -1.0, 1.5, 11.5, -0.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 11.5, 0.5, 1.0, -5.0, -1.0, 1.5, 11.5, -0.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 12.0, 0.5, -1.0, -5.0, 1.0, -0.5, 11.5, 1.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 11.5, 0.5, -1.0, -5.0, 1.0, -0.5, 11.5, 1.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 12.0, 0.5, -1.0, -5.0, -1.0, -0.5, 11.5, -0.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 11.5, 0.5, -1.0, -5.0, -1.0, -0.5, 11.5, -0.5, HitRegion.YPos);
    // Falling onto a block and falling beside a block.
    world.getBlock(0.0, 10.0, 0.0)?.value = craft.BlockType.Turf;
    _checkCollide(args, world, 0.5, 14.0, 0.5, 0.0, -5.0, 0.0, 0.5, 12.5, 0.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 14.0, 1.5, 0.0, -5.0, 0.0, 0.5, 11.5, 1.5, HitRegion.YPos);
    _checkCollide(args, world, 0.5, 14.0, -0.5, 0.0, -5.0, 0.0, 0.5, 11.5, -0.5, HitRegion.YPos);
    _checkCollide(args, world, 1.5, 14.0, 0.5, 0.0, -5.0, 0.0, 1.5, 11.5, 0.5, HitRegion.YPos);
    _checkCollide(args, world, -0.5, 14.0, 0.5, 0.0, -5.0, 0.0, -0.5, 11.5, 0.5, HitRegion.YPos);
    // Running into a block.
    _checkCollide(args, world, 2.5, 11.5, 0.5, -5.0, 0.0, 0.0, 1.25, 11.5, 0.5, HitRegion.XPos);
    _checkCollide(args, world, 2.5, 11.5, 0.5, -5.0, -5.0, 0.0, 1.25, 11.5, 0.5, HitRegion.XPos | HitRegion.YPos);
    _checkCollide(args, world, -1.5, 11.5, 0.5, 5.0, 0.0, 0.0, -0.25, 11.5, 0.5, HitRegion.XNeg);
    _checkCollide(args, world, 0.5, 11.5, 2.5, 0.0, 0.0, -5.0, 0.5, 11.5, 1.25, HitRegion.ZPos);
    _checkCollide(args, world, 0.5, 11.5, -1.5, 0.0, 0.0, 5.0, 0.5, 11.5, -0.25, HitRegion.ZNeg);
  });
}

void _checkGetBlock(TestArgs args, craft.World world, double x, double y, double z, int expChunkX, int expChunkZ,
    int expBlockX, int expBlockY, int expBlockZ) {
  final craft.BlockInfo? block = world.getBlock(x, y, z);
  if (block == null) {
    args.error("Testing getBlock($x, $y, $z): Failed\n");
    args.notice("  Block was null\n");
    args.info("\n");
    return;
  }
  if (block.chunkX != expChunkX ||
      block.chunkZ != expChunkZ ||
      block.x != expBlockX ||
      block.y != expBlockY ||
      block.z != expBlockZ) {
    args.error("Testing getBlock($x, $y, $z): Failed\n");
    args.notice("  Expected: $expChunkX, $expChunkZ, $expBlockX, $expBlockY, $expBlockZ\n");
    args.notice("  Gotten:   ${block.chunkX}, ${block.chunkZ}, ${block.x}, ${block.y}, ${block.z}\n");
    if (block.chunkX != expChunkX) args.error("  Chunk X value ${block.chunkX} should be $expChunkX.\n");
    if (block.chunkZ != expChunkZ) args.error("  Chunk Z value ${block.chunkZ} should be $expChunkZ.\n");
    if (block.x != expBlockX) args.error("  Block X value ${block.x} should be $expBlockX.\n");
    if (block.y != expBlockY) args.error("  Block Y value ${block.y} should be $expBlockY.\n");
    if (block.z != expBlockZ) args.error("  Block Z value ${block.z} should be $expBlockZ.\n");
    args.info("\n");
    return;
  }
  args.info("Testing getBlock($x, $y, $z): Passed\n");
}

void _checkCollide(TestArgs args, craft.World world, double locX, double locY, double locZ, double vecX, double vecY,
    double vecZ, double expX, double expY, double expZ, HitRegion expTouching) {
  final craft.Collider collider = craft.Collider(world);
  final Region3 region = Region3(-0.25, -1.5, -0.25, 0.5, 2.0, 0.5);
  final Point3 loc = Point3(locX, locY, locZ);
  final Vector3 vector = Vector3(vecX, vecY, vecZ);
  final Point3 expLocation = Point3(expX, expY, expZ);
  collider.collide(region, loc, vector);
  if ((collider.location != expLocation) || (collider.touching != expTouching)) {
    args.error("Testing collide: Failed\n");
    args.error("  Region:   $region\n");
    args.error("  Start:    $loc\n");
    args.error("  Vector:   $vector\n");
    args.error("  Expected: Collider($expLocation, $expTouching)\n");
    args.error("  Gotten:   $collider\n");
    args.info("\n");
  } else {
    args.info("Testing collide: Passed\n");
    args.info("  Region:   $region\n");
    args.info("  Start:    $loc\n");
    args.info("  Vector:   $vector\n");
    args.info("  Gotten:   $collider\n");
    args.info("\n");
  }
}

void addChessTests(TestManager tests) {
  void _checkLines(TestArgs args, String resultStr, List<String> expLines) {
    final String expStr = expLines.join("\n");
    if (expStr != resultStr) {
      args.warning("Expected:\n  ${expStr.replaceAll("\n", "\n  ")}\n");
      args.warning("Result:\n  ${resultStr.replaceAll("\n", "\n  ")}\n");
      args.error("Unexpected string of a chess game state.\n\n");
    } else {
      args.info("$resultStr\n\n");
    }
  }

  void checkIsChecked(TestArgs args, bool expIsCheckedWhite, bool expIsCheckedBlack, List<String> data) {
    final chess.State state = chess.parseState(data);
    args.info("State:\n$state\n");
    if (state.isChecked(true) != expIsCheckedWhite) {
      args.error("Expected IsChecked(white) to return $expIsCheckedWhite but it wasn't.\n");
    }
    if (state.isChecked(false) != expIsCheckedBlack) {
      args.error("Expected IsChecked(black) to return $expIsCheckedBlack but it wasn't\n");
    }
  }

  void checkMovements(TestArgs args, chess.State state, String itemStr, List<String> expMovements) {
    args.info("moving $itemStr\n");
    final item = chess.parseTileValue(itemStr);
    final loc = state.findItem(item);
    final moves = state.getMovements(loc);
    final parts = List<String>.filled(moves.length, '');
    final grid = chess.StringGrid();
    grid.setCell(loc.row - 1, loc.column - 1, "O");
    for (int i = moves.length - 1; i >= 0; --i) {
      final move = moves[i];
      parts[i] = move.toString();
      grid.setCell(move.destination.row - 1, move.destination.column - 1, "X");
    }
    args.info("Movements:\n$grid\n");
    _checkLines(args, parts.join("\n"), expMovements);
  }

  void checkLoc(TestArgs args, int row, int column, bool expOnBoard, int expIndex, String expNotation) {
    final loc = chess.Location(row, column);
    if (loc.row != row) args.error("Unexpected row: ${loc.row} != $row\n");
    if (loc.column != column) args.error("Unexpected column: ${loc.column} != $column\n");
    if (loc.onBoard != expOnBoard) args.error("Unexpected onBoard: ${loc.onBoard} != $expOnBoard\n");
    if (loc.index != expIndex) args.error("Unexpected index: ${loc.index} != $expIndex\n");
    if (loc.toNotation() != expNotation) args.error("Unexpected notation: ${loc.toNotation()} != $expNotation\n");
    int row2 = row, column2 = column;
    if (!loc.onBoard) row2 = column2 = 0;
    final loc2 = chess.locationFromIndex(expIndex);
    if (loc2.row != row2) args.error("Unexpected row from index: ${loc2.row} != $row2\n");
    if (loc2.column != column2) args.error("Unexpected column from index: ${loc2.column} != $column2\n");
  }

  tests.add("Test of chess location", (TestArgs args) {
    checkLoc(args, 0, 0, false, -1, "xx");
    checkLoc(args, 1, 1, true, 0, "a8");
    checkLoc(args, 2, 2, true, 9, "b7");
    checkLoc(args, 3, 3, true, 18, "c6");
    checkLoc(args, 4, 4, true, 27, "d5");
    checkLoc(args, 5, 5, true, 36, "e4");
    checkLoc(args, 6, 6, true, 45, "f3");
    checkLoc(args, 7, 7, true, 54, "g2");
    checkLoc(args, 8, 8, true, 63, "h1");
    checkLoc(args, 4, 7, true, 30, "g5");
    checkLoc(args, 9, 1, false, -1, "xx");
    checkLoc(args, 1, 9, false, -1, "xx");
  });
  tests.add("Test of chess state parse and toString", (TestArgs args) {
    chess.State state = chess.makeInitialState();
    _checkLines(args, state.toString(), [
      "   1  2  3  4  5  6  7  8",
      "1 |BR|BH|BB|BK|BQ|BB|BH|BR|",
      "2 |BP|BP|BP|BP|BP|BP|BP|BP|",
      "3 |  |  |  |  |  |  |  |  |",
      "4 |  |  |  |  |  |  |  |  |",
      "5 |  |  |  |  |  |  |  |  |",
      "6 |  |  |  |  |  |  |  |  |",
      "7 |WP|WP|WP|WP|WP|WP|WP|WP|",
      "8 |WR|WH|WB|WK|WQ|WB|WH|WR|"
    ]);
    _checkLines(args, state.toString(showCount: true), [
      "    1   2   3   4   5   6   7   8",
      "1 |BR1|BH1|BB1|BK1|BQ1|BB2|BH2|BR2|",
      "2 |BP1|BP2|BP3|BP4|BP5|BP6|BP7|BP8|",
      "3 |   |   |   |   |   |   |   |   |",
      "4 |   |   |   |   |   |   |   |   |",
      "5 |   |   |   |   |   |   |   |   |",
      "6 |   |   |   |   |   |   |   |   |",
      "7 |WP1|WP2|WP3|WP4|WP5|WP6|WP7|WP8|",
      "8 |WR1|WH1|WB1|WK1|WQ1|WB2|WH2|WR2|"
    ]);
    _checkLines(args, state.toString(showLabels: false), [
      "BR|BH|BB|BK|BQ|BB|BH|BR",
      "BP|BP|BP|BP|BP|BP|BP|BP",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "WP|WP|WP|WP|WP|WP|WP|WP",
      "WR|WH|WB|WK|WQ|WB|WH|WR"
    ]);
    state = chess.parseState([
      "BR|BH|BB|BK|BQ|BB|BH|BR",
      "BP|BP|BP|BP|BP|BP|BP|BP",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "WP|WP|WP|WP|WP|WP|WP|WP",
      "WR|WH|WB|WK|WQ|WB|WH|WR"
    ]);
    _checkLines(args, state.toString(showCount: true), [
      "    1   2   3   4   5   6   7   8",
      "1 |BR1|BH1|BB1|BK1|BQ1|BB2|BH2|BR2|",
      "2 |BP1|BP2|BP3|BP4|BP5|BP6|BP7|BP8|",
      "3 |   |   |   |   |   |   |   |   |",
      "4 |   |   |   |   |   |   |   |   |",
      "5 |   |   |   |   |   |   |   |   |",
      "6 |   |   |   |   |   |   |   |   |",
      "7 |WP1|WP2|WP3|WP4|WP5|WP6|WP7|WP8|",
      "8 |WR1|WH1|WB1|WK1|WQ1|WB2|WH2|WR2|"
    ]);
    // Test complex state missing pieces and having multiple queens
    state = chess.parseState([
      " BR|   | BB| BK|   | BB| BH|   ",
      " WP|   |   |+BQ|   | BP|+BQ|+BQ",
      "   |+WP|   |   |+BP|   |   |   ",
      "   |   |+WP|+BP|   |   |   |   ",
      "   |   |+BP|+WP|   |   |   |   ",
      "   |+BP|   |   |+WP|   |   |   ",
      " BP|   |   |+WK|   |+WP|+WQ|+WQ",
      "   | WH| WB|   |+WQ| WB|   | WR"
    ]);
    _checkLines(args, state.toString(showCount: true), [
      "    1    2    3    4    5    6    7    8",
      "1 | BR1|    | BB1| BK1|    | BB2| BH1|    |",
      "2 | WP1|    |    |+BQ1|    | BP1|+BQ2|+BQ3|",
      "3 |    |+WP2|    |    |+BP2|    |    |    |",
      "4 |    |    |+WP3|+BP3|    |    |    |    |",
      "5 |    |    |+BP4|+WP4|    |    |    |    |",
      "6 |    |+BP5|    |    |+WP5|    |    |    |",
      "7 | BP6|    |    |+WK1|    |+WP6|+WQ1|+WQ2|",
      "8 |    | WH1| WB1|    |+WQ3| WB2|    | WR1|"
    ]);
    state = chess.parseState([
      "BR2|BH2|BB2|BK1|BQ1|BB1|BH1|BR1",
      "BP8|BP7|BP6|BP5|BP4|BP3|BP2|BP1",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "WP8|WP7|WP6|WP5|WP4|WP3|WP2|WP1",
      "WR2|WH2|WB2|WK1|WQ1|WB1|WH1|WR1"
    ]);
    _checkLines(args, state.toString(showCount: true), [
      "    1   2   3   4   5   6   7   8",
      "1 |BR2|BH2|BB2|BK1|BQ1|BB1|BH1|BR1|",
      "2 |BP8|BP7|BP6|BP5|BP4|BP3|BP2|BP1|",
      "3 |   |   |   |   |   |   |   |   |",
      "4 |   |   |   |   |   |   |   |   |",
      "5 |   |   |   |   |   |   |   |   |",
      "6 |   |   |   |   |   |   |   |   |",
      "7 |WP8|WP7|WP6|WP5|WP4|WP3|WP2|WP1|",
      "8 |WR2|WH2|WB2|WK1|WQ1|WB1|WH1|WR1|"
    ]);
  });
  tests.add("Test of chess checked condition determination", (TestArgs args) {
    checkIsChecked(args, false, false, [
      "  |  |  |BK|  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |WK|  |  |  |  "
    ]);
    checkIsChecked(args, true, true, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |BK|  |  |  |  ",
      "  |  |  |WK|  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkIsChecked(args, false, true, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |BK|  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |WQ|  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |WK|  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkIsChecked(args, false, true, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |BK|  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |BR|  |  |  |  |  ",
      "  |WK|  |  |  |  |WR|  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkIsChecked(args, false, true, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |BK|  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |WB|  |  |  |  |  ",
      "  |WK|  |  |  |  |BB|  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkIsChecked(args, true, true, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |BK|  ",
      "  |  |  |  |  |WP|  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |BP|  |  |  |  |  ",
      "  |WK|  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkIsChecked(args, false, false, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |WK|  ",
      "  |  |  |  |  |BP|  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |WP|  |  |  |  |  ",
      "  |BK|  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkIsChecked(args, true, true, [
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |BK|  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |WH|  |  ",
      "  |  |  |  |BH|  |  |  ",
      "  |  |WK|  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
  });
  tests.add("Test of chess state movements of pawns", (final args) {
    chess.State state = chess.makeInitialState();
    checkMovements(args, state, "WP1", ["Pawn move to 6 1, 7 1 => 6 1", "Pawn move to 5 1, 7 1 => 5 1"]);
    checkMovements(args, state, "WP4", ["Pawn move to 6 4, 7 4 => 6 4", "Pawn move to 5 4, 7 4 => 5 4"]);
    checkMovements(args, state, "WP8", ["Pawn move to 6 8, 7 8 => 6 8", "Pawn move to 5 8, 7 8 => 5 8"]);
    checkMovements(args, state, "BP1", ["Pawn move to 3 1, 2 1 => 3 1", "Pawn move to 4 1, 2 1 => 4 1"]);
    checkMovements(args, state, "BP4", ["Pawn move to 3 4, 2 4 => 3 4", "Pawn move to 4 4, 2 4 => 4 4"]);
    checkMovements(args, state, "BP8", ["Pawn move to 3 8, 2 8 => 3 8", "Pawn move to 4 8, 2 8 => 4 8"]);
    chess.State state2 = chess.parseState([
      " BR1| BH1| BB1| BK1| BQ1| BB2| BH2| BR2",
      "    | BP2| BP3|    | BP5| BP6| BP7|    ",
      "    |    |    |    |    |    |    |    ",
      "    |    |    |    |    |    |    |    ",
      "+BP1|+WP2|+WP3|+BP4|+WP5|    |+WP7|+BP8",
      "    |    |    |    |    |    |    |    ",
      " WP1|    |    | WP4|    | WP6|    | WP8",
      " WR1| WH1| WB1| WK1| WQ1| WB2| WH2| WR2"
    ]);
    state2.prev = state;
    checkMovements(
        args, state2, "BP1", ["Pawn move to 6 1, 5 1 => 6 1", "Pawn en passent Pawn at 6 2, 5 1 => 6 2, 5 2 => null"]);
    checkMovements(args, state2, "BP4", [
      "Pawn move to 6 4, 5 4 => 6 4",
      "Pawn en passent Pawn at 6 3, 5 4 => 6 3, 5 3 => null",
      "Pawn en passent Pawn at 6 5, 5 4 => 6 5, 5 5 => null"
    ]);
    checkMovements(
        args, state2, "BP8", ["Pawn move to 6 8, 5 8 => 6 8", "Pawn en passent Pawn at 6 7, 5 8 => 6 7, 5 7 => null"]);
    state2 = chess.parseState([
      " BR1| BH1| BB1| BK1| BQ1| BB2| BH2| BR2",
      " BP1|    |    | BP4|    | BP6|    | BP8",
      "    |    |    |    |    |    |    |    ",
      "+WP1|+BP2|+BP3|+WP4|+BP5|    |+BP7|+WP8",
      "    |    |    |    |    |    |    |    ",
      "    |    |    |    |    |    |    |    ",
      "    | WP2| WP3|    | WP5| WP6| WP7|    ",
      " WR1| WH1| WB1| WK1| WQ1| WB2| WH2| WR2"
    ]);
    state2.prev = state;
    checkMovements(
        args, state2, "WP1", ["Pawn move to 3 1, 4 1 => 3 1", "Pawn en passent Pawn at 3 2, 4 1 => 3 2, 4 2 => null"]);
    checkMovements(args, state2, "WP4", [
      "Pawn move to 3 4, 4 4 => 3 4",
      "Pawn en passent Pawn at 3 3, 4 4 => 3 3, 4 3 => null",
      "Pawn en passent Pawn at 3 5, 4 4 => 3 5, 4 5 => null"
    ]);
    checkMovements(
        args, state2, "WP8", ["Pawn move to 3 8, 4 8 => 3 8", "Pawn en passent Pawn at 3 7, 4 8 => 3 7, 4 7 => null"]);
    state = chess.parseState([
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "BQ|  |  |  |WK|  |  |  ",
      "  |  |  |WP|  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkMovements(args, state, "WP1", ["Pawn move to 6 4, 7 4 => 6 4"]);
  });
  tests.add("Test of chess state movements of knights", (TestArgs args) {
    chess.State state = chess.parseState([
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |+BH1|   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BH1", [
      "Knight move to 6 4, 4 3 => 6 4",
      "Knight move to 6 2, 4 3 => 6 2",
      "Knight move to 5 5, 4 3 => 5 5",
      "Knight move to 3 5, 4 3 => 3 5",
      "Knight move to 2 4, 4 3 => 2 4",
      "Knight move to 2 2, 4 3 => 2 2",
      "Knight move to 5 1, 4 3 => 5 1",
      "Knight move to 3 1, 4 3 => 3 1"
    ]);
    state = chess.parseState([
      "   |    |    |    |   |   |   |   ",
      "   |+BH1|    |    |   |   |   |   ",
      "   |    |    |+BP1|   |   |   |   ",
      "   |    |+WP1|    |   |   |   |   ",
      "   |    |    |    |   |   |   |   ",
      "   |    |    |    |   |   |   |   ",
      "   |    |    |    |   |   |   |   ",
      "   |    |    |    |   |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BH1", [
      "Knight take Pawn at 4 3, 2 2 => 4 3, 4 3 => null",
      "Knight move to 4 1, 2 2 => 4 1",
      "Knight move to 1 4, 2 2 => 1 4"
    ]);
    state = chess.parseState([
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "BQ|  |  |  |  |  |WK|  ",
      "  |  |  |WH|  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkMovements(args, state, "WH1", ["Knight move to 3 6, 4 4 => 3 6", "Knight move to 3 2, 4 4 => 3 2"]);
  });
  tests.add("Test of chess state movements of bishops", (TestArgs args) {
    chess.State state = chess.parseState([
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |+BB1|   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "WB1", []); // Check off board isn't moved
    checkMovements(args, state, "BB1", [
      "Bishop move to 5 4, 4 3 => 5 4",
      "Bishop move to 6 5, 4 3 => 6 5",
      "Bishop move to 7 6, 4 3 => 7 6",
      "Bishop move to 8 7, 4 3 => 8 7",
      "Bishop move to 5 2, 4 3 => 5 2",
      "Bishop move to 6 1, 4 3 => 6 1",
      "Bishop move to 3 2, 4 3 => 3 2",
      "Bishop move to 2 1, 4 3 => 2 1",
      "Bishop move to 3 4, 4 3 => 3 4",
      "Bishop move to 2 5, 4 3 => 2 5",
      "Bishop move to 1 6, 4 3 => 1 6"
    ]);
    state = chess.parseState([
      "    |    |    |   |    |   |   |   ",
      "+WP1|    |    |   |+BP1|   |   |   ",
      "    |    |    |   |    |   |   |   ",
      "    |    |+WB1|   |    |   |   |   ",
      "    |+BP2|    |   |    |   |   |   ",
      "    |    |    |   |+WP2|   |   |   ",
      "    |    |    |   |    |   |   |   ",
      "    |    |    |   |    |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "WB1", [
      "Bishop move to 5 4, 4 3 => 5 4",
      "Bishop take Pawn at 5 2, 4 3 => 5 2, 5 2 => null",
      "Bishop move to 3 2, 4 3 => 3 2",
      "Bishop move to 3 4, 4 3 => 3 4",
      "Bishop take Pawn at 2 5, 4 3 => 2 5, 2 5 => null"
    ]);
  });
  tests.add("Test of chess state movements of rooks", (TestArgs args) {
    chess.State state = chess.parseState([
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |+BR1|   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   ",
      "   |   |    |   |   |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BR1", [
      "Rook move to 4 4, 4 3 => 4 4",
      "Rook move to 4 5, 4 3 => 4 5",
      "Rook move to 4 6, 4 3 => 4 6",
      "Rook move to 4 7, 4 3 => 4 7",
      "Rook move to 4 8, 4 3 => 4 8",
      "Rook move to 4 2, 4 3 => 4 2",
      "Rook move to 4 1, 4 3 => 4 1",
      "Rook move to 5 3, 4 3 => 5 3",
      "Rook move to 6 3, 4 3 => 6 3",
      "Rook move to 7 3, 4 3 => 7 3",
      "Rook move to 8 3, 4 3 => 8 3",
      "Rook move to 3 3, 4 3 => 3 3",
      "Rook move to 2 3, 4 3 => 2 3",
      "Rook move to 1 3, 4 3 => 1 3"
    ]);
    state = chess.parseState([
      "    |   |    |   |    |   |   |   ",
      "    |   |+BP1|   |    |   |   |   ",
      "    |   |    |   |    |   |   |   ",
      "+WP1|   |+WR1|   |+WP2|   |   |   ",
      "    |   |    |   |    |   |   |   ",
      "    |   |+BP2|   |    |   |   |   ",
      "    |   |    |   |    |   |   |   ",
      "    |   |    |   |    |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "WR1", [
      "Rook move to 4 4, 4 3 => 4 4",
      "Rook move to 4 2, 4 3 => 4 2",
      "Rook move to 5 3, 4 3 => 5 3",
      "Rook take Pawn at 6 3, 4 3 => 6 3, 6 3 => null",
      "Rook move to 3 3, 4 3 => 3 3",
      "Rook take Pawn at 2 3, 4 3 => 2 3, 2 3 => null"
    ]);
    state = chess.parseState([
      "BR1|   |   |BK1|   |   |   |BR2",
      "BP1|   |   |   |   |   |   |BP2",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "WP1|   |   |   |   |   |   |WP2",
      "WR1|   |   |WK1|   |   |   |WR2"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BR1", [
      "Rook move to 1 2, 1 1 => 1 2",
      "Rook move to 1 3, 1 1 => 1 3",
      "Rook castles with King, 1 1 => 1 3, 1 4 => 1 2"
    ]);
    checkMovements(args, state, "BR2", [
      "Rook move to 1 7, 1 8 => 1 7",
      "Rook move to 1 6, 1 8 => 1 6",
      "Rook move to 1 5, 1 8 => 1 5",
      "Rook castles with King, 1 8 => 1 5, 1 4 => 1 6"
    ]);
    checkMovements(args, state, "WR1", [
      "Rook move to 8 2, 8 1 => 8 2",
      "Rook move to 8 3, 8 1 => 8 3",
      "Rook castles with King, 8 1 => 8 3, 8 4 => 8 2"
    ]);
    checkMovements(args, state, "WR2", [
      "Rook move to 8 7, 8 8 => 8 7",
      "Rook move to 8 6, 8 8 => 8 6",
      "Rook move to 8 5, 8 8 => 8 5",
      "Rook castles with King, 8 8 => 8 5, 8 4 => 8 6"
    ]);
    state = chess.parseState([
      " BR1|   |   |+BK1|   |   |   | BR2",
      " BP1|   |   |    |   |   |   | BP2",
      "    |   |   |    |   |   |   |    ",
      "    |   |   |    |   |   |   |    ",
      "    |   |   |    |   |   |   |    ",
      "    |   |   |    |   |   |   |    ",
      " WP1|   |   |    |   |   |   | WP2",
      "+WR1|   |   | WK1|   |   |   |+WR2"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BR1", ["Rook move to 1 2, 1 1 => 1 2", "Rook move to 1 3, 1 1 => 1 3"]);
    checkMovements(args, state, "BR2",
        ["Rook move to 1 7, 1 8 => 1 7", "Rook move to 1 6, 1 8 => 1 6", "Rook move to 1 5, 1 8 => 1 5"]);
    checkMovements(args, state, "WR1", ["Rook move to 8 2, 8 1 => 8 2", "Rook move to 8 3, 8 1 => 8 3"]);
    checkMovements(args, state, "WR2",
        ["Rook move to 8 7, 8 8 => 8 7", "Rook move to 8 6, 8 8 => 8 6", "Rook move to 8 5, 8 8 => 8 5"]);
  });
  tests.add("Test of chess state movements of kings", (TestArgs args) {
    chess.State state = chess.parseState([
      "BR1|   |   |BK1|   |   |   |BR2",
      "BP1|   |   |   |   |   |   |BP2",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "WP1|   |   |   |   |   |   |WP2",
      "WR1|   |   |WK1|   |   |   |WR2"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BK1", [
      "King move to 2 5, 1 4 => 2 5",
      "King move to 2 4, 1 4 => 2 4",
      "King move to 2 3, 1 4 => 2 3",
      "King move to 1 3, 1 4 => 1 3",
      "King move to 1 5, 1 4 => 1 5",
      "King castles with Rook, 1 4 => 1 2, 1 1 => 1 3",
      "King castles with Rook, 1 4 => 1 6, 1 8 => 1 5"
    ]);
    checkMovements(args, state, "WK1", [
      "King move to 8 3, 8 4 => 8 3",
      "King move to 7 3, 8 4 => 7 3",
      "King move to 7 4, 8 4 => 7 4",
      "King move to 7 5, 8 4 => 7 5",
      "King move to 8 5, 8 4 => 8 5",
      "King castles with Rook, 8 4 => 8 2, 8 1 => 8 3",
      "King castles with Rook, 8 4 => 8 6, 8 8 => 8 5"
    ]);
    state = chess.parseState([
      " BR1|   |   |+BK1|   |   |   | BR2",
      " BP1|   |   |    |   |   |   | BP2",
      "    |   |   |    |   |   |   |    ",
      "    |   |   |    |   |   |   |    ",
      "    |   |   |    |   |   |   |    ",
      "    |   |   |    |   |   |   |    ",
      " WP1|   |   |    |   |   |   | WP2",
      "+WR1|   |   | WK1|   |   |   |+WR2"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BK1", [
      "King move to 2 5, 1 4 => 2 5",
      "King move to 2 4, 1 4 => 2 4",
      "King move to 2 3, 1 4 => 2 3",
      "King move to 1 3, 1 4 => 1 3",
      "King move to 1 5, 1 4 => 1 5"
    ]);
    checkMovements(args, state, "WK1", [
      "King move to 8 3, 8 4 => 8 3",
      "King move to 7 3, 8 4 => 7 3",
      "King move to 7 4, 8 4 => 7 4",
      "King move to 7 5, 8 4 => 7 5",
      "King move to 8 5, 8 4 => 8 5"
    ]);
    state = chess.parseState([
      "   |   |    |    |    |   |   |   ",
      "   |   |    |    |    |   |   |   ",
      "   |   |    |    |    |   |   |   ",
      "   |   |    |+WP2|+WP1|   |   |   ",
      "   |   |+BP3|+WK1|+WP3|   |   |   ",
      "   |   |    |+BP2|+BP1|   |   |   ",
      "   |   |    |    |    |   |   |   ",
      "   |   |    |    |    |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "WK1", [
      "King take Pawn at 6 5, 5 4 => 6 5, 6 5 => null",
      "King move to 6 3, 5 4 => 6 3",
      "King take Pawn at 5 3, 5 4 => 5 3, 5 3 => null",
      "King move to 4 3, 5 4 => 4 3"
    ]);
    state = chess.parseState([
      "BR1|BB1|   |BK1|   |   |   |BR2",
      "BP1|   |BP3|BP4|BP5|   |   |BP8",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "WP1|   |WP3|WP4|WP5|   |   |WP8",
      "WR1|WB1|   |WK1|   |   |   |WR2"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BK1", [
      "King move to 1 3, 1 4 => 1 3",
      "King move to 1 5, 1 4 => 1 5",
      "King castles with Rook, 1 4 => 1 6, 1 8 => 1 5"
    ]);
    checkMovements(args, state, "WK1", [
      "King move to 8 3, 8 4 => 8 3",
      "King move to 8 5, 8 4 => 8 5",
      "King castles with Rook, 8 4 => 8 6, 8 8 => 8 5"
    ]);
    state = chess.parseState([
      "BR1|   |   |BK1|   |   |BB2|BR2",
      "BP1|   |BP3|BP4|BP5|   |   |BP8",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "   |   |   |   |   |   |   |   ",
      "WP1|   |WP3|WP4|WP5|   |   |WP8",
      "WR1|   |   |WK1|   |   |WB2|WR2"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BK1", [
      "King move to 1 3, 1 4 => 1 3",
      "King move to 1 5, 1 4 => 1 5",
      "King castles with Rook, 1 4 => 1 2, 1 1 => 1 3"
    ]);
    checkMovements(args, state, "WK1", [
      "King move to 8 3, 8 4 => 8 3",
      "King move to 8 5, 8 4 => 8 5",
      "King castles with Rook, 8 4 => 8 2, 8 1 => 8 3"
    ]);
  });
  tests.add("Test of chess state movements of queens", (TestArgs args) {
    chess.State state = chess.parseState([
      "+WQ1|   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |    ",
      "    |   |   |   |   |   |   |+BQ1"
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "BQ1", [
      "Queen move to 8 7, 8 8 => 8 7",
      "Queen move to 8 6, 8 8 => 8 6",
      "Queen move to 8 5, 8 8 => 8 5",
      "Queen move to 8 4, 8 8 => 8 4",
      "Queen move to 8 3, 8 8 => 8 3",
      "Queen move to 8 2, 8 8 => 8 2",
      "Queen move to 8 1, 8 8 => 8 1",
      "Queen move to 7 7, 8 8 => 7 7",
      "Queen move to 6 6, 8 8 => 6 6",
      "Queen move to 5 5, 8 8 => 5 5",
      "Queen move to 4 4, 8 8 => 4 4",
      "Queen move to 3 3, 8 8 => 3 3",
      "Queen move to 2 2, 8 8 => 2 2",
      "Queen take Queen at 1 1, 8 8 => 1 1, 1 1 => null",
      "Queen move to 7 8, 8 8 => 7 8",
      "Queen move to 6 8, 8 8 => 6 8",
      "Queen move to 5 8, 8 8 => 5 8",
      "Queen move to 4 8, 8 8 => 4 8",
      "Queen move to 3 8, 8 8 => 3 8",
      "Queen move to 2 8, 8 8 => 2 8",
      "Queen move to 1 8, 8 8 => 1 8"
    ]);
    checkMovements(args, state, "WQ1", [
      "Queen move to 2 2, 1 1 => 2 2",
      "Queen move to 3 3, 1 1 => 3 3",
      "Queen move to 4 4, 1 1 => 4 4",
      "Queen move to 5 5, 1 1 => 5 5",
      "Queen move to 6 6, 1 1 => 6 6",
      "Queen move to 7 7, 1 1 => 7 7",
      "Queen take Queen at 8 8, 1 1 => 8 8, 8 8 => null",
      "Queen move to 2 1, 1 1 => 2 1",
      "Queen move to 3 1, 1 1 => 3 1",
      "Queen move to 4 1, 1 1 => 4 1",
      "Queen move to 5 1, 1 1 => 5 1",
      "Queen move to 6 1, 1 1 => 6 1",
      "Queen move to 7 1, 1 1 => 7 1",
      "Queen move to 8 1, 1 1 => 8 1",
      "Queen move to 1 2, 1 1 => 1 2",
      "Queen move to 1 3, 1 1 => 1 3",
      "Queen move to 1 4, 1 1 => 1 4",
      "Queen move to 1 5, 1 1 => 1 5",
      "Queen move to 1 6, 1 1 => 1 6",
      "Queen move to 1 7, 1 1 => 1 7",
      "Queen move to 1 8, 1 1 => 1 8"
    ]);
    state = chess.parseState([
      "   |   |    |    |    |   |   |   ",
      "   |   |    |    |    |   |   |   ",
      "   |BP2|    |    |    |   |   |   ",
      "   |   |    |+WP4|+WP1|   |   |   ",
      "   |   |+BP3|+WQ1|+WP3|   |   |   ",
      "   |   |    |+BP4|+BP1|   |   |   ",
      "   |WP2|    |    |    |   |   |   ",
      "   |   |    |    |    |   |   |   "
    ]);
    args.info("State:\n$state\n");
    checkMovements(args, state, "WQ1", [
      "Queen take Pawn at 6 5, 5 4 => 6 5, 6 5 => null",
      "Queen take Pawn at 6 4, 5 4 => 6 4, 6 4 => null",
      "Queen move to 6 3, 5 4 => 6 3",
      "Queen take Pawn at 5 3, 5 4 => 5 3, 5 3 => null",
      "Queen move to 4 3, 5 4 => 4 3",
      "Queen take Pawn at 3 2, 5 4 => 3 2, 3 2 => null"
    ]);
    state = chess.parseState([
      "BQ|  |  |  |  |  |WK|  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |WQ|  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  ",
      "  |  |  |  |  |  |  |  "
    ]);
    checkMovements(args, state, "WQ1",
        ["Queen move to 1 2, 3 4 => 1 2", "Queen move to 1 4, 3 4 => 1 4", "Queen move to 1 6, 3 4 => 1 6"]);
  });
}

/// The interface for the unit-test to callback with.
abstract class TestArgs extends Logger {
  /// The title of the unit-test.
  abstract String title;

  /// Marks this test as failed.
  void fail();

  /// Runs a benchmark for the approximately amount of time
  /// then prints the results of the benchmark.
  void bench(
    final double seconds,
    final void Function() hndl,
  );
}

/// The block for the unit-test output and the test arguments.
class TestBlock implements TestArgs {
  final TestManager _man;
  final DivElement _body;
  final DivElement _title;
  DateTime? _start;
  DateTime? _end;
  final void Function(TestArgs args) _test;
  String _testName;
  final bool _skip;
  bool _started;
  bool _failed;
  bool _finished;

  /// Creates a new test block for the given test.
  TestBlock(
    this._man,
    this._skip,
    this._test,
    this._testName,
  )   : this._body = DivElement()..className = "test_body body_hidden",
        this._title = DivElement()..className = "running top_header",
        this._start = null,
        this._end = null,
        this._started = false,
        this._failed = false,
        this._finished = false {
    this._title.onClick.listen(this._titleClicked);
    this._man._elem.children
      ..add(this._title)
      ..add(this._body);
    this._update();
  }

  /// Handles the test title clicked to show and hide the test output.
  void _titleClicked(
    final Object _,
  ) {
    if (this._body.className != "test_body body_hidden") {
      this._body.className = "test_body body_hidden";
    } else {
      this._body.className = "test_body body_shown";
    }
  }

  /// Updates the test header.
  void _update() {
    String time = "";
    final start = this._start;
    if (start != null) {
      DateTime? end = this._end;
      end ??= DateTime.now();
      time = ((end.difference(start).inMilliseconds) * 0.001).toStringAsFixed(2);
      time = "(${time}s)";
    }
    if (this._skip) {
      this._title
        ..className = "test_header skipped"
        ..text = "Skipped: ${this._testName}";
    } else if (!this._started) {
      this._title
        ..className = "test_header queued"
        ..text = "Queued: ${this._testName} ${time}";
    } else if (this._failed) {
      this._title
        ..className = "test_header failed"
        ..text = "Failed: ${this._testName} ${time}";
    } else if (this._finished) {
      this._title
        ..className = "test_header passed"
        ..text = "Passed: ${this._testName} ${time}";
    } else {
      this._title
        ..className = "test_header running"
        ..text = "Running: ${this._testName} ${time}";
    }
    this._man._update();
  }

  /// Runs this test asynchronously in the event loop.
  void run() => asy.Future(
        () {
          this._started = true;
          this._update();
        },
      ).then(
        (final _) {
          this._start = DateTime.now();
          if (!this._skip) {
            this._test(this);
          }
          this._end = DateTime.now();
        },
      ).catchError(
        (final dynamic exception, final StackTrace stackTrace) {
          this._end = DateTime.now();
          this.error("\nException: $exception");
          this.warning("\nStack: $stackTrace");
        },
      ).then(
        (final _) {
          this._finished = true;
          this._man._testDone(this);
          this._update();
        },
      );

  /// Adds a log to the output area of the test.
  void _addLog(
    final String text,
    final String type,
  ) {
    final log = this
        ._man
        ._escape
        .convert(text)
        .replaceAll(" ", "&nbsp;")
        .replaceAll("\n", "</dir><br class=\"$type\"><dir class=\"$type\">");
    final html = this._body.innerHtml ?? '';
    this._body.innerHtml = html + "<dir class=\"$type\">$log</dir>";
  }

  /// Prints text to the test's output console as an information.
  @override
  void info(
    final String text,
  ) =>
      this._addLog(text, "info_log");

  /// Prints text to the test's output console as a notice.
  @override
  void notice(
    final String text,
  ) =>
      this._addLog(text, "notice_log");

  /// Prints text to the test's output console as a warning.
  @override
  void warning(
    final String text,
  ) =>
      this._addLog(text, "warning_log");

  /// Prints text to the test's output console as an error.
  /// This will also mark this test as a failure.
  @override
  void error(
    final String text,
  ) {
    this._addLog(text, "error_log");
    this.fail();
  }

  /// The title of the unit-test.
  @override
  String get title => this._testName;

  @override
  set title(
    final String title,
  ) {
    this._testName = title;
    this._update();
  }

  /// Indicates if the test has been stated.
  bool get stated => this._started;

  /// Indicates if the test has been finished.
  bool get finished => this._finished;

  /// Indicates if the test has failed.
  @override
  bool get failed => this._failed;

  /// Indicates if the test has been or is to be skipped.
  bool get skipped => this._skip;

  /// Marks this test as failed.
  @override
  void fail() {
    if (!this._failed) {
      this._failed = true;
      this._body.className = "test_body body_shown";
      this._update();
    }
  }

  /// Runs a benchmark for the approximately amount of time
  /// then prints the results of the benchmark.
  @override
  void bench(
    final double seconds,
    final void Function() hndl,
  ) {
    final start = DateTime.now();
    double duration = 0.0;
    int count = 0;
    while (duration < seconds) {
      hndl();
      count++;
      final diff = DateTime.now().difference(start);
      duration = diff.inMilliseconds / Duration.millisecondsPerSecond;
    }
    notice("Benchmark results:\n");
    notice("  count    = $count\n");
    notice("  duration = $duration secs\n");
    notice("  average  = ${duration / count} secs\n");
    notice("  estimate = ${count / duration} per sec\n");
  }
}

/// The manager to run the tests.
class TestManager {
  final Element _elem;
  final DivElement _header;
  final HtmlEscape _escape;
  final DateTime _start;
  final List<TestBlock> _tests;
  int _finished;
  int _failed;
  String _prefix;

  /// Creates new test manager attached to the given element.
  TestManager(
    this._elem,
  )   : this._escape = const HtmlEscape(HtmlEscapeMode.element),
        this._header = DivElement(),
        this._start = DateTime.now(),
        this._tests = [],
        this._finished = 0,
        this._failed = 0,
        this._prefix = "" {
    this._elem.children.add(this._header);
    final checkBoxes = DivElement()..className = "log_checkboxes";
    this._createLogSwitch(checkBoxes, "Information", "info_log");
    this._createLogSwitch(checkBoxes, "Notice", "notice_log");
    this._createLogSwitch(checkBoxes, "Warning", "warning_log");
    this._createLogSwitch(checkBoxes, "Error", "error_log");
    this._elem.children.add(checkBoxes);
  }

  /// The filter to only let tests with the given prefix to be run.
  /// Set to empty to run all tests.
  String get testPrefixFilter => this._prefix;

  set testPrefixFilter(
    final String prefix,
  ) =>
      this._prefix = prefix;

  /// Creates a check box for changing the visibility of logs with the given [type].
  void _createLogSwitch(
    final DivElement checkBoxes,
    final String text,
    final String type,
  ) {
    final checkBox = CheckboxInputElement()
      ..className = "log_checkbox"
      ..checked = true;
    checkBox.onChange.listen(
      (final _) {
        final myElements = document.querySelectorAll(".$type");
        final display = (checkBox.checked ?? false) ? "block" : "none";
        for (int i = 0; i < myElements.length; i++) {
          myElements[i].style.display = display;
        }
      },
    );
    checkBoxes.children.add(checkBox);
    final span = SpanElement()..text = text;
    checkBoxes.children.add(span);
  }

  /// Callback from a test to indicate it is done
  /// and to have the manager start a new test.
  void _testDone(
    final TestBlock block,
  ) {
    this._finished++;
    if (block.failed) this._failed++;
    this._update();
    if (this._finished < this._tests.length) {
      asy.Timer.run(this._tests[this._finished].run);
    }
  }

  /// Updates the top header of the tests.
  void _update() {
    final time = ((DateTime.now().difference(this._start).inMilliseconds) * 0.001).toStringAsFixed(2);
    final testCount = this._tests.length;
    if (testCount <= this._finished) {
      if (this._failed > 0) {
        this._header.className = "top_header failed";
        if (this._failed == 1) {
          this._header.text = "Failed 1 Test (${time}s)";
        } else {
          this._header.text = "Failed ${this._failed} Tests (${time}s)";
        }
      } else {
        this._header
          ..text = "Tests Passed (${time}s)"
          ..className = "top_header passed";
      }
    } else {
      final prec = ((this._finished.toDouble() / testCount) * 100.0).toStringAsFixed(2);
      this._header.text = "Running Tests: ${this._finished}/${testCount} ($prec%)";
      if (this._failed > 0) {
        this._header
          ..text = "${this._header.text} - ${this._failed} failed)"
          ..className = "topHeader failed";
      } else {
        this._header.className = "topHeader running";
      }
    }
  }

  /// Adds a new test to be run.
  void add(
    String testName,
    final void Function(TestArgs args) test, {
    final bool skip = false,
  }) {
    if (testName.isEmpty) {
      // ignore: parameter_assignments
      testName = "$test";
    }
    if (!testName.startsWith(this._prefix)) {
      return;
    }
    this._tests.add(TestBlock(this, skip, test, testName));
    this._update();
    // If currently none are running, start this one.
    if (this._finished + 1 == this._tests.length) {
      asy.Timer.run(this._tests[this._finished].run);
    }
  }
}
