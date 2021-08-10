part of three_dart.test.test000;

void addMatrix2Tests(TestManager tests) {

  tests.add("Matrix2 Point Transposition Test", (TestArgs args) {
    const math.Matrix2 mat = math.Matrix2(2.0, 3.0,
                                        4.0, 5.0);
    _matrix2String(args, mat, "[2.000, 3.000,",
                              " 4.000, 5.000]");
    _transPnt2Matrix2(args, mat,   0.0,  0.0,    0.0,  0.0);
    _transPnt2Matrix2(args, mat,   1.0,  0.0,    2.0,  4.0);
    _transPnt2Matrix2(args, mat,   0.0,  1.0,    3.0,  5.0);
    _transPnt2Matrix2(args, mat,   1.0,  1.0,    5.0,  9.0);
  });

  tests.add("Matrix2 Vector Transposition Test", (TestArgs args) {
    const math.Matrix2 mat = math.Matrix2(2.0, 3.0,
                                        4.0, 5.0);
    _matrix2String(args, mat, "[2.000, 3.000,",
                              " 4.000, 5.000]");
    _transVec2Matrix2(args, mat,   0.0,  0.0,    0.0,  0.0);
    _transVec2Matrix2(args, mat,   1.0,  0.0,    2.0,  4.0);
    _transVec2Matrix2(args, mat,   0.0,  1.0,    3.0,  5.0);
    _transVec2Matrix2(args, mat,   1.0,  1.0,    5.0,  9.0);
  });

  tests.add("Matrix2 Identity Test", (TestArgs args) {
    final math.Matrix2 mat = math.Matrix2.identity;
    _matrix2String(args, mat, "[1.000, 0.000,",
                              " 0.000, 1.000]");
    _transPnt2Matrix2(args, mat,   0.0,  0.0,    0.0,  0.0);
    _transPnt2Matrix2(args, mat,   1.0,  0.0,    1.0,  0.0);
    _transPnt2Matrix2(args, mat,  -1.0,  0.0,   -1.0,  0.0);
    _transPnt2Matrix2(args, mat,   1.0,  1.0,    1.0,  1.0);
    _transPnt2Matrix2(args, mat,  -1.0, -1.0,   -1.0, -1.0);
    _transPnt2Matrix2(args, mat,   0.0,  1.0,    0.0,  1.0);
    _transPnt2Matrix2(args, mat,   0.0, -1.0,    0.0, -1.0);
    _transPnt2Matrix2(args, mat,   2.3, -4.2,    2.3, -4.2);
    _transPnt2Matrix2(args, mat,  -1.5,  7.3,   -1.5,  7.3);
  });

  tests.add("Matrix2 Scalar Test", (TestArgs args) {
    final math.Matrix2 mat = math.Matrix2.scale(2.0, 3.0);
    _matrix2String(args, mat, "[2.000, 0.000,",
                              " 0.000, 3.000]");
    _transPnt2Matrix2(args, mat,   0.0,  0.0,    0.0,   0.0);
    _transPnt2Matrix2(args, mat,   1.0,  0.0,    2.0,   0.0);
    _transPnt2Matrix2(args, mat,  -1.0,  0.0,   -2.0,   0.0);
    _transPnt2Matrix2(args, mat,   1.0,  1.0,    2.0,   3.0);
    _transPnt2Matrix2(args, mat,  -1.0, -1.0,   -2.0,  -3.0);
    _transPnt2Matrix2(args, mat,   0.0,  1.0,    0.0,   3.0);
    _transPnt2Matrix2(args, mat,   0.0, -1.0,    0.0,  -3.0);
    _transPnt2Matrix2(args, mat,   2.3, -4.2,    4.6, -12.6);
    _transPnt2Matrix2(args, mat,  -1.5,  7.3,   -3.0,  21.9);
  });

  tests.add("Matrix2 Basic Rotate Test", (TestArgs args) {
    final math.Matrix2 mat = math.Matrix2.rotate(math.PI/4.0);
    _matrix2String(args, mat, "[0.707, -0.707,",
                              " 0.707,  0.707]");
    const val = 0.70710678118; // sqrt(2)/2
    _transPnt2Matrix2(args, mat,   0.0,  0.0,    0.0,  0.0);
    _transPnt2Matrix2(args, mat,   1.0,  0.0,    val,  val);
    _transPnt2Matrix2(args, mat,   val,  val,    0.0,  1.0);
    _transPnt2Matrix2(args, mat,   0.0,  1.0,   -val,  val);
    _transPnt2Matrix2(args, mat,  -val,  val,   -1.0,  0.0);
    _transPnt2Matrix2(args, mat,  -1.0,  0.0,   -val, -val);
    _transPnt2Matrix2(args, mat,  -val, -val,    0.0, -1.0);
    _transPnt2Matrix2(args, mat,   0.0, -1.0,    val, -val);
    _transPnt2Matrix2(args, mat,   val, -val,    1.0,  0.0);
  });

  tests.add("Matrix2 Rotate Test", (TestArgs args) {
    _matrix2String(args, math.Matrix2.rotate(-math.PI/4.0),
      "[ 0.707, 0.707,",
      " -0.707, 0.707]");
    _matrix2String(args, math.Matrix2.rotate(math.PI/2.0),
      "[0.000, -1.000,",
      " 1.000,  0.000]");
    _matrix2String(args, math.Matrix2.rotate(-math.PI),
      "[-1.000,  0.000,",
      "  0.000, -1.000]");
    _matrix2String(args, math.Matrix2.rotate(math.PI),
      "[-1.000,  0.000,",
      "  0.000, -1.000]");
    _matrix2String(args, math.Matrix2.rotate(math.PI*3.0/8.0),
      "[0.383, -0.924,",
      " 0.924,  0.383]");
  });

  tests.add("Matrix2 Miscellaneous Test", (TestArgs args) {
    const math.Matrix2 mat = math.Matrix2(1.0, 2.0,
                                        3.0, 4.0);
    _matrix2String(args, mat,
      "[1.000, 2.000,",
      " 3.000, 4.000]");
    _matrix2String(args, math.Matrix2.fromList(mat.toList()),
      "[1.000, 2.000,",
      " 3.000, 4.000]");
    _matrix2String(args, mat.transpose(),
      "[1.000, 3.000,",
      " 2.000, 4.000]");
    _doubleCheck(args, mat.m11, 1.0, "m11");
    _doubleCheck(args, mat.m21, 2.0, "m21");
    _doubleCheck(args, mat.m12, 3.0, "m12");
    _doubleCheck(args, mat.m22, 4.0, "m22");
    _matrix2String(args, math.Matrix2.fromMatrix3(
      math.Matrix3(1.0, 2.0, 3.0,
                       4.0, 5.0, 6.0,
                       7.0, 8.0, 9.0)),
      "[1.000, 2.000,",
      " 4.000, 5.000]");
    _matrix2String(args, math.Matrix2.fromMatrix4(
      math.Matrix4( 1.0,  2.0,  3.0,  4.0,
                        5.0,  6.0,  7.0,  8.0,
                        9.0, 10.0, 11.0, 12.0,
                       13.0, 14.0, 15.0, 16.0)),
      "[1.000, 2.000,",
      " 5.000, 6.000]");
  });

  tests.add("Matrix2 Inverse Test", (TestArgs args) {
    _invsMatrix2(args, math.Matrix2.identity,
      "[1.000, 0.000,",
      " 0.000, 1.000]");
    _invsMatrix2(args, math.Matrix2.scale(2.0, 3.0),
      "[0.500, 0.000,",
      " 0.000, 0.333]");
    _invsMatrix2(args, math.Matrix2.rotate(math.PI/4.0),
      "[ 0.707, 0.707,",
      " -0.707, 0.707]");
    _matrix2String(args, const math.Matrix2(0.0, 0.0,
                                          0.0, 0.0).inverse(),
      "[1.000, 0.000,",
      " 0.000, 1.000]");
  });

  tests.add("Matrix2 Multiplication Test", (TestArgs args) {
    // [1, 2, * [5, 6, = [ 5+14,  6+16  = [19, 22,
    //  3, 4]    7, 8]    15+28, 18+32]    43, 50]
    _matrix2String(args,
      const math.Matrix2(1.0, 2.0,
                       3.0, 4.0)*
      const math.Matrix2(5.0, 6.0,
                       7.0, 8.0),
      "[19.000, 22.000,",
      " 43.000, 50.000]");
    // [5, 6, * [1, 2, = [ 5+18, 10+24  = [23, 34,
    //  7, 8]    3, 4]     7+24, 14+32]    31, 46]
    _matrix2String(args,
      const math.Matrix2(5.0, 6.0,
                       7.0, 8.0)*
      const math.Matrix2(1.0, 2.0,
                       3.0, 4.0),
      "[23.000, 34.000,",
      " 31.000, 46.000]");
  });
}

