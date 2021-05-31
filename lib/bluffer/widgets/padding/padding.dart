import '../../base/edge_insets.dart';
import '../../base/keys.dart';
import '../../css/impl/builder.dart';
import '../../css/interface/css.dart';
import '../../html/impl/html.dart';
import '../../html/interface/html.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class Padding implements Widget {
  final Widget? child;
  final EdgeInsets? padding;
  @override
  final Key? key;

  const Padding({
    this.child,
    this.padding,
    this.key,
  });

  @override
  CssStyleDeclaration2 renderCss(BuildContext context) {
    final style = CssStyleDeclaration2BuilderImpl();
    style.display = 'flex';
    if (padding != null) {
      style.margin = '${padding!.top}px ${padding!.right}px ${padding!.bottom}px ${padding!.left}px';
    }
    return style;
  }

  @override
  HtmlElement2 renderHtml(BuildContext context) {
    if (child == null) {
      return DivElement2Impl();
    } else {
      return child!.render(context);
    }
  }

  @override
  HtmlElement2 render(BuildContext context) => renderWidget(this, context);
}
