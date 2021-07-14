// ignore: implementation_imports
import 'package:universal_html/src/html.dart' as html;

import '../../../html/impl/html.dart';
import '../../../html/interface/html.dart';

String elementToStringViaUniversal(
  final HtmlElement2 entity,
) => //
    entity.acceptHtmlElementOneArg(const HtmlElementToUniversalVisitorImpl(), null).outerHtml!;

class _Selector implements HtmlEntityVisitorOneArg<html.Node, void> {
  const _Selector();

  @override
  html.Node visitEntityElement(
    final HtmlElement2 node,
    final void arg,
  ) => //
      node.acceptHtmlElementOneArg(const HtmlElementToUniversalVisitorImpl(), null);

  @override
  html.Node visitEntityNode(
    final HtmlNode node,
    final void arg,
  ) => //
      node.acceptHtmlNodeOneArg(const _Nodes(), null);
}

class HtmlElementToUniversalVisitorImpl implements HtmlElementVisitorOneArg<html.HtmlElement, void> {
  static R passOnHtmlElementValues<R extends html.HtmlElement>(
    final HtmlElement2 element,
    final R other,
  ) {
    final a = element.style;
    final b = other.style;
    if (a.margin != null) {
      b.margin = a.margin;
    }
    if (a.maxHeight != null) {
      b.maxHeight = a.maxHeight;
    }
    if (a.maxWidth != null) {
      b.maxWidth = a.maxWidth;
    }
    if (a.minHeight != null) {
      b.minHeight = a.minHeight;
    }
    if (a.minWidth != null) {
      b.minWidth = a.minWidth;
    }
    if (a.display != null) {
      b.display = a.display;
    }
    if (a.backgroundColor != null) {
      b.backgroundColor = a.backgroundColor;
    }
    if (a.backgroundImage != null) {
      b.backgroundImage = a.backgroundImage;
    }
    if (a.backgroundPosition != null) {
      b.backgroundPosition = a.backgroundPosition;
    }
    if (a.backgroundSize != null) {
      b.backgroundSize = a.backgroundSize;
    }
    if (a.borderTopLeftRadius != null) {
      b.borderTopLeftRadius = a.borderTopLeftRadius;
    }
    if (a.borderTopRightRadius != null) {
      b.borderTopRightRadius = a.borderTopRightRadius;
    }
    if (a.borderBottomLeftRadius != null) {
      b.borderBottomLeftRadius = a.borderBottomLeftRadius;
    }
    if (a.borderBottomRightRadius != null) {
      b.borderBottomRightRadius = a.borderBottomRightRadius;
    }
    if (a.boxShadow != null) {
      b.boxShadow = a.boxShadow;
    }
    if (a.flexDirection != null) {
      b.flexDirection = a.flexDirection;
    }
    if (a.justifyContent != null) {
      b.justifyContent = a.justifyContent;
    }
    if (a.alignItems != null) {
      b.alignItems = a.alignItems;
    }
    if (a.flexGrow != null) {
      b.flexGrow = a.flexGrow;
    }
    if (a.flexShrink != null) {
      b.flexShrink = a.flexShrink;
    }
    if (a.flexBasis != null) {
      b.flexBasis = a.flexBasis;
    }
    if (a.height != null) {
      b.height = a.height;
    }
    if (a.textAlign != null) {
      b.textAlign = a.textAlign;
    }
    if (a.lineHeight != null) {
      b.lineHeight = a.lineHeight;
    }
    if (a.fontSize != null) {
      b.fontSize = a.fontSize;
    }
    if (a.color != null) {
      b.color = a.color;
    }
    if (a.fontWeight != null) {
      b.fontWeight = a.fontWeight;
    }
    if (a.fontFamily != null) {
      b.fontFamily = a.fontFamily;
    }
    if (element.id != null) {
      other.id = element.id!;
    }
    if (element.className != null) {
      other.className = element.className;
    }
    final otherChildNodes = other.childNodes;
    final additionalNodes = [
      for (final child in element.childNodes) //
        child.acceptHtmlEntityOneArg(const _Selector(), null),
    ];
    otherChildNodes.addAll(additionalNodes);
    return other;
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
  ) {
    final key = node.key;
    final content = const HtmlElementToUniversalVisitorImpl().visitElementDiv(DivElement2Impl.custom(node.css), null).style.toString();
    final text = '.${key} { $content }';
    return html.Text(text);
  }

  @override
  html.Node visitNodeText(
    RawTextElement2 node,
    void arg,
  ) => //
      html.Text(node.text);
}
