import '../../boundary/interface.dart';
import '../../edge/interface.dart';
import '../../first_left_edge_args/interface.dart';
import '../../handler_edge/interface.dart';
import '../../handler_node/interface.dart';
import '../../handler_point/interface.dart';
import '../../point/interface.dart';
import '../../point/ops/intersect.dart';
import '../boundary/impl_pass.dart';
import '../boundary/mixin.dart';
import '../edge/interface.dart';
import '../node/impl_empty.dart';
import '../node/interface.dart';
import '../point/interface.dart';
import 'interface.dart';

/// The branch node is a quad-tree branching node with four children nodes.
class BranchNodeImpl with QTNodeBoundaryMixin implements BranchNode {
  /// The north-east child node.
  QTNode _ne;

  /// The north-west child node.
  QTNode _nw;

  /// The south-east child node.
  QTNode _se;

  /// The south-west child node.
  QTNode _sw;

  /// Creates a new branch node.
  BranchNodeImpl()
      : _ne = QTNodeEmptyImpl.instance,
        _nw = QTNodeEmptyImpl.instance,
        _se = QTNodeEmptyImpl.instance,
        _sw = QTNodeEmptyImpl.instance;

  /// Adds an edge to this node and/or children nodes.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertEdge(
    final QTEdgeNode edge,
  ) {
    bool changed = false;
    if (overlapsEdge(edge)) {
      for (final quad in Quadrant.values) {
        final node = child(quad);
        QTNode newChild;
        if (node is QTNodeEmptyImpl) {
          newChild = QTNodeEmptyImpl.instance.addEdge(childX(quad), childY(quad), width ~/ 2, edge);
        } else {
          newChild = (node as QTNodeBoundaryMixin).insertEdge(edge);
        }
        if (setChild(quad, newChild)) {
          changed = true;
        }
      }
    }
    if (changed) {
      return reduce();
    } else {
      return this;
    }
  }

  /// Adds a point to this node.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode insertPoint(
    final PointNode point,
  ) {
    final quad = childQuad(point);
    final node = child(quad);
    if (node is QTNodeEmptyImpl) {
      final child = QTNodeEmptyImpl.instance.addPoint(childX(quad), childY(quad), width ~/ 2, point);
      if (setChild(quad, child)) {
        return reduce();
      }
    } else {
      final child = (node as QTNodeBoundaryMixin).insertPoint(point);
      if (setChild(quad, child)) {
        return reduce();
      }
    }
    return this;
  }

  /// Removes a edge from the tree at this node.
  /// [trimTree] indicates if the end points of the edge should be
  /// removed if no other edges begins or ends at that point.
  /// Returns the node that should be the new root of the subtree that was
  /// defined by this node.
  @override
  QTNode removeEdge(
    final QTEdgeNode edge,
    final bool trimTree,
  ) {
    bool changed = false;
    if (overlapsEdge(edge)) {
      for (final quad in Quadrant.values) {
        final node = child(quad);
        if (node is! QTNodeEmptyImpl) {
          if (setChild(quad, (node as QTNodeBoundaryMixin).removeEdge(edge, trimTree))) {
            changed = true;
            // Even if child changes don't skip others.
          }
        }
      }
    }
    if (changed) {
      return reduce();
    } else {
      return this;
    }
  }

  /// This handles the first found intersecting edge.
  @override
  IntersectionResult? findFirstIntersection(
    final QTEdge edge,
    final QTEdgeHandler? hndl,
  ) {
    if (overlapsEdge(edge)) {
      IntersectionResult? result;
      result = _ne.findFirstIntersection(edge, hndl);
      if (result != null) {
        return result;
      }
      result = _nw.findFirstIntersection(edge, hndl);
      if (result != null) {
        return result;
      }
      result = _se.findFirstIntersection(edge, hndl);
      if (result != null) {
        return result;
      }
      result = _sw.findFirstIntersection(edge, hndl);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// This handles all the intersections.
  @override
  bool findAllIntersections(
    final QTEdge edge,
    final QTEdgeHandler? hndl,
    final IntersectionSet intersections,
  ) {
    bool result = false;
    if (overlapsEdge(edge)) {
      if (_ne.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_nw.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_se.findAllIntersections(edge, hndl, intersections)) result = true;
      if (_sw.findAllIntersections(edge, hndl, intersections)) result = true;
    }
    return result;
  }

  @override
  QTNode get ne => _ne;

  @override
  QTNode get nw => _nw;

  @override
  QTNode get se => _se;

  @override
  QTNode get sw => _sw;

  /// Handles each point node reachable from this node in the boundary.
  /// Returns true if all points in the boundary were run, false if stopped.
  @override
  bool foreachPoint(QTPointHandler handle, [QTBoundary? bounds]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return _ne.foreachPoint(handle, bounds) &&
          _nw.foreachPoint(handle, bounds) &&
          _se.foreachPoint(handle, bounds) &&
          _sw.foreachPoint(handle, bounds);
    }
    return true;
  }

  /// Handles each edge node reachable from this node in the boundary.
  /// [exclusive] indicates that only edge which have both end points
  /// inside the region are collected, otherwise any edge which
  /// exists even partially in the region are collected.
  /// Returns true if all edges in the boundary were run, false if stopped.
  @override
  bool foreachEdge(QTEdgeHandler handle, [QTBoundary? bounds, bool exclusive = false]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return _ne.foreachEdge(handle, bounds, exclusive) &&
          _nw.foreachEdge(handle, bounds, exclusive) &&
          _se.foreachEdge(handle, bounds, exclusive) &&
          _sw.foreachEdge(handle, bounds, exclusive);
    }
    return true;
  }

  /// Handles each node reachable from this node in the boundary.
  /// Returns true if all nodes in the boundary were run,
  /// false if stopped.
  @override
  bool foreachNode(QTNodeHandler handle, [QTBoundary? bounds]) {
    if ((bounds == null) || overlapsBoundary(bounds)) {
      return handle.handle(this) &&
          _ne.foreachNode(handle, bounds) &&
          _nw.foreachNode(handle, bounds) &&
          _se.foreachNode(handle, bounds) &&
          _sw.foreachNode(handle, bounds);
    } else {
      return true;
    }
  }

  /// Determines if the node has any point nodes inside it.
  /// Returns true if this node has any points in it, false otherwise.
  ///
  /// The only way this branch hasn't been reduced is
  /// because there is at least two points in it.
  @override
  bool get hasPoints => true;

  /// Determines if the node has any edge nodes inside it.
  /// Returns true if this edge has any edges in it, false otherwise.
  @override
  bool get hasEdges => _ne.hasEdges && _nw.hasEdges && _se.hasEdges && _sw.hasEdges;

  /// Gets the first edge to the left of the given point.
  @override
  void firstLeftEdge(
    final FirstLeftEdgeArgs args,
  ) {
    if ((args.queryPoint.y <= ymax) && (args.queryPoint.y >= ymin)) {
      final quad = childQuad(args.queryPoint);
      if (quad == Quadrant.NorthEast) {
        _ne.firstLeftEdge(args);
        // If no edges in the NW child could have a larger right value, skip.
        if ((!args.found) || (args.rightValue <= (xmin + width / 2))) {
          _nw.firstLeftEdge(args);
        }
      } else if (quad == Quadrant.NorthWest) {
        _nw.firstLeftEdge(args);
      } else if (quad == Quadrant.SouthEast) {
        _se.firstLeftEdge(args);
        // If no edges in the SW child could have a larger right value, skip.
        if ((!args.found) || (args.rightValue <= (xmin + width / 2))) {
          _sw.firstLeftEdge(args);
        }
      } else {
        // Quadrant.SouthWest
        _sw.firstLeftEdge(args);
      }
    }
  }

  /// Handles all the edges to the left of the given point.
  /// Returns true if all the edges were processed,
  /// false if the handle stopped early.
  @override
  bool foreachLeftEdge(
    final QTPoint point,
    final QTEdgeHandler hndl,
  ) {
    bool result = true;
    if ((point.y <= ymax) && (point.y >= ymin)) {
      final quad = childQuad(point);
      if (quad == Quadrant.NorthEast) {
        result = _ne.foreachLeftEdge(point, hndl);
        if (result) result = _nw.foreachLeftEdge(point, hndl);
      } else if (quad == Quadrant.NorthWest) {
        result = _nw.foreachLeftEdge(point, hndl);
      } else if (quad == Quadrant.SouthEast) {
        result = _se.foreachLeftEdge(point, hndl);
        if (result) result = _sw.foreachLeftEdge(point, hndl);
      } else {
        // Quadrant.SouthWest
        result = _sw.foreachLeftEdge(point, hndl);
      }
    }
    return result;
  }

  /// Gets the quadrant of the child in the direction of the given point.
  /// This doesn't check that the point is actually contained by the child indicated,
  /// only the child in the direction of the point.
  @override
  Quadrant childQuad(
    final QTPoint pnt,
  ) {
    final half = width ~/ 2;
    final south = pnt.y < (ymin + half);
    final west = pnt.x < (xmin + half);
    if (south) {
      if (west) {
        return Quadrant.SouthWest;
      } else {
        return Quadrant.SouthEast;
      }
    } else {
      if (west) {
        return Quadrant.NorthWest;
      } else {
        return Quadrant.NorthEast;
      }
    }
  }

  /// Gets the quadrant of the given child node.
  @override
  Quadrant childNodeQuad(
    final QTNode node,
  ) {
    if (_ne == node) {
      return Quadrant.NorthEast;
    } else if (_nw == node) {
      return Quadrant.NorthWest;
    } else if (_se == node) {
      return Quadrant.SouthEast;
    } else {
      return Quadrant.SouthWest;
    }
  }

  /// Gets the minimum x location of the child of the given quadrant.
  @override
  int childX(
    final Quadrant quad,
  ) {
    if ((quad == Quadrant.NorthEast) || (quad == Quadrant.SouthEast)) {
      return xmin + width ~/ 2;
    }
    // (quad == Quadrant.NorthWest) || (quad == Quadrant.SouthWest)
    return xmin;
  }

  /// Gets the minimum y location of the child of the given quadrant.
  @override
  int childY(
    final Quadrant quad,
  ) {
    if ((quad == Quadrant.NorthEast) || (quad == Quadrant.NorthWest)) {
      return ymin + width ~/ 2;
    }
    // (quad == Quadrant.SouthEast) || (quad == Quadrant.SouthWest)
    return ymin;
  }

  /// Gets the child at a given quadrant.
  @override
  QTNode child(Quadrant childQuad) {
    if (childQuad == Quadrant.NorthEast) {
      return _ne;
    }
    if (childQuad == Quadrant.NorthWest) {
      return _nw;
    }
    if (childQuad == Quadrant.SouthEast) {
      return _se;
    }
    // childQuad ==  Quadrant.SouthWest
    return _sw;
  }

  /// This sets the child at a given quadrant.
  /// Returns true if the child was changed, false if there was not change.
  @override
  bool setChild(
    final Quadrant childQuad,
    final QTNode node,
  ) {
    // ignore: prefer_asserts_with_message
    assert(node != this);
    if (childQuad == Quadrant.NorthEast) {
      if (_ne == node) {
        return false;
      }
      _ne = node;
    } else if (childQuad == Quadrant.NorthWest) {
      if (_nw == node) {
        return false;
      }
      _nw = node;
    } else if (childQuad == Quadrant.SouthEast) {
      if (_se == node) {
        return false;
      }
      _se = node;
    } else {
      // childQuad == Quadrant.SouthWest
      if (_sw == node) {
        return false;
      }
      _sw = node;
    }
    if (node is! QTNodeEmptyImpl) {
      (node as QTNodeBoundaryMixin).parent = this;
    }
    return true;
  }

  /// Returns the first point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the first point node in the given boundary,
  /// or null if none was found.
  @override
  PointNode? findFirstPoint(QTBoundary? boundary, QTPointHandler? handle) {
    if ((boundary == null) || overlapsBoundary(boundary)) {
      for (final quad in Quadrant.values) {
        final node = child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.containsPoint(node)) {
            if ((handle != null) && (!handle.handle(node))) {
              continue;
            }
            return node;
          }
        } else if (node is BranchNode) {
          final result = node.findFirstPoint(boundary, handle);
          if (result != null) {
            return result;
          }
        }
      }
    }
    return null;
  }

  /// Returns the last point within the given boundary in this node.
  /// The given [boundary] is the boundary to search within,
  /// or null for no boundary.
  /// Returns the last point node in the given boundary,
  /// or null if none was found.
  @override
  PointNode? findLastPoint(QTBoundary? boundary, QTPointHandler? handle) {
    if ((boundary == null) || overlapsBoundary(boundary)) {
      for (final quad in Quadrant.values) {
        final node = child(quad);
        if (node is PointNode) {
          if ((boundary == null) || boundary.containsPoint(node)) {
            if ((handle != null) && (!handle.handle(node))) {
              continue;
            }
            return node;
          }
        } else if (node is BranchNode) {
          final result = node.findLastPoint(boundary, handle);
          if (result != null) {
            return result;
          }
        }
      }
    }
    return null;
  }

  /// Returns the next point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the next point node in the given region,
  /// or null if none was found.
  @override
  PointNode? findNextPoint(QTNode curNode, QTBoundary? boundary, QTPointHandler? handle) {
    List<Quadrant> others;
    final quad = childNodeQuad(curNode);
    if (quad == Quadrant.NorthWest) {
      others = [Quadrant.NorthEast, Quadrant.SouthWest, Quadrant.SouthEast];
    } else if (quad == Quadrant.NorthEast) {
      others = [Quadrant.SouthWest, Quadrant.SouthEast];
    } else if (quad == Quadrant.SouthWest) {
      others = [Quadrant.SouthEast];
    } else {
      others = [];
    }
    for (final quad in others) {
      final node = child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          if ((handle != null) && (!handle.handle(node))) {
            continue;
          } else {
            return node;
          }
        }
      } else if (node is BranchNode) {
        final result = node.findFirstPoint(boundary, handle);
        if (result != null) {
          return result;
        }
      }
    }
    final _parent = parent;
    if (_parent == null) {
      return null;
    } else {
      return _parent.findNextPoint(this, boundary, handle);
    }
  }

  /// Returns the previous point in this node after the given child.
  /// The [curNode] is the child node to find the next from.
  /// Returns the previous point node in the given region,
  /// or null if none was found.
  @override
  PointNode? findPreviousPoint(QTNode curNode, QTBoundary? boundary, QTPointHandler? handle) {
    List<Quadrant> others;
    final quad = childNodeQuad(curNode);
    if (quad == Quadrant.NorthWest) {
      others = [];
    } else if (quad == Quadrant.NorthEast) {
      others = [Quadrant.NorthWest];
    } else if (quad == Quadrant.SouthWest) {
      others = [Quadrant.NorthWest, Quadrant.NorthEast];
    } else {
      others = [Quadrant.NorthWest, Quadrant.NorthEast, Quadrant.SouthWest];
    }
    for (final quad in others) {
      final node = child(quad);
      if (node is PointNode) {
        if ((boundary == null) || boundary.containsPoint(node)) {
          if ((handle != null) && (!handle.handle(node))) {
            continue;
          } else {
            return node;
          }
        }
      } else if (node is BranchNode) {
        final result = node.findLastPoint(boundary, handle);
        if (result != null) return result;
      }
    }
    final _parent = parent;
    if (_parent == null) {
      return null;
    } else {
      return _parent.findPreviousPoint(this, boundary, handle);
    }
  }

  /// Determine if this node can be reduced.
  /// Returns this branch node if not reduced,
  /// or the reduced node to replace this node with.
  @override
  QTNode reduce() {
    // A branch node can be reduced any time the all of the children
    // contain no points or only one point.
    final pointCount = _pointWeight(_ne) + _pointWeight(_nw) + _pointWeight(_se) + _pointWeight(_sw);
    if (pointCount == 0) {
      // Find an pass node and populate it with the other pass nodes' lines.
      PassNode? pass;
      for (final quad in Quadrant.values) {
        final node = child(quad);
        if (node is PassNode) {
          if (pass == null) {
            pass = node;
            pass.setLocation(xmin, ymin, width);
            pass.parent = null;
            setChild(quad, QTNodeEmptyImpl.instance);
          } else {
            // Copy all edges from this pass node into the already found pass node.
            pass.passEdges.addAll(node.passEdges);
          }
        }
      }
      // Return either the found pass node or the empty node.
      if (pass != null) {
        return pass;
      } else {
        return QTNodeEmptyImpl.instance;
      }
    } else if (pointCount == 1) {
      // Find the point node in the children.
      PointNode? point;
      for (final quad in Quadrant.values) {
        final node = child(quad);
        if (node is PointNode) {
          // Point node found, relocate and remove the node
          // from this parent node so that it isn't deleted later.
          point = node;
          node.setLocation(xmin, ymin, width);
          node.parent = null;
          setChild(quad, QTNodeEmptyImpl.instance);
          break;
        }
      }
      if (point == null) {
        return QTNodeEmptyImpl.instance;
      } else {
        // Find any pass nodes and copy all lines into the point node.
        for (final quad in Quadrant.values) {
          final node = child(quad);
          if (node is PassNode) {
            // Add all passing lines to point node unless the line starts or ends
            // on the point node, since the line will already be in the start or end line lists.
            for (final edge in node.passEdges) {
              if ((edge.startNode != point) && (edge.endNode != point)) {
                point.passEdges.add(edge);
              }
            }
          }
        }
        // Return found point node.
        return point;
      }
    } else {
      // Can't reduce so return this node.
      return this;
    }
  }

  /// Gets a weighting which indicates the minimum amount
  /// of points which can be in the node.
  int _pointWeight(QTNode node) {
    if (node is PointNode) {
      return 1;
    } else if (node is BranchNode) {
      return 2;
    } else if (node is PassNode) {
      return 0;
    } else {
      return 0;
    }
  }

  //// Validates this node.
  @override
  bool validate(StringBuffer sout, bool recursive) {
    bool result = true;
    if (!_validateChild(sout, recursive, _ne, "NE", true, true)) {
      result = false;
    }
    if (!_validateChild(sout, recursive, _nw, "NW", true, false)) {
      result = false;
    }
    if (!_validateChild(sout, recursive, _sw, "SW", false, false)) {
      result = false;
    }
    if (!_validateChild(sout, recursive, _se, "SE", false, true)) {
      result = false;
    }
    return result;
  }

  /// Validates the given child node.
  bool _validateChild(
    StringBuffer sout,
    bool recursive,
    QTNode? child,
    String name,
    bool north,
    bool east,
  ) {
    if (child == null) {
      sout.write("Error in ");
      sout.write(": The ");
      sout.write(name);
      sout.write(" child was null.\n");
      return false;
    } else {
      bool result = true;
      if (child is! QTNodeEmptyImpl) {
        final bnode = child as QTNodeBoundaryMixin;
        if (bnode.parent != this) {
          sout.write("Error in ");
          sout.write(": The ");
          sout.write(name);
          sout.write(" child, ");
          sout.write(", parent wasn't this node, it was ");
          sout.write(".\n");
          result = false;
        }
        if (width / 2 != bnode.width) {
          sout.write("Error in ");
          sout.write(": The ");
          sout.write(name);
          sout.write(" child, ");
          sout.write(", was ");
          sout.write(bnode.width);
          sout.write(" wide, but should have been ");
          sout.write(width / 2);
          sout.write(".\n");
          result = false;
        }
        final left = () {
          if (east) {
            return xmin + bnode.width;
          } else {
            return xmin;
          }
        }();
        final top = () {
          if (north) {
            return ymin + bnode.width;
          } else {
            return ymin;
          }
        }();
        if ((left != bnode.xmin) || (top != bnode.ymin)) {
          sout.write("Error in ");
          sout.write(": The ");
          sout.write(name);
          sout.write(" child, ");
          sout.write(", was at [");
          sout.write(bnode.xmin);
          sout.write(", ");
          sout.write(bnode.ymin);
          sout.write("], but should have been [");
          sout.write(left);
          sout.write(", ");
          sout.write(top);
          sout.write("].\n");
          result = false;
        }
      }
      if (recursive) {
        if (!child.validate(sout, recursive)) {
          result = false;
        }
      }
      return result;
    }
  }
}
