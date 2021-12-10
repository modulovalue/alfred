import '../base/edge_insets.dart';
import '../base/keys.dart';
import '../css/null_mixin.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import '../widget/widget.dart';
import 'stateless.dart';

class Padding with CssStyleDeclarationNullMixin, WidgetSelfCSS, RenderElementMixin implements Widget {
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
  String get css_display => "flex";

  @override
  String? get css_margin {
    final _padding = padding;
    if (_padding != null) {
      return _padding.top.toString() +
          'px ' +
          _padding.right.toString() +
          'px ' +
          _padding.bottom.toString() +
          'px ' +
          _padding.left.toString() +
          'px';
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
