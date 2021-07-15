import '../../../css/css.dart';
import '../../../html/html.dart';

String elementToStringViaManual(
  final HtmlElement2 element,
) =>
    element.acceptHtmlElementOneArg(
      const HtmlElementSerializerVisitorImpl(),
      null,
    );

class HtmlElementSerializerVisitorImpl //
    implements
        HtmlElementVisitorOneArg<String, void>,
        HtmlNodeVisitorOneArg<String, void> {
  static String serializeCss(
    final CssStyleDeclaration2 css,
  ) {
    return [
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
  }

  static String singleElementToString(
    final String tag,
    final List<String> additionalAttrib,
    final HtmlElement2 element,
    final String? altContent,
  ) {
    final id = element.id;
    final className = element.className;
    final css = element.style;
    final cssContent = serializeCss(css);
    final attributes = [
      if (className != null) 'class="$className"',
      if (id != null) 'id="$id"',
      if (cssContent.isNotEmpty) 'style="${cssContent}"',
      ...additionalAttrib,
    ].join(" ");
    final _alements = <HtmlElement2>[];
    final _attributes = <HtmlNode>[];
    final collectorVisitor = MatchNodeVisitor(_attributes.add, _alements.add);
    for (final child in element.childNodes) {
      child.acceptHtmlEntityOneArg(collectorVisitor, null);
    }
    final content = altContent ??
        _attributes //
                .map((final a) => a.acceptHtmlNodeOneArg(const HtmlElementSerializerVisitorImpl(), null))
                .join(" ") +
            " " +
            _alements //
                .map((final a) => a.acceptHtmlElementOneArg(const HtmlElementSerializerVisitorImpl(), null))
                .join("\n");
    return "<" + tag + (attributes.isEmpty ? "" : " " + attributes) + ">" + content + "</" + tag + ">";
  }

  const HtmlElementSerializerVisitorImpl();

  @override
  String visitElementAnchor(
    final AnchorElement2 node,
    final void arg,
  ) =>
      singleElementToString(
        "a",
        [
          if (node.href != null) 'href="${node.href!}"',
          if (node.target != null) 'target="${node.target!}"',
        ],
        node,
        null,
      );

  @override
  String visitElementBody(
    final BodyElement2 node,
    final void arg,
  ) =>
      singleElementToString("body", [], node, null);

  @override
  String visitElementBr(
    final BRElement2 node,
    final void arg,
  ) =>
      singleElementToString("br", [], node, null);

  @override
  String visitElementDiv(
    final DivElement2 node,
    final void arg,
  ) =>
      singleElementToString("div", [], node, null);

  @override
  String visitElementHead(
    final HeadElement2 node,
    final void arg,
  ) =>
      singleElementToString("head", [], node, null);

  @override
  String visitElementHtmlHtml(
    final HtmlHtmlElement2 node,
    final void arg,
  ) =>
      singleElementToString("html", [], node, null);

  @override
  String visitElementImage(
    final ImageElement2 node,
    final void arg,
  ) =>
      singleElementToString(
        "img",
        [
          if (node.src != null) 'src="${node.src!}"',
          if (node.alt != null) 'alt="${node.alt!}"',
        ],
        node,
        null,
      );

  @override
  String visitElementLink(
    final LinkElement2 node,
    final void arg,
  ) =>
      singleElementToString(
        "link",
        [
          if (node.href != null) 'href="${node.href!}"',
          if (node.rel != null) 'rel="${node.rel!}"',
        ],
        node,
        null,
      );

  @override
  String visitElementMeta(
    final MetaElement2 node,
    final void arg,
  ) =>
      singleElementToString(
        "meta",
        () {
          final attributes = <String>[];
          node.forEachAttribute((key, value) => attributes.add('${key}="${value}"'));
          return attributes;
        }(),
        node,
        null,
      );

  @override
  String visitElementParagraph(
    final ParagraphElement2 node,
    final void arg,
  ) =>
      singleElementToString("p", [], node, null);

  @override
  String visitElementScript(
    final ScriptElement2 node,
    final void arg,
  ) =>
      singleElementToString(
        "script",
        [
          if (node.src != null) 'src="${node.src!}"',
          if (node.async != null) 'alt="${node.async!}"',
          if (node.defer != null) 'alt="${node.defer!}"',
        ],
        node,
        null,
      );

  @override
  String visitElementStyle(
    final StyleElement2 node,
    final void arg,
  ) =>
      singleElementToString("style", [], node, null);

  @override
  String visitElementTitle(
    final TitleElement2 node,
    final void arg,
  ) =>
      singleElementToString(
        "title",
        [],
        node,
        node.text != null ? node.text! : "",
      );

  @override
  String visitNodeStyle(
    final CssTextElement2 node,
    final void arg,
  ) =>
      ".${node.key} { " + serializeCss(node.css) + " }";

  @override
  String visitNodeText(
    final RawTextElement2 node,
    final void arg,
  ) =>
      node.text;
}

class MatchNodeVisitor //
    implements
        HtmlEntityVisitorOneArg<void, void> {
  final void Function(HtmlNode) onAttribute;
  final void Function(HtmlElement2) onContent;

  const MatchNodeVisitor(
    final this.onAttribute,
    final this.onContent,
  );

  @override
  void visitEntityElement(
    final HtmlElement2 node,
    final void arg,
  ) =>
      onContent(node);

  @override
  void visitEntityNode(
    final HtmlNode node,
    final void arg,
  ) =>
      onAttribute(node);
}
