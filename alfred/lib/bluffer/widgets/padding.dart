import '../base/edge_insets.dart';
import '../base/keys.dart';
import '../css/css.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import 'widget/impl/widget_mixin.dart';
import 'widget/interface/build_context.dart';
import 'widget/interface/widget.dart';

class Padding implements Widget {
  final Widget? child;
  final EdgeInsets? padding;
  @override
  final Key? key;

  const Padding({
    final this.child,
    final this.padding,
    final this.key,
  });

  @override
  CssStyleDeclaration renderCss({
    required final BuildContext context,
  }) =>
      CssStyleDeclaration2Impl(
        css_display: "flex",
        css_margin: () {
          if (padding != null) {
            return '${padding!.top}px ${padding!.right}px ${padding!.bottom}px ${padding!.left}px';
          } else {
            return null;
          }
        }(),
      );

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    if (child == null) {
      return DivElementImpl(childNodes: []);
    } else {
      return child!.renderElement(
        context: context,
      );
    }
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
