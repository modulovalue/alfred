import '../../base/keys.dart';
import '../../css/css.dart';
import '../../html/html.dart';
import '../../html/html_impl.dart';
import '../widget/impl/resolve_url.dart';
import '../widget/impl/widget_mixin.dart';
import '../widget/interface/build_context.dart';
import '../widget/interface/widget.dart';

enum ClickState {
  inactive,
  hover,
  active,
}

class Click implements Widget {
  final String url;
  final Widget Function(BuildContext context, ClickState value) builder;
  final bool newTab;
  @override
  final Key? key;

  const Click({
    required final this.url,
    required final this.builder,
    final this.newTab = false,
    final this.key,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      AnchorElementImpl(
        href: resolveUrl(
          context: context,
          url: url,
        ),
        className: 'click',
        target: () {
          if (newTab) {
            return '_blank';
          } else {
            return null;
          }
        }(),
        childNodes: [
          () {
            // TODO when is a button inactive?
            final builtInactive = builder(
              context,
              ClickState.inactive,
            );
            final inactive = builtInactive.render(
              context: context,
            );
            // TODO need a redirecting node that can mutate the class name and redirect the rest.
            inactive.className = inactive.className! + ' inactive';
            return inactive;
          }(),
          () {
            final builtActive = builder(
              context,
              ClickState.active,
            );
            final active = builtActive.render(
              context: context,
            );
            active.className = active.className! + ' active';
            return active;
          }(),
          () {
            final builtHover = builder(
              context,
              ClickState.hover,
            );
            final hover = builtHover.render(
              context: context,
            );
            hover.className = hover.className! + ' hover';
            return hover;
          }(),
        ],
      );

  @override
  HtmlElement render({
    required final BuildContext context,
  }) =>
      renderWidget(
        context: context,
        child: this,
      );

  @override
  CssStyleDeclaration? renderCss({
    required final BuildContext context,
  }) =>
      null;
}
