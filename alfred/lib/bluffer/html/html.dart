// region element visitors
String html_element_to_string({
  required final HtmlElement element,
}) {
  String html_entity_to_string({
    required final HtmlEntity element,
  }) {
    return html_element_to_string(
      element: element.match(
        element: (final e) => e.element,
        node: (final e) => HtmlElementRawImpl(
          html: e.text,
        ),
      ),
    );
  }

  if (element is HtmlElementRaw) {
    return element.html;
  } else {
    // region prep
    final tag = element_tag(element: element);
    final class_name = element_classname(element: element);
    final id = element_id(element: element);
    final other_tag_attributes = element_additional_attributes(element: element);
    // endregion
    // region parts
    final open = "<" + [
      tag,
      if (class_name != null) 'class="' + class_name + '"',
      if (id != null) 'id="' + id + '"',
      ...other_tag_attributes,
    ].join(" ") + ">";
    final close = "</" + tag + ">";
    String wrap(
      final Iterable<String> strs,
    ) {
      return open + strs.join("\n") + close;
    }
    return y_combinator<HtmlElement, String>(
      (final SELF) => (final a) => a.match(
        raw: (final a) => a.html,
        copy: (final a) => SELF(a.other),
        br: (final a) => wrap([]),
        html: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
        meta: (final a) => wrap([]),
        body: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
        custom: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
        script: (final a) => wrap([]),
        link: (final a) => wrap([]),
        title: (final a) => wrap([a.text]),
        style: (final a) => wrap(a.styles.map(
          (final e) => serialize_style_content(
            content: e,
          ),
        )),
        image: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
        div: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
        anchor: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
        head: (final a) => wrap(a.childNodes.map((final a) => html_entity_to_string(element: a))),
      ),
    )(element);
    // endregion
  }
}
B Function(A arg) y_combinator<A, B>(
  final B Function(A arg) Function(B Function(A) SELF) fn,
) {
  B result(final A a) => fn(result)(a);
  return result;
}

