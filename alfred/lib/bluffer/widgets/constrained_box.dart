import '../base/keys.dart';
import '../css/null_mixin.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import '../widget/widget.dart';
import 'stateless.dart';

class ConstrainedBox with CssStyleDeclarationNullMixin, WidgetSelfCSS, RenderElementMixin implements Widget {
  /// The additional constraints to impose on the child.
  final BoxConstraints? constraints;
  final Widget? child;
  @override
  final Key? key;

  const ConstrainedBox({
    required final this.child,
    final this.constraints,
    final this.key,
  });

  @override
  String? get css_margin {
    final _constraints = constraints;
    if (_constraints != null) {
      return 'auto';
    } else {
      return null;
    }
  }

  @override
  String? get css_maxHeight {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.maxHeight.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_maxWidth {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.maxWidth.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_minHeight {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.minHeight.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_minWidth {
    final _constraints = constraints;
    if (_constraints != null) {
      return _constraints.minWidth.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final rendered = child?.renderElement(context: context);
    return rendered ?? DivElementImpl(childNodes: []);
  }
}

class BoxConstraints {
  /// The minimum width that satisfies the constraints.
  final double minWidth;

  /// The maximum width that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxWidth;

  /// The minimum height that satisfies the constraints.
  final double minHeight;

  /// The maximum height that satisfies the constraints.
  ///
  /// Might be [double.infinity].
  final double maxHeight;

  const BoxConstraints({
    required final this.minWidth,
    required final this.maxWidth,
    required final this.minHeight,
    required final this.maxHeight,
  });
}