void _doubleCheck(TestArgs args, double value, double exp, String name) {
  if (value != exp) {
    args.error("Unexpected result from $name: "+
      "\n   Expected: $exp"+
      "\n   Gotten:   $value\n\n");
    args.fail();
  } else {
    args.info("Checked $name is $value\n\n");
  }
}

void _matrix2String(TestArgs args, math.Matrix2 mat, String exp1, String exp2) {
  final String exp = exp1+"\n             "+exp2;
  final String result = mat.format("             ");
  if (result != exp) {
    args.error("Unexpected result from Matrix2: "+
      "\n   Expected: $exp"+
      "\n   Gotten:   $result\n");
    args.fail();
  } else {
    args.info("Checking: "+mat.format("          ")+"\n\n");
  }
}

void _invsMatrix2(TestArgs args, math.Matrix2 mat, String exp1, String exp2) {
  final math.Matrix2 inv = mat.inverse();
  _matrix2String(args, inv, exp1, exp2);
  final math.Matrix2 result = inv.inverse();
  if (result != mat) {
    args.error("Unexpected result from Matrix2.inverse().inverse(): "+
      "\n   Expected: " + mat.format("             ") +
      "\n   Gotten:   " + result.format("             ") + "\n");
    args.fail();
  }
  final math.Matrix2 ident1 = mat*inv;
  if (ident1 != math.Matrix2.identity) {
    args.error("Unexpected result from Matrix2*Matrix2.inverse(): "+
      "\n   Matrix:   " + mat.format("             ") +
      "\n   Inverted: " + inv.format("             ") +
      "\n   Expected: " + math.Matrix2.identity.format("             ") +
      "\n   Gotten:   " + ident1.format("             ") + "\n");
    args.fail();
  }
  final math.Matrix2 ident2 = mat*inv;
  if (ident2 != math.Matrix2.identity) {
    args.error("Unexpected result from Matrix2*Matrix2.inverse(): "+
      "\n   Matrix:   " + mat.format("             ") +
      "\n   Inverted: " + inv.format("             ") +
      "\n   Expected: " + math.Matrix2.identity.format("             ") +
      "\n   Gotten:   " + ident2.format("             ") + "\n");
    args.fail();
  }
}

