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
    final this.child,
    final this.width,
    final this.height,
    final this.key,
  });

  @override
  CssStyleDeclaration2 renderCss(
    final BuildContext context,
  ) =>
      CssStyleDeclaration2BuilderImpl.build(
        flexShrink: '0',
        width: () {
          if (width != null) {
            return '${width}px';
          } else {
            return null;
          }
        }(),
        height: () {
          if (height != null) {
            return '${height}px';
          } else {
            return null;
          }
        }(),
      );

  @override
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) {
    if (child == null) {
      return DivElement2Impl();
    } else {
      return child!.render(context);
    }
  }

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) =>
      renderWidget(this, context);
}
