import '../html/html.dart';
import '../html/pretty.dart';
import '../widget/widget.dart';
import '../widget/widget_mixin.dart';
import '../widgets/builder.dart';
import '../widgets/localizations.dart';
import '../widgets/stateless.dart';
import '../widgets/theme.dart';
import 'breakpoint.dart';
import 'keys.dart';
import 'locale.dart';
import 'media_query_data.dart';

class App with NoCSSMixin implements Widget {
  final String? currentRoute;
  final List<UrlWidgetRoute> routes;
  final AppWidget Function(WidgetRoute) application;
  @override
  final Key? key = null;
  final List<Locale> supportedLocales;

  /// This list collectively defines the localized resources
  /// objects that can be retrieved with [Localizations.of].
  final List<LocalizationsDelegate<dynamic>> delegates;

  App({
    required final this.routes,
    required final this.application,
    final this.currentRoute,
    final this.supportedLocales = const <Locale>[
      Locale('en', 'US'),
    ],
    final this.delegates = const <LocalizationsDelegate<dynamic>>[],
  });

  App withCurrentRoute(
    final String currentRoute,
  ) =>
      App(
        currentRoute: currentRoute,
        routes: routes,
        application: application,
      );

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) {
    // TODO firstWhere is bad because it will throw if nothing is found use firstWhereOrNull or do it manually.
    final currentRoute = routes.firstWhere(
      (final x) => x.relativeUrl == this.currentRoute,
    );
    final appWidget = application(currentRoute);
    return appWidget.renderHtml(
      context: context,
    );
  }

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) {
    final currentRoute = routes.firstWhere(
      (final x) => x.relativeUrl == this.currentRoute,
    );
    final appWidget = application(currentRoute);
    return appWidget.renderElement(
      context: context,
    );
  }
}

class AppWidget<ROUTE extends WidgetRoute> with NoCSSMixin implements Widget {
  final ROUTE route;
  final AppIncludes includes;
  final ThemeData Function(BuildContext context)? theme;
  final Widget Function(BuildContext context, ROUTE child)? builder;
  @override
  final Key? key = null;

  // TODO combine this delegate and include into an "AppSetup" model.
  // TODO have a "(reset|default style) delegate".
  final bool enableCssReset;

  AppWidget({
    required final this.route,
    final this.theme,
    final this.enableCssReset = true,
    final this.builder,
    final this.includes = const AppIncludesEmptyImpl(),
  });

