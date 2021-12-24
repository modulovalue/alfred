// TODO remove this dependency.
import 'dart:io';

import '../base/keys.dart';
import '../html/html.dart';
import '../html/pretty.dart';
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
    required final this.newTab,
    final this.key,
  });

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlEntityElementImpl(
        element: HtmlElementAnchorImpl(
          id: null,
          otherAdditionalAttributes: [],
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
              return HtmlEntityElementImpl(
                element: HtmlElementCopyImpl(
                  other: inactive.element,
                  className: elementClassname(
                        element: inactive.element,
                      )! +
                      ' inactive',
                  id: elementId(
                    element: inactive.element,
                  ),
                ),
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
              return HtmlEntityElementImpl(
                element: HtmlElementCopyImpl(
                  other: active.element,
                  className: elementClassname(
                        element: active.element,
                      )! +
                      ' active',
                  id: elementId(
                    element: active.element,
                  ),
                ),
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
              return HtmlEntityElementImpl(
                element: HtmlElementCopyImpl(
                  other: hover.element,
                  className: elementClassname(
                        element: hover.element,
                      )! +
                      ' hover',
                  id: elementId(
                    element: hover.element,
                  ),
                ),
              );
            }(),
          ],
        ),
      );
}
