import '../base/keys.dart';
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
  HtmlEntityElement renderHtml({
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
  HtmlEntityElement renderElement({
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
  HtmlEntityElement renderElement({
    required final BuildContext context,
  }) {
    var result = renderWidget(
      child: this,
      context: context,
    );
    for (final child in children) {
      result = HtmlEntityElementImpl(
        element: HtmlElementAppendedImpl(
          other: result.element,
          additional: [
            child.renderElement(
              context: context,
            ),
          ],
        ),
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
