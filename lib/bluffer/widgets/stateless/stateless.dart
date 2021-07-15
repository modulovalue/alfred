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
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) =>
      build(context).render(context);

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) =>
      renderWidget(this, context);

  @override
  Null renderCss(
    final BuildContext context,
  ) =>
      null;
}
