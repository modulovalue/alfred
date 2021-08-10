import '../../base/keys.dart';
import '../../html/html.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

abstract class StatelessWidget implements Widget {
  @override
  final Key? key;

  const StatelessWidget({
    final this.key,
  });

  Widget build(
    final BuildContext context,
  );

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    final built = build(context);
    return built.renderElement(
      context: context,
    );
  }

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) =>
      renderWidget(
        child: this,
        context: context,
      );

  @override
  Null renderCss({
    required final BuildContext context,
  }) =>
      null;
}
