part of three_dart.test.test000;

void addRegion2Tests(TestManager tests) {

  tests.add("Region2 Point Expand Test", (TestArgs args) {
    final math.Region2 reg1 = math.Region2.zero;
    _expandReg2(args, reg1,   0.0,  0.0,    0.0,  0.0,   0.0,  0.0);
    _expandReg2(args, reg1,   1.0,  2.0,    0.0,  0.0,   1.0,  2.0);
    _expandReg2(args, reg1,  -1.0, -2.0,   -1.0, -2.0,   1.0,  2.0);
    final math.Region2 reg2 = math.Region2(0.0,  0.0,   1.0,  2.0);
    _expandReg2(args, reg2,  -1.0, -2.0,   -1.0, -2.0,   2.0,  4.0);
    final math.Region2 reg3 = math.Region2(-1.0, -2.0, 2.0,  4.0);
    _expandReg2(args, reg3,   1.0,  1.0,   -1.0, -2.0,   2.0,  4.0);
    _expandReg2(args, reg3,   4.0,  4.0,   -1.0, -2.0,   5.0,  6.0);
  });
}

math.Region2 _expandReg2(TestArgs args, math.Region2 reg, double newX, double newY,
  double x, double y, double dx, double dy) {
  final math.Point2 input = math.Point2(newX, newY);
  final math.Region2 newReg = reg.expandWithPoint(input);
  final math.Region2 expReg = math.Region2(x, y, dx, dy);
  if (newReg != expReg) {
    args.error("Unexpected result from expand:\n"+
      "   Original: $reg\n"+
      "   Point:    $input\n"+
      "   Expected: $expReg\n"+
      "   Result:   $newReg\n");
  } else {
    args.info("$reg + $input => $newReg\n");
  }
  return newReg;
}

