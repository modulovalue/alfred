// ignore: implementation_imports
import 'package:universal_html/src/html.dart' as html;

import '../../../html/html.dart';
import '../../../html/html_impl.dart';

String elementToStringViaUniversal(
  final HtmlElement2 entity,
) =>
    entity
        .acceptHtmlElementOneArg(
          const HtmlElementToUniversalVisitorImpl(),
          null,
        )
        .outerHtml!;

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
    if (a.css_margin != null) {
      b.margin = a.css_margin;
    }
    if (a.css_maxHeight != null) {
      b.maxHeight = a.css_maxHeight;
    }
    if (a.css_maxWidth != null) {
      b.maxWidth = a.css_maxWidth;
    }
    if (a.css_minHeight != null) {
      b.minHeight = a.css_minHeight;
    }
    if (a.css_minWidth != null) {
      b.minWidth = a.css_minWidth;
    }
    if (a.css_display != null) {
      b.display = a.css_display;
    }
    if (a.css_backgroundColor != null) {
      b.backgroundColor = a.css_backgroundColor;
    }
    if (a.css_backgroundImage != null) {
      b.backgroundImage = a.css_backgroundImage;
    }
    if (a.css_backgroundPosition != null) {
      b.backgroundPosition = a.css_backgroundPosition;
    }
    if (a.css_backgroundSize != null) {
      b.backgroundSize = a.css_backgroundSize;
    }
    if (a.css_borderTopLeftRadius != null) {
      b.borderTopLeftRadius = a.css_borderTopLeftRadius;
    }
    if (a.css_borderTopRightRadius != null) {
      b.borderTopRightRadius = a.css_borderTopRightRadius;
    }
    if (a.css_borderBottomLeftRadius != null) {
      b.borderBottomLeftRadius = a.css_borderBottomLeftRadius;
    }
    if (a.css_borderBottomRightRadius != null) {
      b.borderBottomRightRadius = a.css_borderBottomRightRadius;
    }
    if (a.css_boxShadow != null) {
      b.boxShadow = a.css_boxShadow;
    }
    if (a.css_flexDirection != null) {
      b.flexDirection = a.css_flexDirection;
    }
    if (a.css_justifyContent != null) {
      b.justifyContent = a.css_justifyContent;
    }
    if (a.css_alignItems != null) {
      b.alignItems = a.css_alignItems;
    }
    if (a.css_flexGrow != null) {
      b.flexGrow = a.css_flexGrow;
    }
    if (a.css_flexShrink != null) {
      b.flexShrink = a.css_flexShrink;
    }
    if (a.css_flexBasis != null) {
      b.flexBasis = a.css_flexBasis;
    }
    if (a.css_height != null) {
      b.height = a.css_height;
    }
    if (a.css_textAlign != null) {
      b.textAlign = a.css_textAlign;
    }
    if (a.css_lineHeight != null) {
      b.lineHeight = a.css_lineHeight;
    }
    if (a.css_fontSize != null) {
      b.fontSize = a.css_fontSize;
    }
    if (a.css_color != null) {
      b.color = a.css_color;
    }
    if (a.css_fontWeight != null) {
      b.fontWeight = a.css_fontWeight;
    }
    if (a.css_fontFamily != null) {
      b.fontFamily = a.css_fontFamily;
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
  html.HtmlElement visitElementAnchor(
    final AnchorElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.AnchorElement()
          ..href = node.href
          ..target = node.target,
      );

  @override
  html.HtmlElement visitElementBody(
    final BodyElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.BodyElement(),
      );

  @override
  html.HtmlElement visitElementBr(
    final BRElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.BRElement(),
      );

  @override
  html.HtmlElement visitElementDiv(
    final DivElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.DivElement(),
      );

  @override
  html.HtmlElement visitElementHead(
    final HeadElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.HeadElement(),
      );

  @override
  html.HtmlElement visitElementHtmlHtml(
    final HtmlHtmlElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.HtmlHtmlElement(),
      );

  @override
  html.HtmlElement visitElementImage(
    final ImageElement2 node,
    final void arg,
  ) =>
      passOnHtmlElementValues(
        node,
        html.ImageElement()
          ..src = node.src
          ..alt = node.alt,
      );

  @override
  html.HtmlElement visitElementLink(
    final LinkElement2 node,
    final void arg,
  ) {
    final element = html.LinkElement();
    if (node.rel != null) element.rel = node.rel!;
    element.href = node.href;
    return passOnHtmlElementValues(node, element);
  }

  @override
  html.HtmlElement visitElementMeta(
    final MetaElement2 node,
    final void arg,
  ) {
    final element = html.MetaElement();
    node.forEachAttribute(element.setAttribute);
    return passOnHtmlElementValues(node, element);
  }

  @override
  html.HtmlElement visitElementParagraph(
    final ParagraphElement2 node,
    final void arg,
  ) => //
      passOnHtmlElementValues(
        node,
        html.ParagraphElement(),
      );

  @override
  html.HtmlElement visitElementScript(
    final ScriptElement2 node,
    final void arg,
  ) {
    final element = html.ScriptElement();
    if (node.src != null) {
      element.src = node.src!;
    }
    if (node.defer != null) {
      element.defer = node.defer;
    }
    if (node.async != null) {
      element.async = node.async!;
    }
    return passOnHtmlElementValues(
      node,
      element,
    );
  }

  @override
  html.HtmlElement visitElementStyle(
    final StyleElement2 node,
    final void arg,
  ) => //
      passOnHtmlElementValues(
        node,
        html.StyleElement(),
      );

  @override
  html.HtmlElement visitElementTitle(
    final TitleElement2 node,
    final void arg,
  ) {
    final element = html.TitleElement();
    element.text = node.text;
    return passOnHtmlElementValues(node, element);
  }
}

class _Nodes implements HtmlNodeVisitorOneArg<html.Node, void> {
  const _Nodes();

  @override
  html.Node visitNodeStyle(
    final CssTextElement2 node,
    final void arg,
  ) {
    final key = node.key;
    final content = const HtmlElementToUniversalVisitorImpl().visitElementDiv(DivElement2Impl.custom(node.css), null).style.toString();
    final text = '.${key} { $content }';
    return html.Text(text);
  }

  @override
  html.Node visitNodeText(
    final RawTextElement2 node,
    final void arg,
  ) =>
      html.Text(node.text);
}
