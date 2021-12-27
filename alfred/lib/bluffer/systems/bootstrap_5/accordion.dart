import '../../html/html.dart';
import '../../widget/widget.dart';
import '../../widgets/stateless.dart';

class BootstrapAccordion with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final Iterable<AccordionEntry> entries;

  const BootstrapAccordion({
    required final this.entries,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
        HtmlElementDivImpl(
          attributes: [],
          idClass: const IdClassImpl(
            className: null,
            id: "accordion",
          ),
          childNodes: () sync* {
            int i = 0;
            for (final entry in entries) {
              yield HtmlEntityElementImpl(
                element: HtmlElementDivImpl(
                  attributes: [],
                  idClass: const IdClassImpl(
                    id: null,
                    className: "card",
                  ),
                  childNodes: [
                    HtmlEntityElementImpl(
                      element: HtmlElementDivImpl(
                        attributes: [],
                        idClass: const IdClassImpl(
                          id: null,
                          className: "card-header",
                        ),
                        childNodes: [
                          HtmlEntityElementImpl(
                            element: HtmlElementAnchorImpl(
                              target: null,
                              idClass: const IdClassImpl(
                                id: null,
                                className: "btn",
                              ),
                              attributes: [
                                const Attribute(
                                  key: "data-bs-toggle",
                                  value: "collapse",
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
                        idClass: IdClassImpl(
                          id: "collapse" + i.toString(),
                          className: "collapse" +
                              () {
                                if (entry.showByDefault) {
                                  return " show";
                                } else {
                                  return "";
                                }
                              }(),
                        ),
                        attributes: const [
                          Attribute(
                            key: "data-bs-parent",
                            value: "#accordion",
                          ),
                        ],
                        childNodes: [
                          HtmlEntityElementImpl(
                            element: HtmlElementDivImpl(
                              attributes: [],
                              idClass: const IdClassImpl(
                                id: null,
                                className: "card-body",
                              ),
                              childNodes: [
                                HtmlEntityElementImpl(
                                  element: entry.body.renderElement(
                                    context: context,
                                  ),
                                ),
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
