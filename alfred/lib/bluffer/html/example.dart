import 'html.dart';
import 'pretty.dart';

void main() {
  final result = htmlElementToString(
    element: const HtmlElementBodyImpl(
      className: null,
      id: null,
      childNodes: [
        HtmlEntityNodeImpl(
          text: "LoremIpsum",
        ),
        HtmlEntityElementImpl(
          element: HtmlElementCopyImpl(
            id: "overridden id",
            className: "overridden class",
            other: HtmlElementStyleImpl(
              className: "class",
              id: "id",
              childNodes: [],
            ),
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementAppendedImpl(
            other: HtmlElementStyleImpl(
              className: "class",
              id: "id",
              childNodes: [],
            ),
            additional: [
              HtmlEntityElementImpl(
                element: HtmlElementStyleImpl(
                  className: "class",
                  id: "id",
                  childNodes: [],
                ),
              ),
            ],
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementBrImpl(
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementHtmlImpl(
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementMetaImpl(
            childNodes: [],
            className: null,
            id: null,
            attributes: [
              MapEntry(
                "attributekey",
                "attributevalue",
              ),
            ],
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementBodyImpl(
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementCustomImpl(
            childNodes: [],
            className: null,
            id: null,
            tag: "custom-tag",
            additionalAttributes: [
              MapEntry(
                "attributekey",
                "attributevalue",
              ),
            ],
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementScriptImpl(
            src: "src",
            async: true,
            defer: true,
            className: null,
            id: null,
            crossorigin: "crossorigin",
            integrity: "integrity",
            rel: "rel",
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementLinkImpl(
            childNodes: [],
            className: null,
            id: null,
            href: "href",
            rel: "rel",
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementTitleImpl(
            text: "text",
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementStyleImpl(
            className: "class",
            id: "id",
            childNodes: [
              StyleContentStyleImpl(
                content: HtmlStyleImpl(
                  key: CssKeyImpl(key: "key"),
                  css: CssStyleDeclarationImpl(
                    css_margin: "#",
                    css_maxHeight: "#",
                    css_maxWidth: "#",
                    css_minHeight: "#",
                    css_minWidth: "#",
                    css_display: "#",
                    css_backgroundColor: "#",
                    css_backgroundImage: "#",
                    css_backgroundPosition: "#",
                    css_backgroundSize: "#",
                    css_borderTopLeftRadius: "#",
                    css_borderTopRightRadius: "#",
                    css_borderBottomLeftRadius: "#",
                    css_borderBottomRightRadius: "#",
                    css_boxShadow: "#",
                    css_flexDirection: "#",
                    css_justifyContent: "#",
                    css_alignItems: "#",
                    css_flexGrow: "#",
                    css_flexShrink: "#",
                    css_flexBasis: "#",
                    css_objectFit: "#",
                    css_width: "#",
                    css_height: "#",
                    css_textAlign: "#",
                    css_lineHeight: "#",
                    css_fontSize: "#",
                    css_color: "#",
                    css_fontWeight: "#",
                    css_fontFamily: "#",
                    css_cursor: "#",
                    css_padding: "#",
                    css_border: "#",
                    css_font: "#",
                    css_verticalAlign: "#",
                    css_listStyle: "#",
                    css_quotes: "#",
                    css_content: "#",
                    css_borderCollapse: "#",
                    css_spacing: "#",
                    css_textDecoration: "#",
                  ),
                ),
              ),
              StyleContentStructureImpl(
                key: CssKeyImpl(key: "outer"),
                style: [
                  HtmlStyleImpl(
                    key: CssKeyImpl(key: "inner"),
                    css: CssStyleDeclarationImpl(
                      css_margin: "#",
                      css_maxHeight: "#",
                      css_maxWidth: "#",
                      css_minHeight: "#",
                      css_minWidth: "#",
                      css_display: "#",
                      css_backgroundColor: "#",
                      css_backgroundImage: "#",
                      css_backgroundPosition: "#",
                      css_backgroundSize: "#",
                      css_borderTopLeftRadius: "#",
                      css_borderTopRightRadius: "#",
                      css_borderBottomLeftRadius: "#",
                      css_borderBottomRightRadius: "#",
                      css_boxShadow: "#",
                      css_flexDirection: "#",
                      css_justifyContent: "#",
                      css_alignItems: "#",
                      css_flexGrow: "#",
                      css_flexShrink: "#",
                      css_flexBasis: "#",
                      css_objectFit: "#",
                      css_width: "#",
                      css_height: "#",
                      css_textAlign: "#",
                      css_lineHeight: "#",
                      css_fontSize: "#",
                      css_color: "#",
                      css_fontWeight: "#",
                      css_fontFamily: "#",
                      css_cursor: "#",
                      css_padding: "#",
                      css_border: "#",
                      css_font: "#",
                      css_verticalAlign: "#",
                      css_listStyle: "#",
                      css_quotes: "#",
                      css_content: "#",
                      css_borderCollapse: "#",
                      css_spacing: "#",
                      css_textDecoration: "#",
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementImageImpl(
            alt: "alt",
            src: "src",
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementDivImpl(
            otherAdditionalAttributes: [
              MapEntry(
                "attributekey",
                "attributevalue",
              ),
            ],
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementAnchorImpl(
            target: "target",
            href: "href",
            otherAdditionalAttributes: [
              MapEntry(
                "attributekey",
                "attributevalue",
              ),
            ],
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
        HtmlEntityElementImpl(
          element: HtmlElementHeadImpl(
            childNodes: [],
            className: null,
            id: null,
          ),
        ),
      ],
    ),
  );
  print(result);
}
