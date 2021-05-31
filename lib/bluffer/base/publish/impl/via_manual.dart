import '../../../css/interface/css.dart';
import '../../../html/interface/html.dart';

String elementToStringViaManual(HtmlElement2 element) => //
    element.acceptHtmlElementOneArg(const HtmlElementSerializerVisitorImpl(), null);

class HtmlElementSerializerVisitorImpl //
    implements
        HtmlElementVisitorOneArg<String, void>,
        HtmlNodeVisitorOneArg<String, void> {
  static String serializeCss(CssStyleDeclaration2 css) {
    return [
      if (css.margin != null) "margin: " + css.margin!,
      if (css.maxHeight != null) "max-height: " + css.maxHeight!,
      if (css.maxWidth != null) "max-width: " + css.maxWidth!,
      if (css.display != null) "display: " + css.display!,
      if (css.backgroundColor != null) "background-color: " + css.backgroundColor!,
      if (css.backgroundImage != null) "background-image: " + css.backgroundImage!,
      if (css.backgroundPosition != null) "background-position: " + css.backgroundPosition!,
      if (css.backgroundSize != null) "background-size: " + css.backgroundSize!,
      if (css.borderTopLeftRadius != null) "border-top-left-radius: " + css.borderTopLeftRadius!,
      if (css.borderTopRightRadius != null) "border-top-right-radius: " + css.borderTopRightRadius!,
      if (css.borderBottomLeftRadius != null) "border-bottom-left-radius: " + css.borderBottomLeftRadius!,
      if (css.borderBottomRightRadius != null) "border-bottom-right-radius: " + css.borderBottomRightRadius!,
      if (css.boxShadow != null) "box-shadow: " + css.boxShadow!,
      if (css.flexDirection != null) "flex-direction: " + css.flexDirection!,
      if (css.justifyContent != null) "justify-content: " + css.justifyContent!,
      if (css.alignItems != null) "align-items: " + css.alignItems!,
      if (css.flexGrow != null) "flex-grow: " + css.flexGrow!,
      if (css.flexShrink != null) "flex-shrink: " + css.flexShrink!,
      if (css.flexBasis != null) "flex-basis: " + css.flexBasis!,
      if (css.objectFit != null) "object-fit: " + css.objectFit!,
      if (css.width != null) "width: " + css.width!,
      if (css.height != null) "height: " + css.height!,
      if (css.textAlign != null) "text-align: " + css.textAlign!,
      if (css.lineHeight != null) "line-height: " + css.lineHeight!,
      if (css.fontSize != null) "font-size: " + css.fontSize!,
      if (css.color != null) "color: " + css.color!,
      if (css.fontWeight != null) "font-weight: " + css.fontWeight!,
      if (css.fontFamily != null) "font-family: " + css.fontFamily!,
    ].join("; ");
  }

  static String singleElementToString(String tag, List<String> additionalAttrib, HtmlElement2 element, String? altContent) {
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
        "${_attributes.map((a) => a.acceptHtmlNodeOneArg(const HtmlElementSerializerVisitorImpl(), null)).join(" ")} ${_alements.map((a) => a.acceptHtmlElementOneArg(const HtmlElementSerializerVisitorImpl(), null)).join("\n")}";
    return "<$tag${attributes.isEmpty ? "" : " " + attributes}>${content}</$tag>";
  }

  const HtmlElementSerializerVisitorImpl();

  @override
  String visitElementAnchor(AnchorElement2 node, void arg) => //
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
  String visitElementBody(BodyElement2 node, void arg) => //
      singleElementToString("body", [], node, null);

  @override
  String visitElementBr(BRElement2 node, void arg) => //
      singleElementToString("br", [], node, null);

  @override
  String visitElementDiv(DivElement2 node, void arg) => //
      singleElementToString("div", [], node, null);

  @override
  String visitElementHead(HeadElement2 node, void arg) => //
      singleElementToString("head", [], node, null);

  @override
  String visitElementHtmlHtml(HtmlHtmlElement2 node, void arg) => //
      singleElementToString("html", [], node, null);

  @override
  String visitElementImage(ImageElement2 node, void arg) => //
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
  String visitElementLink(LinkElement2 node, void arg) => //
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
  String visitElementMeta(MetaElement2 node, void arg) => //
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
  String visitElementParagraph(ParagraphElement2 node, void arg) => //
      singleElementToString("p", [], node, null);

  @override
  String visitElementScript(ScriptElement2 node, void arg) => //
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
  String visitElementStyle(StyleElement2 node, void arg) => //
      singleElementToString("style", [], node, null);

  @override
  String visitElementTitle(TitleElement2 node, void arg) => //
      singleElementToString(
        "title",
        [],
        node,
        node.text != null ? node.text! : "",
      );

  @override
  String visitNodeStyle(CssTextElement2 node, void arg) => //
      ".${node.key} { " + serializeCss(node.css) + " }";

  @override
  String visitNodeText(RawTextElement2 node, void arg) => //
      node.text;
}

class MatchNodeVisitor //
    implements
        HtmlEntityVisitorOneArg<void, void> {
  final void Function(HtmlNode) onAttribute;
  final void Function(HtmlElement2) onContent;

  const MatchNodeVisitor(this.onAttribute, this.onContent);

  @override
  void visitEntityElement(HtmlElement2 node, void arg) => onContent(node);

  @override
  void visitEntityNode(HtmlNode node, void arg) => onAttribute(node);
}
