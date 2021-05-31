import '../../base/keys.dart';
import '../../css/impl/builder.dart';
import '../../css/interface/css.dart';
import '../../html/impl/html.dart';
import '../../html/interface/html.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

class SizedBox implements Widget {
  final Widget? child;
  final double? width;
  final double? height;
  @override
  final Key? key;

  const SizedBox({
    this.child,
    this.width,
    this.height,
    this.key,
  });

  @override
  CssStyleDeclaration2 renderCss(BuildContext context) {
    final style = CssStyleDeclaration2BuilderImpl();
    if (width != null) {
      style.width = '${width}px';
    }
    if (height != null) {
      style.height = '${height}px';
    }
    style.flexShrink = '0';
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
