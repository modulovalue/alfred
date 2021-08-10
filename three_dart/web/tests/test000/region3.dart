part of three_dart.test.test000;

void addRegion3Tests(TestManager tests) {

  tests.add("Region3 Point Expand Test", (TestArgs args) {
    final math.Region3 reg1 = math.Region3.zero;
    _expandReg3(args, reg1,   0.0,  0.0,  0.0,   0.0,  0.0,  0.0,   0.0,  0.0,  0.0);
    _expandReg3(args, reg1,   1.0,  2.0,  3.0,   0.0,  0.0,  0.0,   1.0,  2.0,  3.0);
    _expandReg3(args, reg1,  -1.0, -2.0, -3.0,  -1.0, -2.0, -3.0,   1.0,  2.0,  3.0);
    final math.Region3 reg2 = math.Region3(0.0,  0.0,  0.0,   1.0,  2.0,  3.0);
    _expandReg3(args, reg2,  -1.0, -2.0, -3.0,  -1.0, -2.0, -3.0,   2.0,  4.0,  6.0);
    final math.Region3 reg3 = math.Region3(-1.0, -2.0, -3.0,   2.0,  4.0,  6.0);
    _expandReg3(args, reg3,   1.0,  1.0,  1.0,  -1.0, -2.0, -3.0,   2.0,  4.0,  6.0);
    _expandReg3(args, reg3,   4.0,  4.0,  4.0,  -1.0, -2.0, -3.0,   5.0,  6.0,  7.0);
  });
}

math.Region3 _expandReg3(TestArgs args, math.Region3 reg, double newX, double newY, double newZ,
  double x, double y, double z, double dx, double dy, double dz) {
  final math.Point3 input = math.Point3(newX, newY, newZ);
  final math.Region3 newReg = reg.expandWithPoint(input);
  final math.Region3 expReg = math.Region3(x, y, z, dx, dy, dz);
  if (newReg != expReg) {
    args.error("Unexpected result from expand:\n"+
      "   Original: $reg\n"+
      "   Point:    $input\n"+
      "   Expected: $expReg\n"+
      "   Result:   $newReg\n");
  } else {
    args.info("[$reg] + [$input] => [$newReg]\n");
  }
  return newReg;
}

