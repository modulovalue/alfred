void main() {
  final result = htmlElementToString(
    element: const HtmlElementBodyImpl(
      idClass: null,
      childNodes: [
        HtmlEntityNodeImpl(
          text: "LoremIpsum",
        ),
        HtmlEntityElementImpl(
          element: HtmlElementCopyImpl(
            idClass: IdClassImpl(
              id: "overridden id",
              className: "overridden class",
            ),
            other: HtmlElementStyleImpl(
              idClass: IdClassImpl(
                className: "class",
                id: "id",
              ),
              styles: [],
            ),
          ),
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
        HtmlEntityElementImpl(
          element: HtmlElementStyleImpl(
            idClass: IdClassImpl(
              className: "class",
              id: "id",
            ),
            styles: [
              StyleContentStyleImpl(
                content: HtmlStyleImpl(
                  key: CssKeyRawImpl(
                    key: "key",
                  ),
                  css: CssStyleDeclarationImpl(
                    css_margin: "#",
                    css_maxHeight: "#",
                    css_maxWidth: "#",
                    css_minHeight: "#",
                    css_minWidth: "#",
                    css_display: "#",
                    css_backgroundColor: "#",
                    css_backgroundImage: "#",
                    css_backgroundPosition: "#",
                    css_backgroundSize: "#",
                    css_borderTopLeftRadius: "#",
                    css_borderTopRightRadius: "#",
                    css_borderBottomLeftRadius: "#",
                    css_borderBottomRightRadius: "#",
                    css_boxShadow: "#",
                    css_flexDirection: "#",
                    css_justifyContent: "#",
                    css_alignItems: "#",
                    css_flexGrow: "#",
                    css_flexShrink: "#",
                    css_flexBasis: "#",
                    css_objectFit: "#",
                    css_width: "#",
                    css_height: "#",
                    css_textAlign: "#",
                    css_lineHeight: "#",
                    css_fontSize: "#",
                    css_color: "#",
                    css_fontWeight: "#",
                    css_fontFamily: "#",
                    css_cursor: "#",
                    css_padding: "#",
                    css_border: "#",
                    css_font: "#",
                    css_verticalAlign: "#",
                    css_listStyle: "#",
                    css_quotes: "#",
                    css_content: "#",
                    css_borderCollapse: "#",
                    css_spacing: "#",
                    css_textDecoration: "#",
                  ),
                ),
              ),
              StyleContentStructureImpl(
                key: CssKeyRawImpl(
                  key: "outer",
                ),
                style: [
                  HtmlStyleImpl(
                    key: CssKeyRawImpl(
                      key: "inner",
                    ),
                    css: CssStyleDeclarationImpl(
                      css_margin: "#",
                      css_maxHeight: "#",
                      css_maxWidth: "#",
                      css_minHeight: "#",
                      css_minWidth: "#",
                      css_display: "#",
                      css_backgroundColor: "#",
                      css_backgroundImage: "#",
                      css_backgroundPosition: "#",
                      css_backgroundSize: "#",
                      css_borderTopLeftRadius: "#",
                      css_borderTopRightRadius: "#",
                      css_borderBottomLeftRadius: "#",
                      css_borderBottomRightRadius: "#",
                      css_boxShadow: "#",
                      css_flexDirection: "#",
                      css_justifyContent: "#",
                      css_alignItems: "#",
                      css_flexGrow: "#",
                      css_flexShrink: "#",
                      css_flexBasis: "#",
                      css_objectFit: "#",
                      css_width: "#",
                      css_height: "#",
                      css_textAlign: "#",
                      css_lineHeight: "#",
                      css_fontSize: "#",
                      css_color: "#",
                      css_fontWeight: "#",
                      css_fontFamily: "#",
                      css_cursor: "#",
                      css_padding: "#",
                      css_border: "#",
                      css_font: "#",
                      css_verticalAlign: "#",
                      css_listStyle: "#",
                      css_quotes: "#",
                      css_content: "#",
                      css_borderCollapse: "#",
                      css_spacing: "#",
                      css_textDecoration: "#",
                    ),
                  )
                ],
              )
            ],
          ),
        ),
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
  print(result);
}

abstract class HtmlEntity {
  Z match<Z>({
    required Z Function(HtmlEntityElement) element,
    required Z Function(HtmlEntityNode) node,
  });
}

abstract class HtmlEntityNode implements HtmlEntity {
  String get text;
}

abstract class HtmlEntityElement implements HtmlEntity {
  HtmlElement get element;
}

class HtmlEntityNodeImpl implements HtmlEntityNode {
  @override
  final String text;

  const HtmlEntityNodeImpl({
    required final this.text,
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

  String? get css_cursor;

  String? get css_padding;

  String? get css_border;

  String? get css_font;

  String? get css_verticalAlign;

  String? get css_listStyle;

  String? get css_quotes;

  String? get css_content;

  String? get css_borderCollapse;

  String? get css_spacing;

  String? get css_textDecoration;
}

class CssStyleDeclarationImpl implements CssStyleDeclaration {
  @override
  final String? css_margin;
  @override
  final String? css_maxHeight;
  @override
  final String? css_maxWidth;
  @override
  final String? css_minHeight;
  @override
  final String? css_minWidth;
  @override
  final String? css_display;
  @override
  final String? css_backgroundColor;
  @override
  final String? css_backgroundImage;
  @override
  final String? css_backgroundPosition;
  @override
  final String? css_backgroundSize;
  @override
  final String? css_borderTopLeftRadius;
  @override
  final String? css_borderTopRightRadius;
  @override
  final String? css_borderBottomLeftRadius;
  @override
  final String? css_borderBottomRightRadius;
  @override
  final String? css_boxShadow;
  @override
  final String? css_flexDirection;
  @override
  final String? css_justifyContent;
  @override
  final String? css_alignItems;
  @override
  final String? css_flexGrow;
  @override
  final String? css_flexShrink;
  @override
  final String? css_flexBasis;
  @override
  final String? css_objectFit;
  @override
  final String? css_width;
  @override
  final String? css_height;
  @override
  final String? css_textAlign;
  @override
  final String? css_lineHeight;
  @override
  final String? css_fontSize;
  @override
  final String? css_color;
  @override
  final String? css_fontWeight;
  @override
  final String? css_fontFamily;
  @override
  final String? css_cursor;
  @override
  final String? css_padding;
  @override
  final String? css_border;
  @override
  final String? css_font;
  @override
  final String? css_verticalAlign;
  @override
  final String? css_listStyle;
  @override
  final String? css_quotes;
  @override
  final String? css_content;
  @override
  final String? css_borderCollapse;
  @override
  final String? css_spacing;
  @override
  final String? css_textDecoration;

  const CssStyleDeclarationImpl({
    final this.css_margin,
    final this.css_maxHeight,
    final this.css_maxWidth,
    final this.css_minHeight,
    final this.css_minWidth,
    final this.css_display,
    final this.css_backgroundColor,
    final this.css_backgroundImage,
    final this.css_backgroundPosition,
    final this.css_backgroundSize,
    final this.css_borderTopLeftRadius,
    final this.css_borderTopRightRadius,
    final this.css_borderBottomLeftRadius,
    final this.css_borderBottomRightRadius,
    final this.css_boxShadow,
    final this.css_flexDirection,
    final this.css_justifyContent,
    final this.css_alignItems,
    final this.css_flexGrow,
    final this.css_flexShrink,
    final this.css_flexBasis,
    final this.css_objectFit,
    final this.css_width,
    final this.css_height,
    final this.css_textAlign,
    final this.css_lineHeight,
    final this.css_fontSize,
    final this.css_color,
    final this.css_fontWeight,
    final this.css_fontFamily,
    final this.css_cursor,
    final this.css_padding,
    final this.css_border,
    final this.css_font,
    final this.css_verticalAlign,
    final this.css_listStyle,
    final this.css_quotes,
    final this.css_content,
    final this.css_borderCollapse,
    final this.css_spacing,
    final this.css_textDecoration,
  });
}

abstract class IdClass {
  String? get className;

  String? get id;
}

class IdClassImpl implements IdClass {
  @override
  final String? className;
  @override
  final String? id;

  const IdClassImpl({
    required final this.className,
    required final this.id,
  });
}

class Attribute {
  final String key;
  final String value;

  const Attribute({
    required final this.key,
    required final this.value,
  });
}

abstract class HtmlElement {}

extension HtmlElementMatch on HtmlElement {
  Z match<Z>({
    required final Z Function(HtmlElementCopy) copy,
    required final Z Function(HtmlElementBr) br,
    required final Z Function(HtmlElementHtml) html,
    required final Z Function(HtmlElementMeta) meta,
    required final Z Function(HtmlElementBody) body,
    required final Z Function(HtmlElementCustom) custom,
    required final Z Function(HtmlElementScript) script,
    required final Z Function(HtmlElementLink) link,
    required final Z Function(HtmlElementTitle) title,
    required final Z Function(HtmlElementStyle) style,
    required final Z Function(HtmlElementImage) image,
    required final Z Function(HtmlElementDiv) div,
    required final Z Function(HtmlElementAnchor) anchor,
    required final Z Function(HtmlElementHead) head,
  }) {
    final _ = this;
    if (_ is HtmlElementCopy) {
      return copy(_);
    } else if (_ is HtmlElementBr) {
      return br(_);
    } else if (_ is HtmlElementHtml) {
      return html(_);
    } else if (_ is HtmlElementMeta) {
      return meta(_);
    } else if (_ is HtmlElementBody) {
      return body(_);
    } else if (_ is HtmlElementCustom) {
      return custom(_);
    } else if (_ is HtmlElementScript) {
      return script(_);
    } else if (_ is HtmlElementLink) {
      return link(_);
    } else if (_ is HtmlElementTitle) {
      return title(_);
    } else if (_ is HtmlElementStyle) {
      return style(_);
    } else if (_ is HtmlElementImage) {
      return image(_);
    } else if (_ is HtmlElementDiv) {
      return div(_);
    } else if (_ is HtmlElementAnchor) {
      return anchor(_);
    } else if (_ is HtmlElementHead) {
      return head(_);
    } else {
      throw Exception("Invalid State");
    }
  }
}

abstract class HtmlElementCopy implements HtmlElement {
  IdClass? get idClass;

  HtmlElement get other;
}

abstract class HtmlElementBr implements HtmlElement {
  IdClass? get idClass;
}

abstract class HtmlElementHtml implements HtmlElement {
  IdClass? get idClass;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementMeta implements HtmlElement {
  IdClass? get idClass;

  List<Attribute> get attributes;
}

abstract class HtmlElementBody implements HtmlElement {
  IdClass? get idClass;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementCustom implements HtmlElement {
  IdClass? get idClass;

  String get tag;

  List<Attribute> get attributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementScript implements HtmlElement {
  IdClass? get idClass;

  bool? get async;

  bool? get defer;

  String? get src;

  String? get integrity;

  String? get crossorigin;

  String? get rel;
}

abstract class HtmlElementLink implements HtmlElement {
  IdClass? get idClass;

  String? get href;

  String? get rel;
}

abstract class HtmlElementTitle implements HtmlElement {
  IdClass? get idClass;

  String get text;
}

abstract class HtmlElementStyle implements HtmlElement {
  IdClass? get idClass;

  List<StyleContent> get styles;
}

abstract class HtmlElementImage implements HtmlElement {
  IdClass? get idClass;

  String? get alt;

  String? get src;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementDiv implements HtmlElement {
  IdClass? get idClass;

  List<Attribute> get attributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementAnchor implements HtmlElement {
  IdClass? get idClass;

  String? get href;

  String? get target;

  List<Attribute> get attributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementHead implements HtmlElement {
  IdClass? get idClass;

  List<HtmlEntity> get childNodes;
}

class HtmlElementCopyImpl implements HtmlElementCopy {
  @override
  final HtmlElement other;
  @override
  final IdClass? idClass;

  const HtmlElementCopyImpl({
    required final this.other,
    required final this.idClass,
  });
}

class HtmlElementBrImpl implements HtmlElementBr {
  @override
  final IdClass? idClass;

  const HtmlElementBrImpl({
    required final this.idClass,
  });
}

class HtmlElementHtmlImpl implements HtmlElementHtml {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementHtmlImpl({
    required final this.childNodes,
    required final this.idClass,
  });
}

class HtmlElementMetaImpl implements HtmlElementMeta {
  @override
  final IdClass? idClass;
  @override
  final List<Attribute> attributes;

  const HtmlElementMetaImpl({
    required final this.attributes,
    required final this.idClass,
  });
}

class HtmlElementBodyImpl implements HtmlElementBody {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementBodyImpl({
    required final this.childNodes,
    required final this.idClass,
  });
}

class HtmlElementCustomImpl implements HtmlElementCustom {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String tag;
  @override
  final List<Attribute> attributes;

  const HtmlElementCustomImpl({
    required final this.tag,
    required final this.attributes,
    required final this.childNodes,
    required final this.idClass,
  });
}

class HtmlElementScriptImpl implements HtmlElementScript {
  @override
  final IdClass? idClass;
  @override
  final bool? async;
  @override
  final bool? defer;
  @override
  final String? src;
  @override
  final String? integrity;
  @override
  final String? crossorigin;
  @override
  final String? rel;

  const HtmlElementScriptImpl({
    required final this.async,
    required final this.defer,
    required final this.src,
    required final this.idClass,
    required final this.integrity,
    required final this.crossorigin,
    required final this.rel,
  });
}

class HtmlElementLinkImpl implements HtmlElementLink {
  @override
  final IdClass? idClass;
  @override
  final String? href;
  @override
  final String? rel;

  const HtmlElementLinkImpl({
    required final this.href,
    required final this.rel,
    required final this.idClass,
  });
}

class HtmlElementTitleImpl implements HtmlElementTitle {
  @override
  final IdClass? idClass;
  @override
  final String text;

  const HtmlElementTitleImpl({
    required final this.text,
    required final this.idClass,
  });
}

class HtmlElementStyleImpl implements HtmlElementStyle {
  @override
  final IdClass? idClass;
  @override
  final List<StyleContent> styles;

  const HtmlElementStyleImpl({
    required final this.styles,
    required final this.idClass,
  });
}

class HtmlElementImageImpl implements HtmlElementImage {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? alt;
  @override
  final String? src;

  const HtmlElementImageImpl({
    required final this.alt,
    required final this.src,
    required final this.childNodes,
    required final this.idClass,
  });
}

class HtmlElementDivImpl implements HtmlElementDiv {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final List<Attribute> attributes;

  const HtmlElementDivImpl({
    required final this.childNodes,
    required final this.attributes,
    required final this.idClass,
  });
}

class HtmlElementAnchorImpl implements HtmlElementAnchor {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? href;
  @override
  final String? target;
  @override
  final List<Attribute> attributes;

  const HtmlElementAnchorImpl({
    required final this.href,
    required final this.childNodes,
    required final this.target,
    required final this.idClass,
    required final this.attributes,
  });
}

class HtmlElementHeadImpl implements HtmlElementHead {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementHeadImpl({
    required final this.childNodes,
    required final this.idClass,
  });
}

abstract class StyleContent {
  Z match<Z>({
    required Z Function(StyleContentStyle) style,
    required Z Function(StyleContentStructure) structure,
  });
}

abstract class StyleContentStyle implements StyleContent {
  HtmlStyle get content;
}

abstract class StyleContentStructure implements StyleContent {
  CssKey get key;

  List<HtmlStyle> get style;
}

class StyleContentStyleImpl implements StyleContentStyle {
  @override
  final HtmlStyle content;

  const StyleContentStyleImpl({
    required final this.content,
  });

  @override
  Z match<Z>({
    required final Z Function(StyleContentStyle) style,
    required final Z Function(StyleContentStructure) structure,
  }) =>
      style(this);
}

class StyleContentStructureImpl implements StyleContentStructure {
  @override
  final CssKey key;
  @override
  final List<HtmlStyle> style;

  const StyleContentStructureImpl({
    required final this.key,
    required final this.style,
  });

  @override
  Z match<Z>({
    required final Z Function(StyleContentStyle) style,
    required final Z Function(StyleContentStructure) structure,
  }) =>
      structure(this);
}

abstract class HtmlStyle {
  CssKey get key;

  CssStyleDeclaration get css;
}

class HtmlStyleImpl implements HtmlStyle {
  @override
  final CssKey key;
  @override
  final CssStyleDeclaration css;

  const HtmlStyleImpl({
    required final this.key,
    required final this.css,
  });
}

// TODO dsl for css keys separated by space
// TODO dsl for css keys id, class and colon at the end.
// TODO, Class, Id, colon?
abstract class CssKey {
  Z match<Z>({
    required Z Function(CssKeyRaw) raw,
    required Z Function(CssKeyComposite) composite,
  });
}

abstract class CssKeyRaw implements CssKey {
  String get key;
}

abstract class CssKeyComposite implements CssKey {
  List<CssKey> get keys;
}

class CssKeyRawImpl implements CssKeyRaw {
  @override
  final String key;

  const CssKeyRawImpl({
    required final this.key,
  });

  @override
  Z match<Z>({
    required final Z Function(CssKeyRaw p1) raw,
    required final Z Function(CssKeyComposite p1) composite,
  }) =>
      raw(this);
}

class CssKeyCompositeImpl implements CssKeyComposite {
  @override
  final List<CssKey> keys;

  const CssKeyCompositeImpl({
    required final this.keys,
  });

  @override
  Z match<Z>({
    required final Z Function(CssKeyRaw p1) raw,
    required final Z Function(CssKeyComposite p1) composite,
  }) =>
      composite(this);
}

String htmlElementToString({
  required final HtmlElement element,
}) {
  String? elementId({
    required final HtmlElement element,
  }) =>
      element.match(
        copy: (final a) => a.idClass?.id,
        br: (final a) => a.idClass?.id,
        html: (final a) => a.idClass?.id,
        meta: (final a) => a.idClass?.id,
        body: (final a) => a.idClass?.id,
        custom: (final a) => a.idClass?.id,
        script: (final a) => a.idClass?.id,
        link: (final a) => a.idClass?.id,
        title: (final a) => a.idClass?.id,
        style: (final a) => a.idClass?.id,
        image: (final a) => a.idClass?.id,
        div: (final a) => a.idClass?.id,
        anchor: (final a) => a.idClass?.id,
        head: (final a) => a.idClass?.id,
      );

  final tag = () {
    String _elementTag({
      required final HtmlElement element,
    }) =>
        element.match(
          custom: (final a) => a.tag,
          copy: (final a) => _elementTag(
            element: a.other,
          ),
          br: (final a) => "br",
          html: (final a) => "html",
          meta: (final a) => "meta",
          body: (final a) => "body",
          script: (final a) => "script",
          link: (final a) => "link",
          title: (final a) => "title",
          style: (final a) => "style",
          image: (final a) => "img",
          div: (final a) => "div",
          anchor: (final a) => "a",
          head: (final a) => "head",
        );
    return _elementTag(
      element: element,
    );
  }();
  return "<" +
          () {
        final className = elementClassname(
          element: element,
        );
        final id = elementId(
          element: element,
        );
        return [
          tag,
          if (className != null) //
            'class="' + className + '"',
          if (id != null) //
            'id="' + id + '"',
          ...() {
            List<String> _elementAdditionalAttributes({
              required final HtmlElement element,
            }) =>
                element.match(
                  copy: (final a) => _elementAdditionalAttributes(
                    element: a.other,
                  ),
                  br: (final a) => [],
                  html: (final a) => [],
                  meta: (final a) => [
                    for (final a in a.attributes) a.key + '="' + a.value + '"',
                  ],
                  body: (final a) => [],
                  custom: (final a) => [
                    for (final a in a.attributes) a.key + '="' + a.value + '"',
                  ],
                  script: (final a) {
                    final _src = a.src;
                    final _async = a.async;
                    final _defer = a.defer;
                    final _integrity = a.integrity;
                    final _crossorigin = a.crossorigin;
                    final _rel = a.rel;
                    return [
                      if (_src != null) 'src="' + _src + '"',
                      if (_async != null) 'async="' + _async.toString() + '"',
                      if (_defer != null) 'defer="' + _defer.toString() + '"',
                      if (_integrity != null) 'integrity="' + _integrity.toString() + '"',
                      if (_crossorigin != null) 'crossorigin="' + _crossorigin.toString() + '"',
                      if (_rel != null) 'rel="' + _rel.toString() + '"',
                    ];
                  },
                  link: (final a) {
                    final _href = a.href;
                    final _rel = a.rel;
                    return [
                      if (_href != null) 'href="' + _href + '"',
                      if (_rel != null) 'rel="' + _rel + '"',
                    ];
                  },
                  title: (final a) => [],
                  style: (final a) => [],
                  image: (final a) {
                    final _src = a.src;
                    final _alt = a.alt;
                    return [
                      if (_src != null) 'src="' + _src + '"',
                      if (_alt != null) 'alt="' + _alt + '"',
                    ];
                  },
                  div: (final a) {
                    return [
                      for (final a in a.attributes) a.key + '="' + a.value + '"',
                    ];
                  },
                  anchor: (final a) {
                    final _href = a.href;
                    final _target = a.target;
                    return [
                      if (_href != null) 'href="' + _href + '"',
                      if (_target != null) 'target="' + _target + '"',
                      for (final a in a.attributes) a.key + '="' + a.value + '"',
                    ];
                  },
                  head: (final a) => [],
                );
            return _elementAdditionalAttributes(
              element: element,
            );
          }(),
        ].join(" ");
      }() +
      ">" +
          () {
        final elements = <HtmlEntityElement>[];
        final attributes = <HtmlEntityNode>[];
        final styles = <StyleContent>[];

        final children = elementChildNodes(
          element: element,
        );
        for (final child in children) {
          child.match(
            node: attributes.add,
            element: elements.add,
          );
        }
        element.match(
          copy: (final a) {},
          br: (final a) {},
          html: (final a) {},
          meta: (final a) {},
          body: (final a) {},
          custom: (final a) {},
          script: (final a) {},
          link: (final a) {},
          title: (final a) {},
          style: (final a) => styles.addAll(a.styles),
          image: (final a) {},
          div: (final a) {},
          anchor: (final a) {},
          head: (final a) {},
        );

        String serializeKey({
          required final CssKey key,
        }) =>
            key.match(
              raw: (final a) => a.key,
              composite: (final a) => a.keys.map((final a) => serializeKey(key: a)).join(", "),
            );
        String _styleContent({
          required final StyleContent content,
        }) =>
            content.match(
              style: (final a) =>
              serializeKey(
                key: a.content.key,
              ) +
                  " { " +
                      () {
                    final css = a.content.css;
                    final margin = css.css_margin;
                    final maxHeight = css.css_maxHeight;
                    final maxWidth = css.css_maxWidth;
                    final display = css.css_display;
                    final backgroundColor = css.css_backgroundColor;
                    final backgroundImage = css.css_backgroundImage;
                    final backgroundPosition = css.css_backgroundPosition;
                    final backgroundSize = css.css_backgroundSize;
                    final borderTopLeftRadius = css.css_borderTopLeftRadius;
                    final borderTopRightRadius = css.css_borderTopRightRadius;
                    final borderBottomLeftRadius = css.css_borderBottomLeftRadius;
                    final borderBottomRightRadius = css.css_borderBottomRightRadius;
                    final boxShadow = css.css_boxShadow;
                    final flexDirection = css.css_flexDirection;
                    final justifyContent = css.css_justifyContent;
                    final alignItems = css.css_alignItems;
                    final flexGrow = css.css_flexGrow;
                    final flexShrink = css.css_flexShrink;
                    final flexBasis = css.css_flexBasis;
                    final objectFit = css.css_objectFit;
                    final width = css.css_width;
                    final height = css.css_height;
                    final textAlign = css.css_textAlign;
                    final lineHeight = css.css_lineHeight;
                    final fontSize = css.css_fontSize;
                    final color = css.css_color;
                    final fontWeight = css.css_fontWeight;
                    final fontFamily = css.css_fontFamily;
                    final cursor = css.css_cursor;
                    final padding = css.css_padding;
                    final border = css.css_border;
                    final font = css.css_font;
                    final verticalAlign = css.css_verticalAlign;
                    final listStyle = css.css_listStyle;
                    final quotes = css.css_quotes;
                    final content = css.css_content;
                    final borderCollapse = css.css_borderCollapse;
                    final spacing = css.css_spacing;
                    final textDecoration = css.css_textDecoration;
                    return [
                      if (margin != null) "margin: " + margin + ";",
                      if (maxHeight != null) "max-height: " + maxHeight + ";",
                      if (maxWidth != null) "max-width: " + maxWidth + ";",
                      if (display != null) "display: " + display + ";",
                      if (backgroundColor != null) "background-color: " + backgroundColor + ";",
                      if (backgroundImage != null) "background-image: " + backgroundImage + ";",
                      if (backgroundPosition != null) "background-position: " + backgroundPosition + ";",
                      if (backgroundSize != null) "background-size: " + backgroundSize + ";",
                      if (borderTopLeftRadius != null) "border-top-left-radius: " + borderTopLeftRadius + ";",
                      if (borderTopRightRadius != null)
                        "border-top-right-radius: " + borderTopRightRadius + ";",
                      if (borderBottomLeftRadius != null)
                        "border-bottom-left-radius: " + borderBottomLeftRadius + ";",
                      if (borderBottomRightRadius != null)
                        "border-bottom-right-radius: " + borderBottomRightRadius + ";",
                      if (boxShadow != null) "box-shadow: " + boxShadow + ";",
                      if (flexDirection != null) "flex-direction: " + flexDirection + ";",
                      if (justifyContent != null) "justify-content: " + justifyContent + ";",
                      if (alignItems != null) "align-items: " + alignItems + ";",
                      if (flexGrow != null) "flex-grow: " + flexGrow + ";",
                      if (flexShrink != null) "flex-shrink: " + flexShrink + ";",
                      if (flexBasis != null) "flex-basis: " + flexBasis + ";",
                      if (objectFit != null) "object-fit: " + objectFit + ";",
                      if (width != null) "width: " + width + ";",
                      if (height != null) "height: " + height + ";",
                      if (textAlign != null) "text-align: " + textAlign + ";",
                      if (lineHeight != null) "line-height: " + lineHeight + ";",
                      if (fontSize != null) "font-size: " + fontSize + ";",
                      if (color != null) "color: " + color + ";",
                      if (fontWeight != null) "font-weight: " + fontWeight + ";",
                      if (fontFamily != null) "font-family: " + fontFamily + ";",
                      if (cursor != null) "cursor: " + cursor + ";",
                      if (padding != null) "padding: " + padding + ";",
                      if (border != null) "border: " + border + ";",
                      if (font != null) "font: " + font + ";",
                      if (verticalAlign != null) "vertical-align: " + verticalAlign + ";",
                      if (listStyle != null) "list-style: " + listStyle + ";",
                      if (quotes != null) "quotes: " + quotes + ";",
                      if (content != null) "content: " + content + ";",
                      if (borderCollapse != null) "border-collapse: " + borderCollapse + ";",
                      if (spacing != null) "spacing: " + spacing + ";",
                      if (textDecoration != null) "text-decoration: " + textDecoration + ";",
                    ].join("");
                  }() +
                  " }\n",
              structure: (final a) =>
              serializeKey(
                key: a.key,
              ) +
                  " { " +
                  <String>[
                    for (final a in a.style)
                      _styleContent(
                        content: StyleContentStyleImpl(
                          content: a,
                        ),
                      )
                  ].join("\n") +
                  " }\n",
            );

        return [
          for (final style in styles)
            _styleContent(
              content: style,
            ),
          for (final a in attributes) a.text,
          <String>[
            for (final a in elements)
              htmlElementToString(
                element: a.element,
              ),
          ].join("\n"),
        ].join();
      }() +
      "</" +
      tag +
      ">";
}

List<HtmlEntity> elementChildNodes({
  required final HtmlElement element,
}) =>
    element.match(
      copy: (final a) => elementChildNodes(
        element: a.other,
      ),
      br: (final a) => [],
      html: (final a) => a.childNodes,
      meta: (final a) => [],
      body: (final a) => a.childNodes,
      custom: (final a) => a.childNodes,
      script: (final a) => [],
      link: (final a) => [],
      title: (final a) => [
        HtmlEntityNodeImpl(
          text: a.text,
        ),
      ],
      style: (final a) => [],
      image: (final a) => a.childNodes,
      div: (final a) => a.childNodes,
      anchor: (final a) => a.childNodes,
      head: (final a) => a.childNodes,
    );

String? elementClassname({
  required final HtmlElement element,
}) =>
    element.match(
      copy: (final a) => a.idClass?.className,
      br: (final a) => a.idClass?.className,
      html: (final a) => a.idClass?.className,
      meta: (final a) => a.idClass?.className,
      body: (final a) => a.idClass?.className,
      custom: (final a) => a.idClass?.className,
      script: (final a) => a.idClass?.className,
      link: (final a) => a.idClass?.className,
      title: (final a) => a.idClass?.className,
      style: (final a) => a.idClass?.className,
      image: (final a) => a.idClass?.className,
      div: (final a) => a.idClass?.className,
      anchor: (final a) => a.idClass?.className,
      head: (final a) => a.idClass?.className,
    );
