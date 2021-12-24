import '../../html/html.dart';
import '../../widget/widget.dart';
import '../../widgets/stateless.dart';

class BootstrapAccordion with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final Iterable<AccordionEntry> entries;

  const BootstrapAccordion({
    required final this.entries,
  });

  @override
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlEntityElementImpl(
        element: HtmlElementDivImpl(
          otherAdditionalAttributes: [],
          className: null,
          id: "accordion",
          childNodes: () sync* {
            int i = 0;
            for (final entry in entries) {
              yield HtmlEntityElementImpl(
                element: HtmlElementDivImpl(
                  otherAdditionalAttributes: [],
                  id: null,
                  className: "card",
                  childNodes: [
                    HtmlEntityElementImpl(
                      element: HtmlElementDivImpl(
                        otherAdditionalAttributes: [],
                        id: null,
                        className: "card-header",
                        childNodes: [
                          HtmlEntityElementImpl(
                            element: HtmlElementAnchorImpl(
                              id: null,
                              target: null,
                              className: "btn",
                              otherAdditionalAttributes: [
                                const MapEntry(
                                  "data-bs-toggle",
                                  "collapse",
                                ),
                              ],
                              href: "#collapse" + i.toString(),
                              childNodes: [
                                HtmlEntityNodeImpl(
                                  text: entry.title,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    HtmlEntityElementImpl(
                      element: HtmlElementDivImpl(
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
                          HtmlEntityElementImpl(
                            element: HtmlElementDivImpl(
                              otherAdditionalAttributes: [],
                              id: null,
                              className: "card-body",
                              childNodes: [
                                entry.body.renderElement(context: context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
              i++;
            }
          }()
              .toList(),
        ),
      );
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
