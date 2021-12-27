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
