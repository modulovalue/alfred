import '../../base/keys.dart';
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
  CssStyleDeclaration renderCss({
    required final BuildContext context,
  }) =>
      CssStyleDeclaration2Impl(
        css_flexShrink: '0',
        css_width: () {
          final _width = width;
          if (_width != null) {
            return _width.toString() + 'px';
          } else {
            return null;
          }
        }(),
        css_height: () {
          final _height = height;
          if (_height != null) {
            return _height.toString() + 'px';
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
      return DivElementEmptyImpl();
    } else {
      return child!.render(
        context: context,
      );
    }
  }

  @override
  HtmlElement render({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );
}
