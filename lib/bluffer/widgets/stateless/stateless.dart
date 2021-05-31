import '../../base/keys.dart';
import '../../html/interface/html.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

abstract class StatelessWidget implements Widget {
  @override
  final Key? key;

  const StatelessWidget({this.key});

  Widget build(BuildContext context);

  @override
  HtmlElement2 renderHtml(BuildContext context) => build(context).render(context);

  @override
  HtmlElement2 render(BuildContext context) => renderWidget(this, context);

  @override
  Null renderCss(BuildContext context) => null;
}
