import '../html/html.dart';
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
  HtmlEntityElement renderHtml({
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
  HtmlEntityElement renderElement({
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
  HtmlEntityElement renderHtml({
    required final BuildContext context,
  }) =>
      HtmlEntityElementImpl(
        element: HtmlElementHtmlImpl(
          id: null,
          className: null,
          childNodes: [
            HtmlEntityElementImpl(
              element: HtmlElementHeadImpl(
                className: null,
                id: null,
                childNodes: [
                  // TODO have a meta subclass that already has those attributes.
                  // TODO look for and support more attributes
                  // TODO have an all-attribute-type-safe meta implementation.
                  const HtmlEntityElementImpl(
                    element: HtmlElementMetaImpl(
                      id: null,
                      className: null,
                      childNodes: [],
                      attributes: {
                        'charset': 'UTF-8',
                        'name': 'viewport',
                        'content': 'width=device-width, initial-scale=1',
                      },
                    ),
                  ),
                  for (final link in includes.stylesheetLinks) //
                    HtmlEntityElementImpl(
                      element: HtmlElementLinkImpl(
                        className: null,
                        id: null,
                        childNodes: [],
                        href: link,
                        rel: 'stylesheet',
                      ),
                    ),
                  ...route.head(context),
                ],
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementStyleImpl(
                className: null,
                id: null,
                childNodes: [
                  // TODO have a reset delegate.
                  if (enableCssReset)
                    const HtmlEntityNodeImpl(
                      node: HtmlNodeTextImpl(
                        resetCss,
                      ),
                    ),
                  if (enableCssReset)
                    const HtmlEntityNodeImpl(
                      node: HtmlNodeTextImpl(
                        baseCss,
                      ),
                    ),
                  for (final size in MediaSize.values)
                    HtmlEntityNodeImpl(
                      node: HtmlNodeTextImpl(
                        mediaClassForMediaSize(
                          MediaSize.values,
                          size,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            HtmlEntityElementImpl(
              element: HtmlElementBodyImpl(
                id: null,
                className: null,
                childNodes: [
                  for (final size in MediaSize.values)
                    HtmlEntityElementImpl(
                      element: HtmlElementDivImpl(
                        otherAdditionalAttributes: [],
                        id: null,
                        className: 'size' + size.index.toString(),
                        childNodes: [
                          MediaQuery(
                            data: MediaQueryDataImpl(size: size),
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
                          ).renderElement(context: context)
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
        ),
      );

  @override
  HtmlEntityElement renderElement({
    required final BuildContext context,
  }) {
    final result = renderWidget(
      context: context,
      child: this,
    );
    for (final HtmlEntity child in result.element.childNodes) {
      if (child is HtmlEntityElement) {
        final _child = child.element;
        if (_child is HtmlElementStyleImpl) {
          context.styles.entries.forEach(
            (final e) => _child.childNodes.add(
              HtmlEntityNodeImpl(
                node: HtmlNodeStyleImpl(
                  e.key,
                  e.value,
                ),
              ),
            ),
          );
          break;
        }
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
            className: null,
            id: null,
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

String mediaClassForMediaSize(
  final List<MediaSize> all,
  final MediaSize size,
) {
  final index = all.indexOf(size);
  assert(
    index != -1,
    "The given size " + size.toString() + " was not in " + all.toString(),
  );
  return [
    '@media all and (min-width: ' +
        Breakpoint.defaultBreakpointSize(size).toString() +
        'px)' +
        () {
          if (index + 1 >= all.length) {
            return "";
          } else {
            return " and (max-width: " + (Breakpoint.defaultBreakpointSize(all[index + 1]) - 1).toString() + "px)";
          }
        }() +
        ' {',
    for (final current in all)
      '  .size' +
          current.index.toString() +
          ' { display: ' +
          () {
            if (size == current) {
              return "block";
            } else {
              return "none";
            }
          }() +
          '; }',
    '} \n',
  ].join("\n");
}

const baseCss = '''
.click {
  display: flex;
}

.click .active {
  display: none;
}
.click .inactive {
  display: flex;
}
.click .hover {
  display: none;
}

.click:active .active {
  display: flex;
}
.click:active .inactive {
  display: none;
}
.click:active .hover {
  display: none;
}

.click:hover .active {
  display: none;
}
.click:hover .inactive {
  display: none;
}
.click:hover .hover {
  display: flex;
  cursor: pointer;
}
''';

const resetCss = '''
html, body, div, span, applet, object, iframe,
h1, h2, h3, h4, h5, h6, p, blockquote, pre,
a, abbr, acronym, address, big, cite, code,
del, dfn, em, img, ins, kbd, q, s, samp,
small, strike, strong, sub, sup, tt, var,
b, u, i, center,
dl, dt, dd, ol, ul, li,
fieldset, form, label, legend,
table, caption, tbody, tfoot, thead, tr, th, td,
article, aside, canvas, details, embed, 
figure, figcaption, footer, header, hgroup, 
menu, nav, output, ruby, section, summary,
time, mark, audio, video {
	margin: 0;
	padding: 0;
	border: 0;
	font-size: 100%;
	font: inherit;
	vertical-align: baseline;
}
/* HTML5 display-role reset for older browsers */
article, aside, details, figcaption, figure, 
footer, header, hgroup, menu, nav, section {
	display: block;
}
body {
	line-height: 1;
}
ol, ul {
	list-style: none;
}
blockquote, q {
	quotes: none;
}
blockquote:before, blockquote:after,
q:before, q:after {
	content: '';
	content: none;
}
table {
	border-collapse: collapse;
	border-spacing: 0;
}
a {
  text-decoration: none;
}
''';
