import '../css/css.dart';
import '../html/html.dart';
import '../html/html_impl.dart';
import '../widgets/builder/builder.dart';
import '../widgets/localization/localizations.dart';
import '../widgets/theme/theme.dart';
import '../widgets/widget/impl/widget_mixin.dart';
import '../widgets/widget/interface/build_context.dart';
import '../widgets/widget/interface/widget.dart';
import 'breakpoint.dart';
import 'keys.dart';
import 'locale.dart';
import 'media_query_data.dart';

class App implements Widget {
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
    final this.supportedLocales = const <Locale>[Locale('en', 'US')],
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
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) {
    final currentRoute = routes.firstWhere((final x) => x.relativeUrl == this.currentRoute);
    return application(currentRoute).renderHtml(context);
  }

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) {
    final currentRoute = routes.firstWhere((final x) => x.relativeUrl == this.currentRoute);
    return application(currentRoute).render(context);
  }

  @override
  Null renderCss(
    final BuildContext context,
  ) =>
      null;
}

class AppWidget<ROUTE extends WidgetRoute> implements Widget {
  static const List<MediaSize> availableSizes = MediaSize.values;

  final ROUTE route;
  final List<String> stylesheetLinks;
  final List<String> scriptLinks;
  final ThemeData Function(BuildContext context)? theme;
  final Widget Function(BuildContext context, ROUTE child)? builder;
  @override
  final Key? key = null;

  AppWidget({
    required final this.route,
    final this.theme,
    final this.builder,
    final this.stylesheetLinks = const <String>[],
    final this.scriptLinks = const <String>[],
  });

  @override
  HtmlElement2 renderHtml(
    final BuildContext context,
  ) =>
      HtmlHtmlElement2Impl.make(
        [
          HeadElement2Impl.make(
            [
              // TODO have a meta subclass that already has those attributes.
              MetaElement2Impl()
                ..setAttribute('charset', 'UTF-8')
                ..setAttribute('name', 'viewport')
                ..setAttribute('content', 'width=device-width, initial-scale=1'),
              for (final link in stylesheetLinks) //
                LinkElement2Impl(href: link, rel: 'stylesheet'),
              ...route.head(context),
            ],
          ),
          StyleElement2Impl.make([
            const RawTextElement2Impl(resetCss),
            const RawTextElement2Impl(baseCss),
            for (final size in availableSizes) //
              RawTextElement2Impl(mediaClassForMediaSize(availableSizes, size)),
          ]),
          BodyElement2Impl.make(
            [
              for (final size in availableSizes)
                DivElement2Impl.make(
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
                    ).render(context)
                  ],
                ),
              for (final link in scriptLinks)
                ScriptElement2Impl()
                  ..src = link
                  ..async = true
                  ..defer = true,
            ],
          )
        ],
      );

  @override
  HtmlElement2 render(
    final BuildContext context,
  ) {
    final result = renderWidget(this, context);
    for (final x in result.childNodes) {
      if (x is StyleElement2) {
        context.styles.entries.forEach(
          (final e) => x.childNodes.add(
            CssTextElement2Impl(
              e.key,
              e.value,
            ),
          ),
        );
        break;
      }
    }
    return result;
  }

  @override
  Null renderCss(
    final BuildContext context,
  ) =>
      null;
}

abstract class WidgetRoute {
  String makeTitle(
    final BuildContext context,
  );

  Iterable<HtmlElement2> head(
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
  Iterable<HtmlElement2> head(
    final BuildContext context,
  ) =>
      [
        TitleElement2Impl()..text = makeTitle(context),
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
  Widget<Key?, HtmlElement2, CssStyleDeclaration?, HtmlElement2> build(
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
  assert(index != -1, "The given size $size was not in $all");
  return [
    '@media all and ${'(min-width: ${Breakpoint.defaultBreakpointSize(size)}px)'}${() {
      if (index + 1 >= all.length) {
        return "";
      } else {
        return " and (max-width: ${Breakpoint.defaultBreakpointSize(all[index + 1]) - 1}px)";
      }
    }()} {',
    for (final current in all) //
      '  .size${current.index} { display: ${() {
        if (size == current) {
          return "block";
        } else {
          return "none";
        }
      }()}; }',
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