String? element_classname({
  required final HtmlElement element,
}) =>
    element.match(
      raw: (final a) => null,
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

String? element_id({
  required final HtmlElement element,
}) =>
    element.match(
      raw: (final a) => null,
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

String element_tag({
  required final HtmlElement element,
}) =>
    element.match(
      raw: (final a) => "div",
      custom: (final a) => a.tag,
      copy: (final a) => element_tag(
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

List<String> element_additional_attributes({
  required final HtmlElement element,
}) =>
    element.match(
      raw: (final a) => [],
      copy: (final a) => element_additional_attributes(
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
          if (_integrity != null) 'integrity="' +
              _integrity + '"',
          if (_crossorigin != null) 'crossorigin="' +
              _crossorigin + '"',
          if (_rel != null) 'rel="' + _rel + '"',
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
          for (final a in a.attributes) a.key + '="' + a.value +
              '"',
        ];
      },
      anchor: (final a) {
        final _href = a.href;
        final _target = a.target;
        return [
          if (_href != null) 'href="' + _href + '"',
          if (_target != null) 'target="' + _target + '"',
          for (final a in a.attributes) a.key + '="' + a.value +
              '"',
        ];
      },
      head: (final a) => [],
    );

String serialize_key({
  required final CssKey key,
}) =>
    key.match(
      raw: (final a) => a.key,
      composite: (final a) => a.keys.map(
        (final a) => serialize_key(key: a),
      ).join(", "),
    );

String serialize_style_content({
  required final StyleContent content,
}) =>
    content.match(
      style: (final a) => serialize_key(
        key: a.content.key,
      ) + " { " + () {
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
          if (borderTopRightRadius != null)"border-top-right-radius: " + borderTopRightRadius + ";",
          if (borderBottomLeftRadius != null)
            "border-bottom-left-radius: " +
                borderBottomLeftRadius + ";",
          if (borderBottomRightRadius != null)
            "border-bottom-right-radius: " +
                borderBottomRightRadius + ";",
          if (boxShadow != null) "box-shadow: " + boxShadow + ";",
          if (flexDirection != null) "flex-direction: " +
              flexDirection + ";",
          if (justifyContent != null) "justify-content: " +
              justifyContent + ";",
          if (alignItems != null) "align-items: " + alignItems +
              ";",
          if (flexGrow != null) "flex-grow: " + flexGrow + ";",
          if (flexShrink != null) "flex-shrink: " + flexShrink +
              ";",
          if (flexBasis != null) "flex-basis: " + flexBasis + ";",
          if (objectFit != null) "object-fit: " + objectFit + ";",
          if (width != null) "width: " + width + ";",
          if (height != null) "height: " + height + ";",
          if (textAlign != null) "text-align: " + textAlign + ";",
          if (lineHeight != null) "line-height: " + lineHeight +
              ";",
          if (fontSize != null) "font-size: " + fontSize + ";",
          if (color != null) "color: " + color + ";",
          if (fontWeight != null) "font-weight: " + fontWeight +
              ";",
          if (fontFamily != null) "font-family: " + fontFamily +
              ";",
          if (cursor != null) "cursor: " + cursor + ";",
          if (padding != null) "padding: " + padding + ";",
          if (border != null) "border: " + border + ";",
          if (font != null) "font: " + font + ";",
          if (verticalAlign != null) "vertical-align: " +
              verticalAlign + ";",
          if (listStyle != null) "list-style: " + listStyle + ";",
          if (quotes != null) "quotes: " + quotes + ";",
          if (content != null) "content: " + content + ";",
          if (borderCollapse != null) "border-collapse: " +
              borderCollapse + ";",
          if (spacing != null) "spacing: " + spacing + ";",
          if (textDecoration != null) "text-decoration: " +
              textDecoration + ";",
        ].join("");
      }() + " }",
      structure: (final a) => serialize_key(key: a.key) + " { " + <String>[
        for (final a in a.style)
          serialize_style_content(
            content: StyleContentStyleImpl(
              content: a,
            ),
          ) + "\n",
      ].join("\n") + " }",
    );
// endregion

// region html entity
abstract class HtmlEntity {
  Z match<Z>({
    required final Z Function(HtmlEntityElement) element,
    required final Z Function(HtmlEntityNode) node,
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
    required this.text,
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
    required this.element,
  });

  @override
  Z match<Z>({
    required final Z Function(HtmlEntityElement p1) element,
    required final Z Function(HtmlEntityNode p1) node,
  }) =>
      element(this);
}
// endregion

// region css style declaration
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
    this.css_margin,
    this.css_maxHeight,
    this.css_maxWidth,
    this.css_minHeight,
    this.css_minWidth,
    this.css_display,
    this.css_backgroundColor,
    this.css_backgroundImage,
    this.css_backgroundPosition,
    this.css_backgroundSize,
    this.css_borderTopLeftRadius,
    this.css_borderTopRightRadius,
    this.css_borderBottomLeftRadius,
    this.css_borderBottomRightRadius,
    this.css_boxShadow,
    this.css_flexDirection,
    this.css_justifyContent,
    this.css_alignItems,
    this.css_flexGrow,
    this.css_flexShrink,
    this.css_flexBasis,
    this.css_objectFit,
    this.css_width,
    this.css_height,
    this.css_textAlign,
    this.css_lineHeight,
    this.css_fontSize,
    this.css_color,
    this.css_fontWeight,
    this.css_fontFamily,
    this.css_cursor,
    this.css_padding,
    this.css_border,
    this.css_font,
    this.css_verticalAlign,
    this.css_listStyle,
    this.css_quotes,
    this.css_content,
    this.css_borderCollapse,
    this.css_spacing,
    this.css_textDecoration,
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
    required this.className,
    required this.id,
  });
}

class Attribute {
  final String key;
  final String value;

  const Attribute({
    required this.key,
    required this.value,
  });
}
// endregion

// region interface
abstract class HtmlElement {}

