import '../../html/html.dart';
import '../../html/html_impl.dart';
import '../../widget/widget.dart';
import '../../widgets/stateless.dart';

class BootstrapAccordion with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final Iterable<AccordionEntry> entries;

  const BootstrapAccordion({
    required final this.entries,
  });

  @override
  HtmlElement<HtmlElement> renderHtml({
    required final BuildContext context,
  }) {
    return DivElementImpl(
      id: "accordion",
      childNodes: () sync* {
        int i = 0;
        for (final entry in entries) {
          yield DivElementImpl(
            className: "card",
            childNodes: [
              DivElementImpl(
                className: "card-header",
                childNodes: [
                  AnchorElementImpl(
                    className: "btn",
                    otherAdditionalAttributes: [
                      const MapEntry(
                        "data-bs-toggle",
                        "collapse",
                      ),
                    ],
                    href: "#collapse" + i.toString(),
                    childNodes: [
                      RawTextElementImpl(
                        entry.title,
                      ),
                    ],
                  ),
                ],
              ),
              DivElementImpl(
                id: "collapse" + i.toString(),
                className: "collapse" +
                    () {
                      if (entry.showByDefault) {
                        return " show";
                      } else {
                        return "";
                      }
                    }(),
                otherAdditionalAttributes: const [
                  MapEntry(
                    "data-bs-parent",
                    "#accordion",
                  ),
                ],
                childNodes: [
                  DivElementImpl(
                    className: "card-body",
                    childNodes: [
                      entry.body.renderElement(context: context),
                    ],
                  ),
                ],
              ),
            ],
          );
          i++;
        }
      }()
          .toList(),
    );
  }
}

class AccordionEntry {
  final String title;
  final Widget body;
  final bool showByDefault;

  const AccordionEntry({
    required final this.title,
    required final this.body,
    final this.showByDefault = false,
  });
}
