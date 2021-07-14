import '../../base/keys.dart';
import '../../css/builder.dart';
import '../../css/css.dart';
import '../../html/html.dart';
import '../../html/html_impl.dart';
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
      CssStyleDeclaration2Impl(
        css_flexShrink: '0',
        css_width: () {
          if (width != null) {
            return '${width}px';
          } else {
            return null;
          }
        }(),
        css_height: () {
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
      return DivElement2Impl.empty();
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
