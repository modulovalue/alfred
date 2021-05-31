import '../../base/keys.dart';
import '../../css/interface/css.dart';
import '../../html/impl/html.dart';
import '../../html/interface/html.dart';
import '../widget/impl/resolve_url.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

enum ClickState { inactive, hover, active }

class Click implements Widget {
  final String url;
  final Widget Function(BuildContext context, ClickState value) builder;
  final bool newTab;
  @override
  final Key? key;

  const Click({
    required this.url,
    required this.builder,
    this.newTab = false,
    this.key,
  });

  @override
  HtmlElement2 renderHtml(BuildContext context) {
    final result = AnchorElement2Impl();
    result.className = 'click';
    result.href = resolveUrl(context, url);
    if (newTab) {
      result.target = '_blank';
    }
    final inactive = builder(context, ClickState.inactive).render(context);
    final active = builder(context, ClickState.active).render(context);
    final hover = builder(context, ClickState.hover).render(context);
    inactive.className = inactive.className! + ' inactive';
    active.className = active.className! + ' active';
    hover.className = hover.className! + ' hover';
    result.childNodes.add(inactive);
    result.childNodes.add(active);
    result.childNodes.add(hover);
    return result;
  }

  @override
  HtmlElement2 render(BuildContext context) => renderWidget(this, context);

  @override
  CssStyleDeclaration2? renderCss(BuildContext context) => null;
}
