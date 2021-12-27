// TODO remove this dependency.
import 'dart:io';

import '../base/keys.dart';
import '../html/html.dart';
import '../widget/resolve_url.dart';
import '../widget/widget.dart';
import 'stateless.dart';

class Click with NoCSSMixin, RenderElementMixin implements Widget {
  final String url;
  final Widget Function(BuildContext context) builder;
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
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementAnchorImpl(
        attributes: [],
        href: resolveUrl(
          context: context,
          url: url,
          pathSeparator: Platform.pathSeparator,
        ),
        idClass: const IdClassImpl(
          id: null,
          className: 'click',
        ),
        target: () {
          if (newTab) {
            return '_blank';
          } else {
            return null;
          }
        }(),
        childNodes: [
          HtmlEntityElementImpl(
            element: builder(
              context,
            ).renderElement(
              context: context,
            ),
          ),
        ],
      );
}
