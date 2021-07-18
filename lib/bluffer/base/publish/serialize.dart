import '../../css/css.dart';
import '../../html/html.dart';

/// Serializes the given HtmlElement into an html string.
/// TODO use StringBuffer, thread it through the visitors arg parameter.
String serializeHtml({
  required final HtmlElement2 html,
}) => html.acceptHtmlElementOneArg(HtmlElementSerializerVisitor, null);

const _HtmlElementSerializerVisitorImpl HtmlElementSerializerVisitor = _HtmlElementSerializerVisitorImpl._();

class _HtmlElementSerializerVisitorImpl implements HtmlElementVisitor<String, void>, HtmlNodeVisitor<String, void> {
  const _HtmlElementSerializerVisitorImpl._();

  @override
  String visitElementAnchor(
    final AnchorElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "a",
        additionalAttrib: [
          if (node.href != null) 'href="${node.href!}"',
          if (node.target != null) 'target="${node.target!}"',
        ],
        element: node,
        altContent: null,
      );

  @override
  String visitElementBody(
    final BodyElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "body",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementBr(
    final BRElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "br",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementDiv(
    final DivElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "div",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementHead(
    final HeadElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "head",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementHtmlHtml(
    final HtmlHtmlElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "html",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementImage(
    final ImageElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "img",
        additionalAttrib: [
          if (node.src != null) 'src="${node.src!}"',
          if (node.alt != null) 'alt="${node.alt!}"',
        ],
        element: node,
        altContent: null,
      );

  @override
  String visitElementLink(
    final LinkElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "link",
        additionalAttrib: [
          if (node.href != null) 'href="${node.href!}"',
          if (node.rel != null) 'rel="${node.rel!}"',
        ],
        element: node,
        altContent: null,
      );

  @override
  String visitElementMeta(
    final MetaElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "meta",
        additionalAttrib: () {
          final attributes = <String>[];
          node.forEachAttribute(
            (final key, final value) => attributes.add('${key}="${value}"'),
          );
          return attributes;
        }(),
        element: node,
        altContent: null,
      );

  @override
  String visitElementParagraph(
    final ParagraphElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "p",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementScript(
    final ScriptElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "script",
        additionalAttrib: [
          if (node.src != null) 'src="${node.src!}"',
          if (node.async != null) 'alt="${node.async!}"',
          if (node.defer != null) 'alt="${node.defer!}"',
        ],
        element: node,
        altContent: null,
      );

  @override
  String visitElementStyle(
    final StyleElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "style",
        additionalAttrib: [],
        element: node,
        altContent: null,
      );

  @override
  String visitElementTitle(
    final TitleElement2 node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "title",
        additionalAttrib: [],
        element: node,
        altContent: () {
          if (node.text != null) {
            return node.text!;
          } else {
            return "";
          }
        }(),
      );

  @override
  String visitNodeStyle(
    final CssTextElement2 node,
    final void arg,
  ) =>
      ".${node.key} { " + serializeCss(css: node.css) + " }";

  @override
  String visitNodeText(
    final RawTextElement2 node,
    final void arg,
  ) =>
      node.text;
}

String serializeHtmlNode({
  required final String tag,
  required final List<String> additionalAttrib,
  required final HtmlElement2 element,
  required final String? altContent,
}) =>
    "<" +
    tag +
    (() {
      final className = element.className;
      final id = element.id;
      final css = element.style;
      final cssContent = serializeCss(css: css);
      final attributes = [
        if (className != null) //
          'class="$className"',
        if (id != null) //
          'id="$id"',
        if (cssContent.isNotEmpty) //
          'style="${cssContent}"',
        ...additionalAttrib,
      ].join(" ");
      if (attributes.isEmpty) {
        return "";
      } else {
        return " " + attributes;
      }
    }()) +
    ">" +
    () {
      final visitor = _CollectingHtmlEntityVisitor();
      for (final child in element.childNodes) {
        child.acceptHtmlEntityOneArg(visitor, null);
      }
      return altContent ??
          visitor. //
                  attributes
                  .map((final a) => a.acceptHtmlNodeOneArg(HtmlElementSerializerVisitor, null))
                  .join(" ") +
              " " +
              visitor. //
                  elements
                  .map((final a) => a.acceptHtmlElementOneArg(HtmlElementSerializerVisitor, null))
                  .join("\n");
    }() +
    "</" +
    tag +
    ">";

/// Converts the given [CssStyleDeclaration] into a css string.
String serializeCss({
  required final CssStyleDeclaration css,
}) =>
    [
      if (css.css_margin != null) "margin: " + css.css_margin!,
      if (css.css_maxHeight != null) "max-height: " + css.css_maxHeight!,
      if (css.css_maxWidth != null) "max-width: " + css.css_maxWidth!,
      if (css.css_display != null) "display: " + css.css_display!,
      if (css.css_backgroundColor != null) "background-color: " + css.css_backgroundColor!,
      if (css.css_backgroundImage != null) "background-image: " + css.css_backgroundImage!,
      if (css.css_backgroundPosition != null) "background-position: " + css.css_backgroundPosition!,
      if (css.css_backgroundSize != null) "background-size: " + css.css_backgroundSize!,
      if (css.css_borderTopLeftRadius != null) "border-top-left-radius: " + css.css_borderTopLeftRadius!,
      if (css.css_borderTopRightRadius != null) "border-top-right-radius: " + css.css_borderTopRightRadius!,
      if (css.css_borderBottomLeftRadius != null) "border-bottom-left-radius: " + css.css_borderBottomLeftRadius!,
      if (css.css_borderBottomRightRadius != null) "border-bottom-right-radius: " + css.css_borderBottomRightRadius!,
      if (css.css_boxShadow != null) "box-shadow: " + css.css_boxShadow!,
      if (css.css_flexDirection != null) "flex-direction: " + css.css_flexDirection!,
      if (css.css_justifyContent != null) "justify-content: " + css.css_justifyContent!,
      if (css.css_alignItems != null) "align-items: " + css.css_alignItems!,
      if (css.css_flexGrow != null) "flex-grow: " + css.css_flexGrow!,
      if (css.css_flexShrink != null) "flex-shrink: " + css.css_flexShrink!,
      if (css.css_flexBasis != null) "flex-basis: " + css.css_flexBasis!,
      if (css.css_objectFit != null) "object-fit: " + css.css_objectFit!,
      if (css.css_width != null) "width: " + css.css_width!,
      if (css.css_height != null) "height: " + css.css_height!,
      if (css.css_textAlign != null) "text-align: " + css.css_textAlign!,
      if (css.css_lineHeight != null) "line-height: " + css.css_lineHeight!,
      if (css.css_fontSize != null) "font-size: " + css.css_fontSize!,
      if (css.css_color != null) "color: " + css.css_color!,
      if (css.css_fontWeight != null) "font-weight: " + css.css_fontWeight!,
      if (css.css_fontFamily != null) "font-family: " + css.css_fontFamily!,
    ].join("; ");

class _CollectingHtmlEntityVisitor implements HtmlEntityVisitor<void, void> {
  final List<HtmlElement2> elements = <HtmlElement2>[];
  final List<HtmlNode> attributes = <HtmlNode>[];

  _CollectingHtmlEntityVisitor();

  @override
  void visitEntityElement(
    final HtmlElement2 node,
    final void arg,
  ) =>
      elements.add(node);

  @override
  void visitEntityNode(
    final HtmlNode node,
    final void arg,
  ) =>
      attributes.add(node);
}
