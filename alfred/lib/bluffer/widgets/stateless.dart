import '../base/keys.dart';
import '../css/css.dart';
import '../html/html.dart';
import '../widget/widget.dart';
import '../widget/widget_mixin.dart';

abstract class StatelessWidget implements Widget {
  Widget build(
    final BuildContext context,
  );
}

abstract class StatelessWidgetBase with RenderElementMixin implements StatelessWidget {
  @override
  final Key? key;

  const StatelessWidgetBase({
    final this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final built = build(
      context,
    );
    return built.renderElement(
      context: context,
    );
  }
}

mixin RenderElementMixin implements Widget {
  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );
}

mixin MultiRenderElementMixin implements Widget {
  Iterable<Widget> get children;

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) {
    var result = renderWidget(
      child: this,
      context: context,
    );
    for (final child in children) {
      final rendered = child.renderElement(
        context: context,
      );
      result = result.append(
        [
          rendered,
        ],
      );
    }
    return result;
  }
}

mixin NoCSSMixin implements Widget {
  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      null;
}

mixin NoKeyMixin implements Widget {
  @override
  Key? get key => null;
}
