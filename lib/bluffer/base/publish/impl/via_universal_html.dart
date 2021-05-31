// ignore: implementation_imports
import 'package:universal_html/src/html.dart' as html;

import '../../../css/impl/builder.dart';
import '../../../html/impl/html.dart';
import '../../../html/interface/html.dart';

String elementToStringViaUniversal(HtmlElement2 entity) => //
    entity
        .acceptHtmlElementOneArg(
          const HtmlElementToUniversalVisitorImpl(),
          null,
        )
        .outerHtml!;

class _Selector implements HtmlEntityVisitorOneArg<html.Node, void> {
  const _Selector();

  @override
  html.Node visitEntityElement(HtmlElement2 node, void arg) => //
      node.acceptHtmlElementOneArg(const HtmlElementToUniversalVisitorImpl(), null);

  @override
  html.Node visitEntityNode(HtmlNode node, void arg) => //
      node.acceptHtmlNodeOneArg(const _Nodes(), null);
}

class HtmlElementToUniversalVisitorImpl implements HtmlElementVisitorOneArg<html.HtmlElement, void> {
  static R passOnHtmlElementValues<R extends html.HtmlElement>(
    HtmlElement2 element,
    R other,
  ) {
    if (element.style.margin != null) other.style.margin = element.style.margin;
    if (element.style.maxHeight != null) other.style.maxHeight = element.style.maxHeight;
    if (element.style.maxWidth != null) other.style.maxWidth = element.style.maxWidth;
    if (element.style.minHeight != null) other.style.minHeight = element.style.minHeight;
    if (element.style.minWidth != null) other.style.minWidth = element.style.minWidth;
    if (element.style.display != null) other.style.display = element.style.display;
    if (element.style.backgroundColor != null) other.style.backgroundColor = element.style.backgroundColor;
    if (element.style.backgroundImage != null) other.style.backgroundImage = element.style.backgroundImage;
    if (element.style.backgroundPosition != null) other.style.backgroundPosition = element.style.backgroundPosition;
    if (element.style.backgroundSize != null) other.style.backgroundSize = element.style.backgroundSize;
    if (element.style.borderTopLeftRadius != null) other.style.borderTopLeftRadius = element.style.borderTopLeftRadius;
    if (element.style.borderTopRightRadius != null) other.style.borderTopRightRadius = element.style.borderTopRightRadius;
    if (element.style.borderBottomLeftRadius != null) other.style.borderBottomLeftRadius = element.style.borderBottomLeftRadius;
    if (element.style.borderBottomRightRadius != null) other.style.borderBottomRightRadius = element.style.borderBottomRightRadius;
    if (element.style.boxShadow != null) other.style.boxShadow = element.style.boxShadow;
    if (element.style.flexDirection != null) other.style.flexDirection = element.style.flexDirection;
    if (element.style.justifyContent != null) other.style.justifyContent = element.style.justifyContent;
    if (element.style.alignItems != null) other.style.alignItems = element.style.alignItems;
    if (element.style.flexGrow != null) other.style.flexGrow = element.style.flexGrow;
    if (element.style.flexShrink != null) other.style.flexShrink = element.style.flexShrink;
    if (element.style.flexBasis != null) other.style.flexBasis = element.style.flexBasis;
    if (element.style.height != null) other.style.height = element.style.height;
    if (element.style.textAlign != null) other.style.textAlign = element.style.textAlign;
    if (element.style.lineHeight != null) other.style.lineHeight = element.style.lineHeight;
    if (element.style.fontSize != null) other.style.fontSize = element.style.fontSize;
    if (element.style.color != null) other.style.color = element.style.color;
    if (element.style.fontWeight != null) other.style.fontWeight = element.style.fontWeight;
    if (element.style.fontFamily != null) other.style.fontFamily = element.style.fontFamily;
    if (element.id != null) other.id = element.id!;
    if (element.className != null) other.className = element.className;
    return other
      ..childNodes.addAll(
        element.childNodes.map((a) => a.acceptHtmlEntityOneArg(const _Selector(), null)),
      );
  }

  const HtmlElementToUniversalVisitorImpl();

  @override
  html.HtmlElement visitElementAnchor(AnchorElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.AnchorElement()
          ..href = node.href
          ..target = node.target,
      );

  @override
  html.HtmlElement visitElementBody(BodyElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.BodyElement(),
      );

  @override
  html.HtmlElement visitElementBr(BRElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.BRElement(),
      );

  @override
  html.HtmlElement visitElementDiv(DivElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.DivElement(),
      );

  @override
  html.HtmlElement visitElementHead(HeadElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.HeadElement(),
      );

  @override
  html.HtmlElement visitElementHtmlHtml(HtmlHtmlElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.HtmlHtmlElement(),
      );

  @override
  html.HtmlElement visitElementImage(ImageElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.ImageElement()
          ..src = node.src
          ..alt = node.alt,
      );

  @override
  html.HtmlElement visitElementLink(LinkElement2 node, void arg) {
    final element = html.LinkElement();
    if (node.rel != null) element.rel = node.rel!;
    element.href = node.href;
    return passOnHtmlElementValues(node, element);
  }

  @override
  html.HtmlElement visitElementMeta(MetaElement2 node, void arg) {
    final element = html.MetaElement();
    node.forEachAttribute(element.setAttribute);
    return passOnHtmlElementValues(node, element);
  }

  @override
  html.HtmlElement visitElementParagraph(ParagraphElement2 node, void arg) => //
      passOnHtmlElementValues(node, html.ParagraphElement());

  @override
  html.HtmlElement visitElementScript(ScriptElement2 node, void arg) {
    final element = html.ScriptElement();
    if (node.src != null) element.src = node.src!;
    if (node.defer != null) element.defer = node.defer;
    if (node.async != null) element.async = node.async!;
    return passOnHtmlElementValues(node, element);
  }

  @override
  html.HtmlElement visitElementStyle(StyleElement2 node, void arg) => //
      passOnHtmlElementValues(
        node,
        html.StyleElement(),
      );

  @override
  html.HtmlElement visitElementTitle(TitleElement2 node, void arg) {
    final element = html.TitleElement();
    element.text = node.text;
    return passOnHtmlElementValues(node, element);
  }
}

class _Nodes implements HtmlNodeVisitorOneArg<html.Node, void> {
  const _Nodes();

  @override
  html.Node visitNodeStyle(
    CssTextElement2 node,
    void arg,
  ) => //
      html.Text(
        '.${node.key} { ${const HtmlElementToUniversalVisitorImpl().visitElementDiv(DivElement2Impl.customStyle(node.css as CssStyleDeclaration2BuilderImpl), null).style.toString()} }',
      );

  @override
  html.Node visitNodeText(
    RawTextElement2 node,
    void arg,
  ) => //
      html.Text(node.text);
}