  @override
  HtmlElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlElementHtmlImpl(
        idClass: null,
        childNodes: [
          HtmlEntityElementImpl(
            element: HtmlElementHeadImpl(
              idClass: null,
              childNodes: [
                // TODO have a meta subclass that already has those attributes.
                // TODO look for and support more attributes
                // TODO have an all-attribute-type-safe meta implementation.
                const HtmlEntityElementImpl(
                  element: HtmlElementMetaImpl(
                    idClass: null,
                    attributes: [
                      Attribute(
                        key: 'charset',
                        value: 'UTF-8',
                      ),
                      Attribute(
                        key: 'name',
                        value: 'viewport',
                      ),
                      Attribute(
                        key: 'content',
                        value: 'width=device-width, initial-scale=1',
                      ),
                    ],
                  ),
                ),
                for (final link in includes.stylesheetLinks) //
                  HtmlEntityElementImpl(
                    element: HtmlElementLinkImpl(
                      idClass: null,
                      href: link,
                      rel: 'stylesheet',
                    ),
                  ),
                ...route.head(context),
              ],
            ),
          ),
          // ignore: prefer_const_constructors
          HtmlEntityElementImpl(
            // ignore: prefer_const_constructors
            element: HtmlElementStyleImpl(
              idClass: null,
              styles: [
                // TODO have a reset delegate.
                if (enableCssReset) ...[
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyCompositeImpl(
                        keys: [
                          CssKeyRawImpl(key: "html"),
                          CssKeyRawImpl(key: "body"),
                          CssKeyRawImpl(key: "div"),
                          CssKeyRawImpl(key: "span"),
                          CssKeyRawImpl(key: "applet"),
                          CssKeyRawImpl(key: "object"),
                          CssKeyRawImpl(key: "iframe"),
                          CssKeyRawImpl(key: "h1"),
                          CssKeyRawImpl(key: "h2"),
                          CssKeyRawImpl(key: "h3"),
                          CssKeyRawImpl(key: "h4"),
                          CssKeyRawImpl(key: "h5"),
                          CssKeyRawImpl(key: "h6"),
                          CssKeyRawImpl(key: "p"),
                          CssKeyRawImpl(key: "blockquote"),
                          CssKeyRawImpl(key: "pre"),
                          CssKeyRawImpl(key: "a"),
                          CssKeyRawImpl(key: "abbr"),
                          CssKeyRawImpl(key: "acronym"),
                          CssKeyRawImpl(key: "address"),
                          CssKeyRawImpl(key: "big"),
                          CssKeyRawImpl(key: "cite"),
                          CssKeyRawImpl(key: "code"),
                          CssKeyRawImpl(key: "del"),
                          CssKeyRawImpl(key: "dfn"),
                          CssKeyRawImpl(key: "em"),
                          CssKeyRawImpl(key: "img"),
                          CssKeyRawImpl(key: "ns"),
                          CssKeyRawImpl(key: "kbd"),
                          CssKeyRawImpl(key: "q"),
                          CssKeyRawImpl(key: "s"),
                          CssKeyRawImpl(key: "samp"),
                          CssKeyRawImpl(key: "small"),
                          CssKeyRawImpl(key: "strike"),
                          CssKeyRawImpl(key: "storng"),
                          CssKeyRawImpl(key: "sub"),
                          CssKeyRawImpl(key: "sup"),
                          CssKeyRawImpl(key: "tt"),
                          CssKeyRawImpl(key: "var"),
                          CssKeyRawImpl(key: "b"),
                          CssKeyRawImpl(key: "u"),
                          CssKeyRawImpl(key: "i"),
                          CssKeyRawImpl(key: "center"),
                          CssKeyRawImpl(key: "dl"),
                          CssKeyRawImpl(key: "dt"),
                          CssKeyRawImpl(key: "dd"),
                          CssKeyRawImpl(key: "ol"),
                          CssKeyRawImpl(key: "ul"),
                          CssKeyRawImpl(key: "li"),
                          CssKeyRawImpl(key: "fieldset"),
                          CssKeyRawImpl(key: "form"),
                          CssKeyRawImpl(key: "label"),
                          CssKeyRawImpl(key: "legend"),
                          CssKeyRawImpl(key: "tale"),
                          CssKeyRawImpl(key: "caption"),
                          CssKeyRawImpl(key: "tbody"),
                          CssKeyRawImpl(key: "tfoot"),
                          CssKeyRawImpl(key: "thead"),
                          CssKeyRawImpl(key: "tr"),
                          CssKeyRawImpl(key: "th"),
                          CssKeyRawImpl(key: "td"),
                          CssKeyRawImpl(key: "article"),
                          CssKeyRawImpl(key: "aside"),
                          CssKeyRawImpl(key: "canvas"),
                          CssKeyRawImpl(key: "details"),
                          CssKeyRawImpl(key: "embed"),
                          CssKeyRawImpl(key: "figure"),
                          CssKeyRawImpl(key: "figcaption"),
                          CssKeyRawImpl(key: "footer"),
                          CssKeyRawImpl(key: "header"),
                          CssKeyRawImpl(key: "hgroup"),
                          CssKeyRawImpl(key: "menu"),
                          CssKeyRawImpl(key: "nav"),
                          CssKeyRawImpl(key: "output"),
                          CssKeyRawImpl(key: "ruby"),
                          CssKeyRawImpl(key: "section"),
                          CssKeyRawImpl(key: "summary"),
                          CssKeyRawImpl(key: "time"),
                          CssKeyRawImpl(key: "mark"),
                          CssKeyRawImpl(key: "audio"),
                          CssKeyRawImpl(key: "video"),
                        ],
                      ),
                      css: CssStyleDeclarationImpl(
                        css_margin: "0",
                        css_padding: "0",
                        css_border: "0",
                        css_fontSize: "100%",
                        css_font: "inherit",
                        css_verticalAlign: "baseline",
                      ),
                    ),
                  ),
                  // HTML5 display-role reset for older browsers
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyCompositeImpl(
                        keys: [
                          CssKeyRawImpl(key: "article"),
                          CssKeyRawImpl(key: "aside"),
                          CssKeyRawImpl(key: "details"),
                          CssKeyRawImpl(key: "figcaption"),
                          CssKeyRawImpl(key: "figure"),
                          CssKeyRawImpl(key: "footer"),
                          CssKeyRawImpl(key: "header"),
                          CssKeyRawImpl(key: "hgroup"),
                          CssKeyRawImpl(key: "menu"),
                          CssKeyRawImpl(key: "nav"),
                          CssKeyRawImpl(key: "section"),
                        ],
                      ),
                      css: CssStyleDeclarationImpl(css_display: "block"),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: "body",
                      ),
                      css: CssStyleDeclarationImpl(css_lineHeight: "1"),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyCompositeImpl(
                        keys: [
                          CssKeyRawImpl(key: "ol"),
                          CssKeyRawImpl(key: "ul"),
                        ],
                      ),
                      css: CssStyleDeclarationImpl(
                        css_listStyle: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyCompositeImpl(
                        keys: [
                          CssKeyRawImpl(key: "blockquote"),
                          CssKeyRawImpl(key: "q"),
                        ],
                      ),
                      css: CssStyleDeclarationImpl(
                        css_quotes: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyCompositeImpl(
                        keys: [
                          CssKeyRawImpl(key: "blockquote:before"),
                          CssKeyRawImpl(key: "blockquote:after"),
                          CssKeyRawImpl(key: "q:before"),
                          CssKeyRawImpl(key: "q:after"),
                        ],
                      ),
                      css: CssStyleDeclarationImpl(
                        css_content: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: "table",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_borderCollapse: "collapse",
                        css_spacing: "0",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: "a",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_textDecoration: "none",
                      ),
                    ),
                  ),
                ],
                if (enableCssReset) ...[
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "flex",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click .active",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click .inactive",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "flex",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click .hover",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click:active .active",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "flex",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click:active .inactive",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click:active .hover",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click:hover .active",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click:hover .inactive",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "none",
                      ),
                    ),
                  ),
                  const StyleContentStyleImpl(
                    content: HtmlStyleImpl(
                      key: CssKeyRawImpl(
                        key: ".click:hover .hover",
                      ),
                      css: CssStyleDeclarationImpl(
                        css_display: "flex",
                        css_cursor: "pointer",
                      ),
                    ),
                  ),
                ],
                for (final size in MediaSize.values) ...[
                  StyleContentStructureImpl(
                    key: CssKeyRawImpl(
                      key: '@media all and (min-width: ' +
                          Breakpoint.defaultBreakpointSize(
                            size: size,
                          ).toString() +
                          'px)' +
                          () {
                            final index = MediaSize.values.indexOf(size);
                            if (index + 1 >= MediaSize.values.length) {
                              return "";
                            } else {
                              return " and (max-width: " +
                                  (Breakpoint.defaultBreakpointSize(
                                            size: MediaSize.values[index + 1],
                                          ) -
                                          1)
                                      .toString() +
                                  "px)";
                            }
                          }(),
                    ),
                    style: [
                      for (final current in MediaSize.values)
                        HtmlStyleImpl(
                          key: CssKeyRawImpl(
                            key: '.size' + current.index.toString(),
                          ),
                          css: CssStyleDeclarationImpl(
                            css_display: () {
                              if (size == current) {
                                return "block";
                              } else {
                                return "none";
                              }
                            }(),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          HtmlEntityElementImpl(
            element: HtmlElementBodyImpl(
              idClass: null,
              childNodes: [
                for (final size in MediaSize.values)
                  HtmlEntityElementImpl(
                    element: HtmlElementDivImpl(
                      attributes: [],
                      idClass: IdClassImpl(
                        id: null,
                        className: 'size' + size.index.toString(),
                      ),
                      childNodes: [
                        HtmlEntityElementImpl(
                          element: MediaQuery(
                            data: MediaQueryDataImpl(
                              size: size,
                            ),
                            child: Builder(
                              builder: (final context) => Theme(
                                data: theme?.call(context),
                                child: () {
                                  if (builder != null) {
                                    return builder!(context, route);
                                  } else {
                                    return route.build(context);
                                  }
                                }(),
                              ),
                            ),
                          ).renderElement(context: context),
                        ),
                      ],
                    ),
                  ),
                ...includes.scriptLinks.map(
                  (final a) => HtmlEntityElementImpl(
                    element: a,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  @override
  HtmlElement renderElement({
    required final BuildContext context,
  }) {
    final result = renderWidget(
      context: context,
      child: this,
    );
    final children = elementChildNodes(
      element: result,
    );
    for (final child in children) {
      final stop = child.match(
        element: (final a) => a.element.match(
          copy: (final a) => false,
          br: (final a) => false,
          html: (final a) => false,
          meta: (final a) => false,
          body: (final a) => false,
          custom: (final a) => false,
          script: (final a) => false,
          link: (final a) => false,
          title: (final a) => false,
          style: (final a) {
            context.styles.entries.forEach(
              // TODO bad, don't 'add'
              (final e) => a.styles.add(
                StyleContentStyleImpl(
                  content: HtmlStyleImpl(
                    key: CssKeyRawImpl(
                      key: "." + e.key,
                    ),
                    css: e.value,
                  ),
                ),
              ),
            );
            return true;
          },
          image: (final a) => false,
          div: (final a) => false,
          anchor: (final a) => false,
          head: (final a) => false,
        ),
        node: (final a) => false,
      );
      if (stop) {
        break;
      } else {
        // Continue.
      }
    }
    return result;
  }
}

class AppIncludesEmptyImpl implements AppIncludes {
  const AppIncludesEmptyImpl();

  @override
  Iterable<String> get stylesheetLinks => const Iterable.empty();

  @override
  Iterable<HtmlElementScriptImpl> get scriptLinks => const Iterable.empty();
}

class AppIncludesImpl implements AppIncludes {
  @override
  final List<String> stylesheetLinks;
  @override
  final List<HtmlElementScriptImpl> scriptLinks;

  const AppIncludesImpl({
    required final this.stylesheetLinks,
    required final this.scriptLinks,
  });
}

abstract class AppIncludes {
  // TODO make this not be a string but a stylesheet model.
  Iterable<String> get stylesheetLinks;

  Iterable<HtmlElementScriptImpl> get scriptLinks;
}

class AppIncludesCompositeImpl implements AppIncludes {
  final Iterable<AppIncludes> includes;

  const AppIncludesCompositeImpl({
    required final this.includes,
  });

  @override
  Iterable<String> get stylesheetLinks sync* {
    for (final include in includes) {
      yield* include.stylesheetLinks;
    }
  }

  @override
  Iterable<HtmlElementScriptImpl> get scriptLinks sync* {
    for (final include in includes) {
      yield* include.scriptLinks;
    }
  }
}

abstract class WidgetRoute {
  String makeTitle(
    final BuildContext context,
  );

  Iterable<HtmlEntityElement> head(
    final BuildContext context,
  );

  Widget build(
    final BuildContext context,
  );
}

class WidgetRouteImpl with WidgetRouteMixin {
  final String Function(BuildContext context) title;
  final Widget Function(BuildContext context) builder;

  const WidgetRouteImpl({
    required final this.title,
    required final this.builder,
  });

  @override
  Widget build(
    final BuildContext context,
  ) =>
      builder(context);

  @override
  String makeTitle(
    final BuildContext context,
  ) =>
      title(context);
}

class WidgetRouteSimpleImpl with WidgetRouteMixin {
  final String title;
  final Widget child;

  const WidgetRouteSimpleImpl({
    required final this.title,
    required final this.child,
  });

  @override
  String makeTitle(
    final BuildContext context,
  ) =>
      title;

  @override
  Widget build(
    final BuildContext context,
  ) =>
      child;
}

mixin WidgetRouteMixin implements WidgetRoute {
  @override
  Iterable<HtmlEntityElement> head(
    final BuildContext context,
  ) =>
      [
        HtmlEntityElementImpl(
          element: HtmlElementTitleImpl(
            idClass: null,
            text: makeTitle(context),
          ),
        ),
      ];
}

class UrlWidgetRoute with WidgetRouteMixin {
  final String relativeUrl;
  final String Function(BuildContext context) title;
  final Widget Function(BuildContext context) builder;

  const UrlWidgetRoute({
    required final this.relativeUrl,
    required final this.title,
    required final this.builder,
  });

  @override
  Widget build(
    final BuildContext context,
  ) =>
      builder(context);

  @override
  String makeTitle(
    final BuildContext context,
  ) =>
      title(context);
}
