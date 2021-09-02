import '../node/edge/interface.dart';

/// The edge node handler is used to process
/// or match edges with custom handlers inside for-each methods.
abstract class QTEdgeHandler<T> {
  /// Handles the given edge node.
  /// Return true to continue, false to stop.
  bool handle(
    final QTEdgeNode<T> edge,
  );
}
