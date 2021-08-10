part of three_dart.test.test000;

void addTechniqueTests(TestManager tests) {

  tests.add("Matrix4 Point Transposition Test", (TestArgs args) {
    testTechnique(args,
      math.Matrix4.identity,
      math.Matrix4.translate(0.0, 0.0, -5.0),
      [pointPair( 0.0,  0.0,  0.0,    0.0,                 0.0,                1.020051002550127),
       pointPair( 1.0,  0.0,  0.0,   -0.3464101615137755,  0.0,                1.020051002550127),
       pointPair(-1.0,  0.0,  0.0,    0.3464101615137755,  0.0,                1.020051002550127),
       pointPair( 0.0,  1.0,  0.0,    0.0,                -0.3464101615137755, 1.020051002550127),
       pointPair( 0.0, -1.0,  0.0,    0.0,                 0.3464101615137755, 1.020051002550127),
       pointPair( 0.0,  0.0,  1.0,    0.0,                 0.0,                1.016717502541794),
       pointPair( 0.0,  0.0, -1.0,    0.0,                 0.0,                1.025051252562628),
       pointPair( 1.0,  1.0,  1.0,   -0.2886751345948129, -0.2886751345948129, 1.016717502541794),
       pointPair( 1.0, -1.0,  1.0,   -0.2886751345948129,  0.2886751345948129, 1.016717502541794),
       pointPair( 1.0,  1.0, -1.0,   -0.4330127018922194, -0.4330127018922194, 1.025051252562628),
       pointPair( 1.0, -1.0, -1.0,   -0.4330127018922194,  0.4330127018922194, 1.025051252562628),
       pointPair(-1.0,  1.0,  1.0,    0.2886751345948129, -0.2886751345948129, 1.016717502541794),
       pointPair(-1.0, -1.0,  1.0,    0.2886751345948129,  0.2886751345948129, 1.016717502541794),
       pointPair(-1.0,  1.0, -1.0,    0.4330127018922194, -0.4330127018922194, 1.025051252562628),
       pointPair(-1.0, -1.0, -1.0,    0.4330127018922194,  0.4330127018922194, 1.025051252562628)]);
  });
}

class pointPair {
  math.Point3 inPoint;
  math.Point3 outPoint;

  pointPair(double inX, double inY, double inZ,
            double outX, double outY, double outZ):
    this.inPoint = math.Point3(inX, inY, inZ),
    this.outPoint = math.Point3(outX, outY, outZ);
}

void testTechnique(TestArgs args, math.Matrix4 objMat, math.Matrix4 camMat, List<pointPair> pairs) {
  final Shape shape = Shape();
  for (int i = 0; i < pairs.length; i++) {
    shape.vertices.addNew(loc: pairs[i].inPoint);
  }
  final three_dart.Entity obj = three_dart.Entity()
    ..shape = shape
    ..mover = Constant(objMat);
  final StringBuffer buf = StringBuffer();
  final Debugger tech = Debugger(buf);
  final EntityPass pass = EntityPass()
    ..technique = tech
    ..children.add(obj)
    ..camera?.mover = Constant(camMat);

  final three_dart.ThreeDart td = three_dart.ThreeDart.fromCanvas(html.CanvasElement())
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
      final math.Point3 expPnt = pairs[i].outPoint;
      final math.Point3 result = tech.results[i];
      if (expPnt != result) {
        args.error("Unexpected result from debugging technique at $i: " +
          "\n   Expected: $expPnt" +
          "\n   Gotten:   ${result.x}, ${result.y}, ${result.z}\n\n");
      }
    }
  }
}
