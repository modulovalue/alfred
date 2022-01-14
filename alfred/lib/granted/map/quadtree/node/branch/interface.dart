import '../../basic/qt_point_handler.dart';
import '../../boundary.dart';
import '../../point/qt_point.dart';
import '../boundary/interface.dart';
import '../node/interface.dart';
import '../point/interface.dart';

abstract class BranchNode implements QTNodeBoundary {
  /// Gets the north-east child node.
  QTNode get ne;

  /// Gets the north-west child node.
  QTNode get nw;

  /// Gets the south-east child node.
  QTNode get se;

  /// Gets the south-west child node.
  QTNode get sw;

  /// Gets the quadrant of the child in the direction of the given point.
  /// This doesn't check that the point is actually contained by the child indicated,
  /// only the child in the direction of the point.
  Quadrant childQuad(
    final QTPoint pnt,
  );

  /// Gets the quadrant of the given child node.
  Quadrant childNodeQuad(
    final QTNode node,
  );

  /// Gets the minimum x location of the child of the given quadrant.
  int childX(
    final Quadrant quad,
  );

  /// Gets the minimum y location of the child of the given quadrant.
  int childY(
    final Quadrant quad,
  );

  /// Gets the child at a given quadrant.
  QTNode child(
    final Quadrant childQuad,
  );

  /// This sets the child at a given quadrant.
  /// Returns true if the child was changed, false if there was not change.
  bool setChild(
    final Quadrant childQuad,
    final QTNode node,
  );

  /// Returns the first point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the first point node in the given boundary,
  /// or null if none was found.
  PointNode? findFirstPoint(
    final QTBoundary? boundary,
    final QTPointHandler? handle,
  );

  /// Returns the last point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the last point node in the given boundary,
  /// or null if none was found.
  PointNode? findLastPoint(
    final QTBoundary? boundary,
    final QTPointHandler? handle,
  );

  /// Returns the next point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the next point node in the given region,
  /// or null if none was found.
  PointNode? findNextPoint(
    final QTNode curNode,
    final QTBoundary? boundary,
    final QTPointHandler? handle,
  );

  /// Returns the previous point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the previous point node in the given region,
  /// or null if none was found.
  PointNode? findPreviousPoint(
    final QTNode curNode,
    final QTBoundary? boundary,
    final QTPointHandler? handle,
  );

  /// Determine if this node can be reduced.
  /// Returns this branch node if not reduced,
  /// or the reduced node to replace this node with.
  QTNode reduce();
}

/// The child quadrant.
enum Quadrant {
  /// Indicates the minimum X and maximum Y child.
  NorthWest,

  /// Indicates the maximum X and minimum Y child.
  SouthWest,

  /// Indicates the minimum X and maximum Y child.
  NorthEast,

  /// Indicates the maximum X and minimum Y child.
  SouthEast,
}
