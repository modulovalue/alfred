import '../css/interface/css.dart';
import '../html/impl/html.dart';
import '../html/interface/html.dart';
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

class Application implements Widget {
  final String? currentRoute;
  final List<UrlWidgetRoute> routes;
  final ApplicationWidget Function(WidgetRoute) application;
  @override
  final Key? key = null;
  final List<Locale> supportedLocales;

  /// This list collectively defines the localized resources objects that can
  /// be retrieved with [Localizations.of].
  final List<LocalizationsDelegate<dynamic>> delegates;

  Application({
    required this.routes,
    required this.application,
    this.currentRoute,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.delegates = const <LocalizationsDelegate<dynamic>>[],
  });

  Application withCurrentRoute(
    String currentRoute,
  ) =>
      Application(
        currentRoute: currentRoute,
        routes: routes,
        application: application,
      );

  @override
  HtmlElement2 renderHtml(BuildContext context) {
    final currentRoute = routes.firstWhere((x) => x.relativeUrl == this.currentRoute);
    return application(currentRoute).renderHtml(context);
  }

  @override
  HtmlElement2 render(BuildContext context) {
    final currentRoute = routes.firstWhere((x) => x.relativeUrl == this.currentRoute);
    return application(currentRoute).render(context);
  }

  @override
  Null renderCss(BuildContext context) => null;
}

class ApplicationWidget<ROUTE extends WidgetRoute> implements Widget {
  static const List<MediaSize> availableSizes = MediaSize.values;

  final ROUTE route;
  final List<String> stylesheetLinks;
  final List<String> scriptLinks;
  final ThemeData Function(BuildContext context)? theme;
  final Widget Function(BuildContext context, ROUTE child)? builder;
  @override
  final Key? key = null;

  ApplicationWidget({
    required this.route,
    this.theme,
    this.builder,
    this.stylesheetLinks = const <String>[],
    this.scriptLinks = const <String>[],
  });


  @override
  HtmlElement2 renderHtml(BuildContext context) {
    return HtmlHtmlElement2Impl.make([
      HeadElement2Impl.make(
        [
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
      BodyElement2Impl.make([
        for (final size in availableSizes)
          DivElement2Impl.make(
            className: 'size' + size.index.toString(),
            nodes: [
              MediaQuery(
                data: MediaQueryDataImpl(size: size),
                child: Builder(
                  builder: (context) => Theme(
                    data: theme?.call(context),
                    child: builder != null ? builder!(context, route) : route.build(context),
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
      ])
    ]);
  }

  @override
  HtmlElement2 render(BuildContext context) {
    final result = renderWidget(this, context);
    for (final x in result.childNodes) {
      if (x is StyleElement2) {
        context.styles.entries.forEach(
          (e) => x.childNodes.add(
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
  CssStyleDeclaration2? renderCss(BuildContext context) {
    return null;
  }
}

abstract class WidgetRoute {
  String makeTitle(BuildContext context);

  Widget build(BuildContext context);

  Iterable<HtmlElement2> head(BuildContext context);
}

class WidgetRouteImpl with WidgetRouteMixin {
  @override
  final String Function(BuildContext context) title;
  @override
  final Widget Function(BuildContext context) builder;

  const WidgetRouteImpl({
    required this.title,
    required this.builder,
  });
}

mixin WidgetRouteMixin implements WidgetRoute {
  String Function(BuildContext context) get title;

  Widget Function(BuildContext context) get builder;

  @override
  Iterable<HtmlElement2> head(BuildContext context) => //
      [TitleElement2Impl()..text = title(context)];

  @override
  Widget build(BuildContext context) => //
      builder(context);

  @override
  String makeTitle(BuildContext context) => //
      title(context);
}

class UrlWidgetRoute with WidgetRouteMixin {
  final String relativeUrl;
  @override
  final String Function(BuildContext context) title;
  @override
  final Widget Function(BuildContext context) builder;

  const UrlWidgetRoute({
    required this.relativeUrl,
    required this.title,
    required this.builder,
  });
}

String mediaClassForMediaSize(List<MediaSize> all, MediaSize size) {
  final index = all.indexOf(size);
  assert(index != -1, "The given size $size was not in $all");
  return [
    '@media all and ${'(min-width: ${Breakpoint.defaultBreakpointSize(size)}px)'}${index + 1 >= all.length ? "" : " and (max-width: ${Breakpoint.defaultBreakpointSize(all[index + 1]) - 1}px)"} {',
    for (final current in all) //
      '  .size${current.index} { display: ${size == current ? "block" : "none"}; }',
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