extension HtmlElementMatch on HtmlElement {
  Z match<Z>({
    required final Z Function(HtmlElementRaw) raw,
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
    final self = this;
    if (self is HtmlElementRaw) return raw(self);
    if (self is HtmlElementCopy) return copy(self);
    if (self is HtmlElementBr) return br(self);
    if (self is HtmlElementHtml) return html(self);
    if (self is HtmlElementMeta) return meta(self);
    if (self is HtmlElementBody) return body(self);
    if (self is HtmlElementCustom) return custom(self);
    if (self is HtmlElementScript) return script(self);
    if (self is HtmlElementLink) return link(self);
    if (self is HtmlElementTitle) return title(self);
    if (self is HtmlElementStyle) return style(self);
    if (self is HtmlElementImage) return image(self);
    if (self is HtmlElementDiv) return div(self);
    if (self is HtmlElementAnchor) return anchor(self);
    if (self is HtmlElementHead) return head(self);
    throw Exception("Invalid State");
  }
}

abstract class HtmlElementRaw implements HtmlElement {
  String get html;
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
// endregion

// region impl
class HtmlElementRawImpl implements HtmlElementRaw {
  @override
  final String html;

  const HtmlElementRawImpl({
    required this.html,
  });
}

class HtmlElementCopyImpl implements HtmlElementCopy {
  @override
  final IdClass? idClass;
  @override
  final HtmlElement other;

  const HtmlElementCopyImpl({
    required this.other,
    required this.idClass,
  });
}

class HtmlElementBrImpl implements HtmlElementBr {
  @override
  final IdClass? idClass;

  const HtmlElementBrImpl({
    required this.idClass,
  });
}

class HtmlElementHtmlImpl implements HtmlElementHtml {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementHtmlImpl({
    required this.childNodes,
    required this.idClass,
  });
}

class HtmlElementMetaImpl implements HtmlElementMeta {
  @override
  final IdClass? idClass;
  @override
  final List<Attribute> attributes;

  const HtmlElementMetaImpl({
    required this.attributes,
    required this.idClass,
  });
}

class HtmlElementBodyImpl implements HtmlElementBody {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementBodyImpl({
    required this.childNodes,
    required this.idClass,
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
    required this.tag,
    required this.attributes,
    required this.childNodes,
    required this.idClass,
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
    required this.async,
    required this.defer,
    required this.src,
    required this.idClass,
    required this.integrity,
    required this.crossorigin,
    required this.rel,
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
    required this.href,
    required this.rel,
    required this.idClass,
  });
}

class HtmlElementTitleImpl implements HtmlElementTitle {
  @override
  final IdClass? idClass;
  @override
  final String text;

  const HtmlElementTitleImpl({
    required this.text,
    required this.idClass,
  });
}

class HtmlElementStyleImpl implements HtmlElementStyle {
  @override
  final IdClass? idClass;
  @override
  final List<StyleContent> styles;

  const HtmlElementStyleImpl({
    required this.styles,
    required this.idClass,
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
    required this.alt,
    required this.src,
    required this.childNodes,
    required this.idClass,
  });
}

class HtmlElementDivImpl implements HtmlElementDiv {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;
  @override
  final List<Attribute> attributes;

  HtmlElementDivImpl({
    required this.childNodes,
    required this.attributes,
    required this.idClass,
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
    required this.href,
    required this.childNodes,
    required this.target,
    required this.idClass,
    required this.attributes,
  });
}

class HtmlElementHeadImpl implements HtmlElementHead {
  @override
  final IdClass? idClass;
  @override
  final List<HtmlEntity> childNodes;

  const HtmlElementHeadImpl({
    required this.childNodes,
    required this.idClass,
  });
}
// endregion

// region style
abstract class StyleContent {
  Z match<Z>({
    required final Z Function(StyleContentStyle) style,
    required final Z Function(StyleContentStructure) structure,
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
    required this.content,
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
    required this.key,
    required this.style,
  });

  @override
  Z match<Z>({
    required final Z Function(StyleContentStyle) style,
    required final Z Function(StyleContentStructure) structure,
  }) =>
      structure(this);
}
// endregion

// region html style
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
    required this.key,
    required this.css,
  });
}
// endregion

// region css key
// TODO • dsl for css keys separated by space
// TODO • dsl for css keys id, class and colon at the end.
// TODO   Class, Id, colon?
abstract class CssKey {
  Z match<Z>({
    required final Z Function(CssKeyRaw) raw,
    required final Z Function(CssKeyComposite) composite,
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
    required this.key,
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
    required this.keys,
  });

  @override
  Z match<Z>({
    required final Z Function(CssKeyRaw p1) raw,
    required final Z Function(CssKeyComposite p1) composite,
  }) =>
      composite(this);
}
// endregion