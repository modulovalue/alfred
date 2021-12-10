import '../base/keys.dart';
import '../css/null_mixin.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import '../widget/widget.dart';
import 'stateless.dart';

class SizedBox with CssStyleDeclarationNullMixin, WidgetSelfCSS, RenderElementMixin implements Widget {
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
  String? get css_flexShrink => "0";

  @override
  String? get css_width {
    final _width = width;
    if (_width != null) {
      return _width.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  String? get css_height {
    final _height = height;
    if (_height != null) {
      return _height.toString() + 'px';
    } else {
      return null;
    }
  }

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    if (child == null) {
      return const DivElementImpl(
        childNodes: [],
      );
    } else {
      return child!.renderElement(
        context: context,
      );
    }
  }
}
