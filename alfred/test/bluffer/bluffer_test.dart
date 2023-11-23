import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/html/html.dart';
import 'package:alfred/bluffer/publish/publish.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:test/test.dart';

void main() {
  group("bluffer tests", () {
    test("smoketest css", () {
      expect(
        single_page(
          builder: (final context) => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("a", textAlign: TextAlign.start),
              Text("b"),
            ],
          ),
        ),
        '<div><p class="_w1">a</p>\n'
            '<p class="_w2">b</p></div>',
      );
    });
    test("smoketest", () {
      expect(
        single_page(
          builder: (final context) => const TableImpl(
            children: [
              TableRowImpl(
                children: [
                  TableHeadImpl(
                    child: Text("A"),
                  ),
                  TableHeadImpl(
                    child: Text("B"),
                  ),
                  TableHeadImpl(
                    child: Text("C"),
                  ),
                ],
              ),
              TableRowImpl(
                children: [
                  TableDataImpl(
                    child: Text("1"),
                  ),
                  TableDataImpl(
                    child: Text("2"),
                  ),
                  TableDataImpl(
                    child: Text("3"),
                  ),
                ],
              ),
              TableRowImpl(
                children: [
                  TableDataImpl(
                    child: Text("a"),
                  ),
                  TableDataImpl(
                    child: Text("b"),
                  ),
                  TableDataImpl(
                    child: Text("c"),
                  ),
                ],
              ),
            ],
          ),
        ),
        '<table><tr><th><p class="_w0">A</p></th>\n'
        '<th><p class="_w1">B</p></th>\n'
        '<th><p class="_w2">C</p></th></tr>\n'
        '<tr><td><p class="_w3">1</p></td>\n'
        '<td><p class="_w4">2</p></td>\n'
        '<td><p class="_w5">3</p></td></tr>\n'
        '<tr><td><p class="_w6">a</p></td>\n'
        '<td><p class="_w7">b</p></td>\n'
        '<td><p class="_w8">c</p></td></tr></table>',
      );
      // Add fixture back
    });
    test("all", () {
      final result =
      html_element_to_string(
        // element: AppWidget(
        //   includes: includes,
        //   enableCssReset: enable_css_reset,
        //   route: WidgetRouteSimpleImpl(
        //     title: title,
        //     child: builder(
        //       c,
        //       context,
        //     ),
        //   ),
        // ),
        element: HtmlElementBodyImpl(
          idClass: null,
          childNodes: [
            HtmlEntityNodeImpl(
              text: "LoremIpsum",
            ),
            HtmlEntityElementImpl(
              element: HtmlElementBrImpl(
                idClass: null,
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementHtmlImpl(
                childNodes: [],
                idClass: null,
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementMetaImpl(
                idClass: null,
                attributes: [
                  Attribute(
                    key: "attributekey",
                    value: "attributevalue",
                  ),
                ],
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementBodyImpl(
                childNodes: [],
                idClass: null,
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementCustomImpl(
                childNodes: [],
                idClass: null,
                tag: "custom-tag",
                attributes: [
                  Attribute(
                    key: "attributekey",
                    value: "attributevalue",
                  ),
                ],
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementScriptImpl(
                src: "src",
                async: true,
                defer: true,
                idClass: null,
                crossorigin: "crossorigin",
                integrity: "integrity",
                rel: "rel",
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementLinkImpl(
                idClass: null,
                href: "href",
                rel: "rel",
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementTitleImpl(
                text: "text",
                idClass: null,
              ),
            ),
            // HtmlEntityElementImpl(
            //   element: HtmlElementStyleImpl(
            //     idClass: IdClassImpl(
            //       className: "class",
            //       id: "id",
            //     ),
            //     styles: [
            //       StyleContentStyleImpl(
            //         content: HtmlStyleImpl(
            //           key: CssKeyRawImpl(
            //             key: "key",
            //           ),
            //           css: CssStyleDeclarationImpl(
            //             css_margin: "#",
            //             css_maxHeight: "#",
            //             css_maxWidth: "#",
            //             css_minHeight: "#",
            //             css_minWidth: "#",
            //             css_display: "#",
            //             css_backgroundColor: "#",
            //             css_backgroundImage: "#",
            //             css_backgroundPosition: "#",
            //             css_backgroundSize: "#",
            //             css_borderTopLeftRadius: "#",
            //             css_borderTopRightRadius: "#",
            //             css_borderBottomLeftRadius: "#",
            //             css_borderBottomRightRadius: "#",
            //             css_boxShadow: "#",
            //             css_flexDirection: "#",
            //             css_justifyContent: "#",
            //             css_alignItems: "#",
            //             css_flexGrow: "#",
            //             css_flexShrink: "#",
            //             css_flexBasis: "#",
            //             css_objectFit: "#",
            //             css_width: "#",
            //             css_height: "#",
            //             css_textAlign: "#",
            //             css_lineHeight: "#",
            //             css_fontSize: "#",
            //             css_color: "#",
            //             css_fontWeight: "#",
            //             css_fontFamily: "#",
            //             css_cursor: "#",
            //             css_padding: "#",
            //             css_border: "#",
            //             css_font: "#",
            //             css_verticalAlign: "#",
            //             css_listStyle: "#",
            //             css_quotes: "#",
            //             css_content: "#",
            //             css_borderCollapse: "#",
            //             css_spacing: "#",
            //             css_textDecoration: "#",
            //           ),
            //         ),
            //       ),
            //       StyleContentStructureImpl(
            //         key: CssKeyRawImpl(
            //           key: "outer",
            //         ),
            //         style: [
            //           HtmlStyleImpl(
            //             key: CssKeyRawImpl(
            //               key: "inner",
            //             ),
            //             css: CssStyleDeclarationImpl(
            //               css_margin: "#",
            //               css_maxHeight: "#",
            //               css_maxWidth: "#",
            //               css_minHeight: "#",
            //               css_minWidth: "#",
            //               css_display: "#",
            //               css_backgroundColor: "#",
            //               css_backgroundImage: "#",
            //               css_backgroundPosition: "#",
            //               css_backgroundSize: "#",
            //               css_borderTopLeftRadius: "#",
            //               css_borderTopRightRadius: "#",
            //               css_borderBottomLeftRadius: "#",
            //               css_borderBottomRightRadius: "#",
            //               css_boxShadow: "#",
            //               css_flexDirection: "#",
            //               css_justifyContent: "#",
            //               css_alignItems: "#",
            //               css_flexGrow: "#",
            //               css_flexShrink: "#",
            //               css_flexBasis: "#",
            //               css_objectFit: "#",
            //               css_width: "#",
            //               css_height: "#",
            //               css_textAlign: "#",
            //               css_lineHeight: "#",
            //               css_fontSize: "#",
            //               css_color: "#",
            //               css_fontWeight: "#",
            //               css_fontFamily: "#",
            //               css_cursor: "#",
            //               css_padding: "#",
            //               css_border: "#",
            //               css_font: "#",
            //               css_verticalAlign: "#",
            //               css_listStyle: "#",
            //               css_quotes: "#",
            //               css_content: "#",
            //               css_borderCollapse: "#",
            //               css_spacing: "#",
            //               css_textDecoration: "#",
            //             ),
            //           )
            //         ],
            //       )
            //     ],
            //   ),
            // ),
            HtmlEntityElementImpl(
              element: HtmlElementImageImpl(
                alt: "alt",
                src: "src",
                childNodes: [],
                idClass: null,
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementDivImpl(
                attributes: [
                  Attribute(
                    key: "attributekey",
                    value: "attributevalue",
                  ),
                ],
                childNodes: [],
                idClass: null,
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementAnchorImpl(
                target: "target",
                href: "href",
                attributes: [
                  Attribute(
                    key: "attributekey",
                    value: "attributevalue",
                  ),
                ],
                childNodes: [],
                idClass: null,
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementHeadImpl(
                childNodes: [],
                idClass: null,
              ),
            ),
          ],
        ),
      );
      // TODO • add fixture.
      print(result);
    });
  });
}
