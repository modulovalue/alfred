import '../css/css.dart';
import '../html/html.dart';

// TODO use StringBuffer, thread it through the visitors arg parameter.
/// Serializes the given HtmlElement into an html string.
String serializeHtmlElement({
  required final HtmlElement element,
}) =>
    _serializeHtmlNode(
      tag: element.tag,
      additionalAttrib: element.additionalAttributes,
      element: element,
    );

// TODO use StringBuffer, thread it through the visitors arg parameter.
String serializeHtmlNode({
  required final HtmlNode node,
}) =>
    node.acceptHtmlNode(
      const _HtmlNodeVisitorImpl._(),
      null,
    );

class _HtmlNodeVisitorImpl implements HtmlNodeVisitor<String, void> {
  const _HtmlNodeVisitorImpl._();

  @override
  String visitNodeStyle(
    final CssTextElement node,
    final void arg,
  ) =>
      ".${node.key} { " +
      serializeCss(
        css: node.css,
      ) +
      " }";

  @override
  String visitNodeText(
    final RawTextElement node,
    final void arg,
  ) =>
      node.text;
}

String _serializeHtmlNode({
  required final String tag,
  required final Iterable<String> additionalAttrib,
  required final HtmlElement element,
}) {
  final buffer = StringBuffer();
  safeStringBufferWrite(buffer, "<");
  safeStringBufferWrite(buffer, () {
    final cssContent = () {
      final css = element.style;
      if (css != null) {
        return serializeCss(css: css);
      } else {
        return null;
      }
    }();
    final className = element.className;
    final id = element.id;
    return [
      tag,
      if (className != null) //
        'class="' + className + '"',
      if (id != null) //
        'id="' + id + '"',
      if (cssContent != null && cssContent.isNotEmpty) //
        'style="' + cssContent + '"',
      ...additionalAttrib,
    ].join(" ");
  }());
  safeStringBufferWrite(buffer, ">");
  safeStringBufferWrite(buffer, () {
    final elementAndAttiributesVisitor = _CollectingHtmlEntityVisitor();
    for (final child in element.childNodes) {
      child.acceptHtmlEntity(
        elementAndAttiributesVisitor,
        null,
      );
    }
    final _attributes = () {
      final attributes = elementAndAttiributesVisitor.attributes;
      if (attributes.isEmpty) {
        return "";
      } else {
        return attributes.map((final a) => serializeHtmlNode(node: a)).join(" ");
      }
    }();
    final _elements = () {
      final elements = elementAndAttiributesVisitor.elements;
      if (elements.isEmpty) {
        return "";
      } else {
        return elements.map((final a) => serializeHtmlElement(element: a)).join("\n");
      }
    }();
    if (_attributes == "") {
      if (_elements == "") {
        return "";
      } else {
        return _elements;
      }
    } else {
      if (_elements == "") {
        return _attributes;
      } else {
        return _attributes + " " + _elements;
      }
    }
  }());
  safeStringBufferWrite(buffer, "</");
  safeStringBufferWrite(buffer, tag);
  safeStringBufferWrite(buffer, ">");
  return buffer.toString();
}

/// Converts the given [CssStyleDeclaration] into a css string.
// TODO use string buffer.
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

/// Makes sure that buffer.write will only
/// be called with values of type String.
void safeStringBufferWrite(
  final StringBuffer buffer,
  final String value,
) =>
    buffer.write(value);
