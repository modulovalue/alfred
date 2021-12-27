import 'grammar.dart';
import 'tokenizer.dart';

/// The handler signature for a method to call for a specific trigger.
typedef TriggerHandle = void Function(TriggerArgs args);

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
abstract class TreeNode {
  /// Processes this tree node with the given handles for the triggers to call.
  void process(
    final Map<String, TriggerHandle> handles,
  );
}

/// The argument passed into the trigger handler when it is being called.
class TriggerArgs {
  /// The list of recent tokens while processing a tree node.
  List<Token> tokens = [];

  /// Creates a new trigger argument.
  TriggerArgs();

  /// Gets the recent token offset from most recent by the given index.
  Token? recent(
    final int index,
  ) {
    if ((index > 0) && (index <= tokens.length)) {
      return this.tokens[this.tokens.length - index];
    } else {
      return null;
    }
  }
}

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class RuleNode implements TreeNode {
  static const String _charStart = '─';
  static const String _charBar = '  │';
  static const String _charBranch = '  ├─';
  static const String _charSpace = '   ';
  static const String _charLeaf = '  └─';

  /// The grammar rule for this node.
  final Rule rule;

  /// The list of items for this rule.
  /// The items are `TreeNodes` and `Tokenizer.Token`s.
  final List<TreeNode> items;

  /// Creates a new tree node.
  const RuleNode(
    final this.rule,
    final this.items,
  );

  /// Helps construct the debugging output of the tree.
  void _toTree(StringBuffer buf, String indent, String first) {
    buf.write(first + '<' + (this.rule.term?.name ?? '') + '>');
    if (items.isNotEmpty) {
      for (int i = 0; i < items.length - 1; i++) {
        final item = items[i];
        if (item is RuleNode) {
          item._toTree(buf, indent + _charBar, '\n' + indent + _charBranch);
        } else {
          buf.write('\n' + indent + _charBranch + item.toString());
        }
      }
      final item = items[items.length - 1];
      if (item is RuleNode) {
        item._toTree(buf, indent + _charSpace, '\n' + indent + _charLeaf);
      } else {
        buf.write('\n' + indent + _charLeaf + item.toString());
      }
    }
  }

  /// Processes this tree node with the given handles for the triggers to call.
  @override
  void process(Map<String, TriggerHandle> handles) {
    final List<TreeNode> stack = [];
    stack.add(this);
    final TriggerArgs args = TriggerArgs();
    while (stack.isNotEmpty) {
      final TreeNode node = stack.removeLast();
      if (node is RuleNode) {
        stack.addAll(node.items.reversed);
      } else if (node is TokenNode) {
        args.tokens.add(node.token);
      } else if (node is TriggerNode) {
        if (!handles.containsKey(node.trigger)) {
          throw Exception('Failed to find the handle for the trigger, ${node.trigger}');
        }
        handles[node.trigger]?.call(args);
      }
    }
  }

  /// Gets a string for the tree node.
  @override
  String toString() {
    final buf = StringBuffer();
    this._toTree(buf, '', _charStart);
    return buf.toString();
  }
}

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class TokenNode implements TreeNode {
  /// The token found at this point in the parse tree.
  final Token token;

  /// Creates a new token parse tree node.
  const TokenNode(
    final this.token,
  );

  /// Processes this tree node with the given handles for the triggers to call.
  @override
  void process(
    final Map<String, TriggerHandle> handles,
  ) {
    // Do Nothing, no trigger so there is no effect.
  }

  /// Gets a string for this tree node.
  @override
  String toString() => '[${this.token.toString()}]';
}

/// The tree node containing reduced rule of the grammar
/// filled out with tokens and other TreeNodes.
class TriggerNode implements TreeNode {
  /// The token found at this point in the parse tree.
  final String trigger;

  /// Creates a new token parse tree node.
  const TriggerNode(
    final this.trigger,
  );

  /// Processes this tree node with the given handles for the triggers to call.
  @override
  void process(
    final Map<String, TriggerHandle> handles,
  ) {
    if (!handles.containsKey(this.trigger)) {
      throw Exception('Failed to find the handle for the trigger, ${this.trigger}');
    } else {
      handles[this.trigger]?.call(TriggerArgs());
    }
  }

  /// Gets a string for this tree node.
  @override
  String toString() => '{${this.trigger}}';
}
