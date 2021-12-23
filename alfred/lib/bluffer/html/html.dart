abstract class HtmlEntity {
  Z match<Z>({
    required Z Function(HtmlEntityElement) element,
    required Z Function(HtmlEntityNode) node,
  });
}

abstract class HtmlEntityNode implements HtmlEntity {
  HtmlNode get node;
}

abstract class HtmlEntityElement implements HtmlEntity {
  HtmlElement get element;
}

class HtmlEntityNodeImpl implements HtmlEntityNode {
  @override
  final HtmlNode node;

  const HtmlEntityNodeImpl({
    required final this.node,
  });

  @override
  Z match<Z>({
    required final Z Function(HtmlEntityElement p1) element,
    required final Z Function(HtmlEntityNode p1) node,
  }) =>
      node(this);
}

class HtmlEntityElementImpl implements HtmlEntityElement {
  @override
  final HtmlElement element;

  const HtmlEntityElementImpl({
    required final this.element,
  });

  @override
  Z match<Z>({
    required final Z Function(HtmlEntityElement p1) element,
    required final Z Function(HtmlEntityNode p1) node,
  }) =>
      element(this);
}

abstract class HtmlNode {
  Z match<Z>({
    required final Z Function(HtmlNodeText) text,
    required final Z Function(HtmlNodeStyle) style,
  });
}

abstract class HtmlNodeText implements HtmlNode {
  String get text;
}

abstract class HtmlNodeStyle implements HtmlNode {
  String get key;

  CssStyleDeclaration get css;
}

class HtmlNodeTextImpl implements HtmlNodeText {
  @override
  final String text;

  const HtmlNodeTextImpl(
    final this.text,
  );

  @override
  Z match<Z>({
    required final Z Function(HtmlNodeText p1) text,
    required final Z Function(HtmlNodeStyle p1) style,
  }) =>
      text(this);
}

class HtmlNodeStyleImpl implements HtmlNodeStyle {
  @override
  final String key;
  @override
  final CssStyleDeclaration css;

  const HtmlNodeStyleImpl(
    final this.key,
    final this.css,
  );

  @override
  Z match<Z>({
    required final Z Function(HtmlNodeText p1) text,
    required final Z Function(HtmlNodeStyle p1) style,
  }) =>
      style(this);
}

abstract class CssStyleDeclaration {
  String? get css_margin;

  String? get css_maxHeight;

  String? get css_maxWidth;

  String? get css_minHeight;

  String? get css_minWidth;

  String? get css_display;

  String? get css_backgroundColor;

  String? get css_backgroundImage;

  String? get css_backgroundPosition;

  String? get css_backgroundSize;

  String? get css_borderTopLeftRadius;

  String? get css_borderTopRightRadius;

  String? get css_borderBottomLeftRadius;

  String? get css_borderBottomRightRadius;

  String? get css_boxShadow;

  String? get css_flexDirection;

  String? get css_justifyContent;

  String? get css_alignItems;

  String? get css_flexGrow;

  String? get css_flexShrink;

  String? get css_flexBasis;

  String? get css_objectFit;

  String? get css_width;

  String? get css_height;

  String? get css_textAlign;

  String? get css_lineHeight;

  String? get css_fontSize;

  String? get css_color;

  String? get css_fontWeight;

  String? get css_fontFamily;
}

abstract class HtmlElement {
  String? get className;

  String? get id;

  CssStyleDeclaration? get style;

  List<HtmlEntity> get childNodes;

  String get tag;

  List<String> get additionalAttributes;
}

// TODO abstract classes with matchers and impls.
class HtmlElementCopyImpl implements HtmlElement {
  final HtmlElement other;
  @override
  final String? className;
  @override
  final String? id;

  const HtmlElementCopyImpl({
    required final this.other,
    required final this.className,
    required final this.id,
  });

  @override
  CssStyleDeclaration? get style => other.style;

  @override
  List<HtmlEntity> get childNodes => other.childNodes;

  @override
  String get tag => other.tag;

  @override
  List<String> get additionalAttributes => other.additionalAttributes;
}

class HtmlElementAppendedImpl implements HtmlElement {
  final HtmlElement other;
  final List<HtmlEntityElement> additional;

  const HtmlElementAppendedImpl({
    required final this.other,
    required final this.additional,
  });

  @override
  List<String> get additionalAttributes => other.additionalAttributes;

  @override
  List<HtmlEntity> get childNodes => [
        ...other.childNodes,
        ...additional,
      ];

  @override
  String? get className => other.className;

  @override
  String? get id => other.id;

  @override
  CssStyleDeclaration? get style => other.style;

  @override
  String get tag => other.tag;
}

class HtmlElementBRImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementBRImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => const [];

  @override
  String get tag => "br";
}

class HtmlElementHtmlImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementHtmlImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => const [];

  @override
  String get tag => "html";
}

class HtmlElementMetaImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final Map<String, String> attributes;

  const HtmlElementMetaImpl({
    required final this.childNodes,
    required final this.attributes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes {
    final _attributes = <String>[];
    attributes.forEach(
      (final key, final value) => _attributes.add(
        key + '="' + value + '"',
      ),
    );
    return _attributes;
  }

  @override
  String get tag => "meta";
}

class HtmlElementBodyImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementBodyImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => const [];

  @override
  String get tag => "body";
}

class HtmlElementCustomImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String tag;
  @override
  final List<String> additionalAttributes;

  const HtmlElementCustomImpl({
    required final this.tag,
    required final this.additionalAttributes,
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;
}

class HtmlElementScriptImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final bool? async;
  final bool? defer;
  final String? src;
  final String? content;

  // TODO support integrity
  // TODO support crossorigin
  // TODO support rel

  const HtmlElementScriptImpl({
    required final this.childNodes,
    required final this.async,
    required final this.defer,
    required final this.src,
    required final this.content,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes {
    final _src = src;
    final _async = async;
    final _defer = defer;
    return [
      if (_src != null) 'src="' + _src + '"',
      if (_async != null) 'async="' + _async.toString() + '"',
      if (_defer != null) 'defer="' + _defer.toString() + '"',
    ];
  }

  @override
  String get tag => "script";
}

class HtmlElementLinkImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final String? href;
  final String? rel;

  const HtmlElementLinkImpl({
    required final this.href,
    required final this.rel,
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes {
    final _href = href;
    final _rel = rel;
    return [
      if (_href != null) 'href="' + _href + '"',
      if (_rel != null) 'rel="' + _rel + '"',
    ];
  }

  @override
  String get tag => "link";
}

class HtmlElementTitleImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  final String? text;

  const HtmlElementTitleImpl({
    required final this.text,
    required final this.className,
    required final this.id,
  });

  @override
  List<HtmlEntity> get childNodes => [
        HtmlEntityNodeImpl(
          node: HtmlNodeTextImpl(
            text ?? "",
          ),
        ),
      ];

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => const [];

  @override
  String get tag => "title";
}

class HtmlElementStyleImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementStyleImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => [];

  @override
  String get tag => "style";
}

class HtmlElementImageImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final String? alt;
  final String? src;

  const HtmlElementImageImpl({
    required final this.alt,
    required final this.src,
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes {
    final _src = src;
    final _alt = alt;
    return [
      if (_src != null) 'src="' + _src + '"',
      if (_alt != null) 'alt="' + _alt + '"',
    ];
  }

  @override
  String get tag => "img";
}

class HtmlElementDivImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final List<MapEntry<String, String>> otherAdditionalAttributes;

  const HtmlElementDivImpl({
    required final this.childNodes,
    required final this.otherAdditionalAttributes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => [
        for (final a in otherAdditionalAttributes) a.key + '="' + a.value + '"',
      ];

  @override
  String get tag => "div";
}

class HtmlElementAnchorImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  final String? href;
  final String? target;
  final List<MapEntry<String, String>> otherAdditionalAttributes;

  const HtmlElementAnchorImpl({
    required final this.href,
    required final this.childNodes,
    required final this.target,
    required final this.className,
    required final this.id,
    required final this.otherAdditionalAttributes,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes {
    final _href = href;
    final _target = target;
    return [
      if (_href != null) 'href="' + _href + '"',
      if (_target != null) 'target="' + _target + '"',
      for (final a in otherAdditionalAttributes) a.key + '="' + a.value + '"',
    ];
  }

  @override
  String get tag => "a";
}

class HtmlElementHeadImpl implements HtmlElement {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementHeadImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });

  @override
  Null get style => null;

  @override
  List<String> get additionalAttributes => const [];

  @override
  String get tag => "head";
}

String htmlElementToString({
  required final HtmlElement element,
}) =>
    _htmlElementToString(
      tag: element.tag,
      additionalAttrib: element.additionalAttributes,
      element: element,
    );

String _htmlNodeToString({
  required final HtmlNode node,
}) =>
    node.match(
      text: (final node) => node.text,
      style: (final node) => "." + node.key + " { " + _serializeCss(css: node.css) + " }",
    );

String _htmlElementToString({
  required final HtmlElement element,
  required final String tag,
  required final List<String> additionalAttrib,
}) =>
    "<" +
    () {
      final cssContent = () {
        final css = element.style;
        if (css != null) {
          return _serializeCss(css: css);
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
    }() +
    ">" +
    () {
      final elements = <HtmlEntityElement>[];
      final attributes = <HtmlEntityNode>[];
      for (final child in element.childNodes) {
        child.match(
          node: (final a) => attributes.add(a),
          element: (final a) => elements.add(a),
        );
      }
      final _attributes = attributes
          .map(
            (final a) => _htmlNodeToString(
              node: a.node,
            ),
          )
          .join(" ");
      final _elements = elements
          .map(
            (final a) => htmlElementToString(
              element: a.element,
            ),
          )
          .join("\n");
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
    }() +
    "</" +
    tag +
    ">";

/// Converts the given [CssStyleDeclaration] into a css string.
String _serializeCss({
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
