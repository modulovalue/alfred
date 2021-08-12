import '../node/node/interface.dart';

/// The node handler is used to process
/// or match points with custom handlers inside for each methods.
abstract class QTNodeHandler {
  /// Handles the given node.
  /// The [node] to handle.
  /// Returns true to continue or accept, false to stop or reject.
  bool handle(
    final QTNode node,
  );
}
