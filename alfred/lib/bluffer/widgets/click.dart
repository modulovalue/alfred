// TODO remove this dependency.
import 'dart:io';

import '../base/keys.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import '../widget/resolve_url.dart';
import '../widget/widget.dart';
import 'stateless.dart';

enum ClickState {
  inactive,
  hover,
  active,
}

class Click with NoCSSMixin, RenderElementMixin implements Widget {
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
          pathSeparator: Platform.pathSeparator,
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
            final inactive = builtInactive.renderElement(
              context: context,
            );
            // TODO need a redirecting node that can mutate the class name and redirect the rest.
            return inactive.overwrite(
              className: inactive.className! + ' inactive',
            );
          }(),
          () {
            final builtActive = builder(
              context,
              ClickState.active,
            );
            final active = builtActive.renderElement(
              context: context,
            );
            return active.overwrite(
              className: active.className! + ' active',
            );
          }(),
          () {
            final builtHover = builder(
              context,
              ClickState.hover,
            );
            final hover = builtHover.renderElement(
              context: context,
            );
            return hover.overwrite(
              className: hover.className! + ' hover',
            );
          }(),
        ],
      );
}
