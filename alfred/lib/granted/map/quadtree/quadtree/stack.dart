import '../node/branch/interface.dart';
import '../node/node/interface.dart';

/// A stack of nodes.
class NodeStackImpl implements NodeStack {
  /// The internal stack of nodes.
  final List<QTNode> _stack;

  /// Creates a new stack.
  /// The initial sets of [nodes] is pushed in order.
  NodeStackImpl({
    required final List<QTNode>? nodes,
  }) : _stack = <QTNode>[] {
    if (nodes != null) {
      // ignore: prefer_foreach
      for (final node in nodes) {
        pushOnTop(node);
      }
    }
  }

  @override
  bool get isEmpty => _stack.isEmpty;

  @override
  QTNode get popTop => _stack.removeLast();

  @override
  void pushOnTop(
    final QTNode node,
  ) =>
      _stack.add(node);

  @override
  void pushAllOnTop(
    final List<QTNode> nodes,
  ) {
    // ignore: prefer_foreach
    for (final node in nodes) {
      pushOnTop(node);
    }
  }

  @override
  void pushChildrenOnTop(
    final BranchNode node,
  ) {
    // Push in reverse order from typical searches so that they
    // are processed in the order: NE, NW, SE, then SW.
    pushOnTop(node.sw);
    pushOnTop(node.se);
    pushOnTop(node.nw);
    pushOnTop(node.ne);
  }

  @override
  void pushReverseChildrenOnTop(
    final BranchNode node,
  ) {
    // Push in normal order from typical searches so that they
    // are processed in the order: SW, SE, NW, then NE.
    pushOnTop(node.ne);
    pushOnTop(node.nw);
    pushOnTop(node.se);
    pushOnTop(node.sw);
  }
}

abstract class NodeStack {
  bool get isEmpty;

  QTNode get popTop;

  void pushOnTop(
    final QTNode node,
  );

  void pushAllOnTop(
    final List<QTNode> nodes,
  );

  void pushChildrenOnTop(
    final BranchNode node,
  );

  void pushReverseChildrenOnTop(
    final BranchNode node,
  );
}
