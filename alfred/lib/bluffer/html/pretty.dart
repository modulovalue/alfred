import 'html.dart';

String htmlElementToString({
  required final HtmlElement element,
}) {
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
