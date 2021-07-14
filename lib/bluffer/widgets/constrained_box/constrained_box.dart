import '../../base/keys.dart';
import '../../css/impl/builder.dart';
import '../../css/impl/empty.dart';
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
    required final this.child,
    final this.constraints,
    final this.key,
  });

  @override
  CssStyleDeclaration2 renderCss(
    final BuildContext context,
  ) {
    if (constraints != null) {
      return CssStyleDeclaration2BuilderImpl.build(
        margin: 'auto',
        maxHeight: '${constraints!.maxHeight}px',
        maxWidth: '${constraints!.maxWidth}px',
        minHeight: '${constraints!.minHeight}px',
        minWidth: '${constraints!.minWidth}px',
      );
    } else {
      return const CssStyleDeclaration2EmptyImpl();
    }
  }

  @override
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) => //
      child?.render(context) ?? DivElement2Impl();

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) =>
      renderWidget(this, context);
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
