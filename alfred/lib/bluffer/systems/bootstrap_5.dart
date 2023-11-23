import '../base/app.dart';
import '../html/html.dart';
import '../widget/widget.dart';
import 'flutter.dart';

const AppIncludes bootstrapIncludes = AppIncludesImpl(
  stylesheetLinks: [
    // TODO pass in model to give rel crossorigin and integrity https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
    "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css",
  ],
  scriptLinks: [
    HtmlElementScriptImpl(
      async: null,
      defer: null,
      idClass: null,
      // TODO rel crossorigin integrity https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
      src: "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js",
      integrity: null,
      rel: null,
      crossorigin: null,
    )
  ],
);

// TODO action (open link, execute, others)
// TODO more from https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-buttons.php
class BootstrapButton with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final String text;
  final BootstrapButtonType type;

  const BootstrapButton({
    required this.text,
    this.type = BootstrapButtonType.primary,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "button",
        attributes: [
          const Attribute(
            key: "type",
            value: "button",
          ),
          Attribute(
            key: "class",
            value: 'btn btn-' +
                _serializeBootstrapButtonType(
                  type: type,
                ),
          ),
        ],
        childNodes: [
          HtmlEntityNodeImpl(
            text: text,
          ),
        ],
      );
}

// TODO action.
class BootstrapOutlineButton with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final String text;
  final BootstrapOutlineButtonType type;

  const BootstrapOutlineButton({
    required this.text,
    this.type = BootstrapOutlineButtonType.primary,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementCustomImpl(
        idClass: null,
        tag: "button",
        attributes: [
          const Attribute(
            key: "type",
            value: "button",
          ),
          Attribute(
            key: "class",
            value: 'btn btn-outline-' +
                _serializeBootstrapOutlineButtonType(
                  type: type,
                ),
          ),
        ],
        childNodes: [
          HtmlEntityNodeImpl(
            text: text,
          ),
        ],
      );
}

// TODO have a sum type for the types and share a subset between normal and outline.

String _serializeBootstrapButtonType({
  required final BootstrapButtonType type,
}) {
  switch (type) {
    case BootstrapButtonType.primary:
      return "primary";
    case BootstrapButtonType.secondary:
      return "secondary";
    case BootstrapButtonType.success:
      return "success";
    case BootstrapButtonType.danger:
      return "danger";
    case BootstrapButtonType.warning:
      return "warning";
    case BootstrapButtonType.info:
      return "info";
    case BootstrapButtonType.dark:
      return "dark";
    case BootstrapButtonType.light:
      return "light";
    case BootstrapButtonType.link:
      return "link";
  }
}

String _serializeBootstrapOutlineButtonType({
  required final BootstrapOutlineButtonType type,
}) {
  switch (type) {
    case BootstrapOutlineButtonType.primary:
      return "primary";
    case BootstrapOutlineButtonType.secondary:
      return "secondary";
    case BootstrapOutlineButtonType.success:
      return "success";
    case BootstrapOutlineButtonType.danger:
      return "danger";
    case BootstrapOutlineButtonType.warning:
      return "warning";
    case BootstrapOutlineButtonType.info:
      return "info";
    case BootstrapOutlineButtonType.dark:
      return "dark";
  }
}

enum BootstrapButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  dark,
  light,
  link,
}

enum BootstrapOutlineButtonType {
  primary,
  secondary,
  success,
  danger,
  warning,
  info,
  dark,
}

class BootstrapAccordion with RenderElementMixin, NoCSSMixin, NoKeyMixin {
  final Iterable<AccordionEntry> entries;

  const BootstrapAccordion({
    required this.entries,
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
    required this.title,
    required this.body,
    this.showByDefault = false,
  });
}

/// https://getbootstrap.com/docs/5.0/content/tables/
class BootstrapTable with RenderElementMixin, NoKeyMixin, NoCSSMixin {
  final Iterable<TableRowImpl> children;

  const BootstrapTable({
    required this.children,
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementDivImpl(
        attributes: [],
        idClass: const IdClassImpl(
          id: null,
          className: "table-responsive",
        ),
        childNodes: [
          HtmlEntityElementImpl(
            element: TableImpl(
              children: children,
              clazz: "table table-sm table-striped",
            ).renderHtml(
              context: context,
            ),
          ),
        ],
      );
}
