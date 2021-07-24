import '../../css/css.dart';
import '../../html/html.dart';

/// Serializes the given HtmlElement into an html string.
/// TODO use StringBuffer, thread it through the visitors arg parameter.
String serializeHtml({
  required final HtmlElement html,
}) =>
    html.acceptHtmlElement(HtmlElementSerializerVisitor, null);

const _HtmlElementSerializerVisitorImpl HtmlElementSerializerVisitor = _HtmlElementSerializerVisitorImpl._();

/// TODO extract constants into a spec.
class _HtmlElementSerializerVisitorImpl implements HtmlElementVisitor<String, void>, HtmlNodeVisitor<String, void> {
  const _HtmlElementSerializerVisitorImpl._();

  @override
  String visitElementAnchor(
    final AnchorElement node,
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
    final BodyElement node,
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
    final BRElement node,
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
    final DivElement node,
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
    final HeadElement node,
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
    final HtmlHtmlElement node,
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
    final ImageElement node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "img",
        additionalAttrib: () sync* {
          final src = node.src;
          if (src != null) {
            yield 'src="' + src + '"';
          }
          final alt = node.alt;
          if (alt != null) {
            yield 'alt="' + alt + '"';
          }
        }(),
        element: node,
        altContent: null,
      );

  @override
  String visitElementLink(
    final LinkElement node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "link",
        additionalAttrib: () sync* {
          final href = node.href;
          if (href != null) {
            yield 'href="' + href + '"';
          }
          final rel = node.rel;
          if (rel != null) {
            yield 'rel="' + rel + '"';
          }
        }(),
        element: node,
        altContent: null,
      );

  @override
  String visitElementMeta(
    final MetaElement node,
    final void arg,
  ) =>
      serializeHtmlNode(
        tag: "meta",
        additionalAttrib: () {
          final attributes = <String>[];
          node.forEachAttribute(
            forEach: (final key, final value) => attributes.add(
              key + '="' + value + '"',
            ),
          );
          return attributes;
        }(),
        element: node,
        altContent: null,
      );

  @override
  String visitElementParagraph(
    final ParagraphElement node,
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
    final ScriptElement node,
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
        altContent: node.content,
      );

  @override
  String visitElementStyle(
    final StyleElement node,
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
    final TitleElement node,
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
    final CssTextElement node,
    final void arg,
  ) =>
      ".${node.key} { " + serializeCss(css: node.css) + " }";

  @override
  String visitNodeText(
    final RawTextElement node,
    final void arg,
  ) =>
      node.text;
}

StringBuffer _sharedStringBuffer = StringBuffer();

String serializeHtmlNode({
  required final String tag,
  required final Iterable<String> additionalAttrib,
  required final HtmlElement element,
  required final String? altContent,
}) {
  final buffer = _sharedStringBuffer;
  safeStringBufferWrite(buffer, "<");
  safeStringBufferWrite(buffer, tag);
  safeStringBufferWrite(buffer, () {
    final className = element.className;
    final id = element.id;
    final css = element.style;
    final cssContent = css != null ? serializeCss(css: css) : null;
    final attributes = [
      if (className != null) //
        'class="' + className + '"',
      if (id != null) //
        'id="' + id + '"',
      if (cssContent != null && cssContent.isNotEmpty) //
        'style="' + cssContent + '"',
      ...additionalAttrib,
    ].join(" ");
    if (attributes.isEmpty) {
      return "";
    } else {
      return " " + attributes;
    }
  }());
  safeStringBufferWrite(buffer, ">");
  safeStringBufferWrite(buffer, () {
    final visitor = _CollectingHtmlEntityVisitor();
    for (final child in element.childNodes) {
      child.acceptHtmlEntity(visitor, null);
    }
    if (altContent != null) {
      return altContent;
    } else {
      return visitor. //
              attributes
              .map(
                (final a) => a.acceptHtmlNode(HtmlElementSerializerVisitor, null),
              )
              .join(" ") +
          " " +
          visitor. //
              elements
              .map(
                (final a) => a.acceptHtmlElement(HtmlElementSerializerVisitor, null),
              )
              .join("\n");
    }
  }());
  safeStringBufferWrite(buffer, "</");
  safeStringBufferWrite(buffer, tag);
  safeStringBufferWrite(buffer, ">");
  final result = buffer.toString();
  buffer.clear();
  return result;
}

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
  final List<HtmlElement> elements = <HtmlElement>[];
  final List<HtmlNode> attributes = <HtmlNode>[];

  _CollectingHtmlEntityVisitor();

  @override
  void visitEntityElement(
    final HtmlElement node,
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

void safeStringBufferWrite(
  final StringBuffer buffer,
  final String value,
) =>
    buffer.write(value);