void _transPnt2Matrix2(TestArgs args, math.Matrix2 mat, double pntX, double pntY, double expX, double expY) {
  final math.Point2 pnt = math.Point2(pntX, pntY);
  final math.Point2 exp = math.Point2(expX, expY);
  final math.Point2 result = mat.transPnt2(pnt);
  args.info("Checking Matrix2.transPnt2: "+
    "\n   Matrix:   "+mat.format("             ")+
    "\n   Point:    $pnt\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix2.transPnt2: "+
      "\n   Expected: $exp"+
      "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}

void _transVec2Matrix2(TestArgs args, math.Matrix2 mat, double vecX, double vecY, double expX, double expY) {
  final math.Vector2 vec = math.Vector2(vecX, vecY);
  final math.Vector2 exp = math.Vector2(expX, expY);
  final math.Vector2 result = mat.transVec2(vec);
  args.info("Checking Matrix2.transVec2: "+
    "\n   Matrix:   "+mat.format("             ")+
    "\n   Vector:   $vec\n");
  if (result != exp) {
    args.error("Unexpected result from Matrix2.transVec2: "+
      "\n   Expected: $exp"+
      "\n   Gotten:   $result\n\n");
    args.fail();
  } else {
    args.info("   Result:   $result\n\n");
  }
}
