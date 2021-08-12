import '../node/point/interface.dart';

/// The point handler is used to process
/// or match points with custom handlers inside for-each methods.
abstract class QTPointHandler {
  /// Handles the given point.
  /// Returns true to continue, false to stop.
  bool handle(
    final PointNode point,
  );
}
