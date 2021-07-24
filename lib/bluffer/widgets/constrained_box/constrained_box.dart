import '../../base/keys.dart';
import '../../css/css.dart';
import '../../html/html.dart';
import '../../html/html_impl.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class ConstrainedBox implements Widget {
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
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) {
    final _constraints = constraints;
    if (_constraints != null) {
      return CssStyleDeclaration2Impl(
        css_margin: 'auto',
        css_maxHeight: _constraints.maxHeight.toString() + 'px',
        css_maxWidth: _constraints.maxWidth.toString() + 'px',
        css_minHeight: _constraints.minHeight.toString() + 'px',
        css_minWidth: _constraints.minWidth.toString() + 'px',
      );
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

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );
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
