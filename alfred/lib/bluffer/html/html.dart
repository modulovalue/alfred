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

abstract class HtmlElement {}

extension HtmlElementMatch on HtmlElement {
  Z match<Z>({
    required final Z Function(HtmlElementCopy) copy,
    required final Z Function(HtmlElementAppended) appended,
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
    } else if (_ is HtmlElementAppended) {
      return appended(_);
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
  String? get id;

  String? get className;

  HtmlElement get other;
}

abstract class HtmlElementAppended implements HtmlElement {
  HtmlElement get other;

  List<HtmlEntityElement> get additional;
}

abstract class HtmlElementBr implements HtmlElement {
  String? get className;

  String? get id;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementHtml implements HtmlElement {
  String? get className;

  String? get id;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementMeta implements HtmlElement {
  String? get className;

  String? get id;

  List<MapEntry<String, String>> get attributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementBody implements HtmlElement {
  String? get className;

  String? get id;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementCustom implements HtmlElement {
  String? get className;

  String? get id;

  String get tag;

  List<MapEntry<String, String>> get additionalAttributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementScript implements HtmlElement {
  String? get className;

  String? get id;

  bool? get async;

  bool? get defer;

  String? get src;

  String? get integrity;

  String? get crossorigin;

  String? get rel;
}

abstract class HtmlElementLink implements HtmlElement {
  String? get className;

  String? get id;

  String? get href;

  String? get rel;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementTitle implements HtmlElement {
  String? get className;

  String? get id;

  String get text;
}

abstract class HtmlElementStyle implements HtmlElement {
  String? get className;

  String? get id;

  List<StyleContent> get childNodes;
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

// TODO dsl for css keys
// TODO List of CssKey, Class, Id, colon?
abstract class CssKey {
  String get key;
}

class CssKeyImpl implements CssKey {
  @override
  final String key;

  const CssKeyImpl({
    required final this.key,
  });
}

abstract class HtmlElementImage implements HtmlElement {
  String? get className;

  String? get id;

  String? get alt;

  String? get src;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementDiv implements HtmlElement {
  String? get className;

  String? get id;

  List<MapEntry<String, String>> get otherAdditionalAttributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementAnchor implements HtmlElement {
  String? get className;

  String? get id;

  String? get href;

  String? get target;

  List<MapEntry<String, String>> get otherAdditionalAttributes;

  List<HtmlEntity> get childNodes;
}

abstract class HtmlElementHead implements HtmlElement {
  String? get className;

  String? get id;

  List<HtmlEntity> get childNodes;
}

class HtmlElementCopyImpl implements HtmlElementCopy {
  @override
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
}

class HtmlElementAppendedImpl implements HtmlElementAppended {
  @override
  final HtmlElement other;
  @override
  final List<HtmlEntityElement> additional;

  const HtmlElementAppendedImpl({
    required final this.other,
    required final this.additional,
  });
}

class HtmlElementBrImpl implements HtmlElementBr {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementBrImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementHtmlImpl implements HtmlElementHtml {
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
}

class HtmlElementMetaImpl implements HtmlElementMeta {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final List<MapEntry<String, String>> attributes;

  const HtmlElementMetaImpl({
    required final this.childNodes,
    required final this.attributes,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementBodyImpl implements HtmlElementBody {
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
}

class HtmlElementCustomImpl implements HtmlElementCustom {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String tag;
  @override
  final List<MapEntry<String, String>> additionalAttributes;

  const HtmlElementCustomImpl({
    required final this.tag,
    required final this.additionalAttributes,
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementScriptImpl implements HtmlElementScript {
  @override
  final String? className;
  @override
  final String? id;
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
    required final this.className,
    required final this.id,
    required final this.integrity,
    required final this.crossorigin,
    required final this.rel,
  });
}

class HtmlElementLinkImpl implements HtmlElementLink {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? href;
  @override
  final String? rel;

  const HtmlElementLinkImpl({
    required final this.href,
    required final this.rel,
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementTitleImpl implements HtmlElementTitle {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final String text;

  const HtmlElementTitleImpl({
    required final this.text,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementStyleImpl implements HtmlElementStyle {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<StyleContent> childNodes;

  const HtmlElementStyleImpl({
    required final this.childNodes,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementImageImpl implements HtmlElementImage {
  @override
  final String? className;
  @override
  final String? id;
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
    required final this.className,
    required final this.id,
  });
}

class HtmlElementDivImpl implements HtmlElementDiv {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final List<MapEntry<String, String>> otherAdditionalAttributes;

  const HtmlElementDivImpl({
    required final this.childNodes,
    required final this.otherAdditionalAttributes,
    required final this.className,
    required final this.id,
  });
}

class HtmlElementAnchorImpl implements HtmlElementAnchor {
  @override
  final String? className;
  @override
  final String? id;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final String? href;
  @override
  final String? target;
  @override
  final List<MapEntry<String, String>> otherAdditionalAttributes;

  const HtmlElementAnchorImpl({
    required final this.href,
    required final this.childNodes,
    required final this.target,
    required final this.className,
    required final this.id,
    required final this.otherAdditionalAttributes,
  });
}

class HtmlElementHeadImpl implements HtmlElementHead {
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
}
