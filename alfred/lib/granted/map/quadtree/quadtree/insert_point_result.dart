import '../node/point/interface.dart';

class InsertPointResultImpl implements InsertPointResult {
  @override
  final PointNode insertedPoint;

  @override
  final bool pointExistedElsePointNew;

  const InsertPointResultImpl(
    final this.insertedPoint,
    final this.pointExistedElsePointNew,
  );
}

abstract class InsertPointResult {
  PointNode get insertedPoint;

  bool get pointExistedElsePointNew;
}
