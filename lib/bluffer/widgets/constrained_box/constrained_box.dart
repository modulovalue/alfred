import '../../base/keys.dart';
import '../../css/impl/builder.dart';
import '../../css/interface/css.dart';
import '../../html/impl/html.dart';
import '../../html/interface/html.dart';
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
    required this.child,
    this.constraints,
    this.key,
  });

  @override
  CssStyleDeclaration2 renderCss(BuildContext context) {
    final style = CssStyleDeclaration2BuilderImpl();
    if (constraints != null) {
      style.margin = 'auto';
      style.maxHeight = '${constraints!.maxHeight}px';
      style.maxWidth = '${constraints!.maxWidth}px';
      style.minHeight = '${constraints!.minHeight}px';
      style.minWidth = '${constraints!.minWidth}px';
    }
    return style;
  }

  @override
  HtmlElement2 renderHtml(BuildContext context) {
    return child?.render(context) ?? DivElement2Impl();
  }

  @override
  HtmlElement2 render(BuildContext context) => renderWidget(this, context);
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

  BoxConstraints({
    required this.minWidth,
    required this.maxWidth,
    required this.minHeight,
    required this.maxHeight,
  });
}
