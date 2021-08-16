import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/io_file.dart';
import 'package:alfred/alfred/impl/middleware/widget.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/border_radius.dart';
import 'package:alfred/bluffer/base/color.dart';
import 'package:alfred/bluffer/base/decoration.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/image.dart';
import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/widgets/click/click.dart';
import 'package:alfred/bluffer/widgets/container/container.dart';
import 'package:alfred/bluffer/widgets/flex/flex.dart';
import 'package:alfred/bluffer/widgets/image/image.dart';
import 'package:alfred/bluffer/widgets/padding/padding.dart';
import 'package:alfred/bluffer/widgets/text/text.dart';
import 'package:alfred/bluffer/widgets/theme/theme.dart';

Future<void> main() async {
  const dartLogoRelativePath = "/dartlogo.svg";
  final app = makeSimpleAlfred()
    ..addRoutes(
      [
        const RouteGet(
          path: dartLogoRelativePath,
          middleware: ServeFileStringPathImpl(
            "../../bluffer/example/assets/images/logo_dart_192px.svg",
          ),
        ),
        RouteGet(
          path: "/",
          middleware: ServeWidgetBuilder(
            builder: (c, context) => AppWidget(
              route: WidgetRouteImpl(
                title: (final context) => "My title",
                builder: (final context) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Uri: '${c.req.uri}' • Method: '${c.req.method}'",
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Image(
                          image: ImageProvider.network(dartLogoRelativePath),
                        ),
                      ),
                      Click(
                        newTab: true,
                        url: 'https://www.google.com',
                        builder: (final context, final state) => Container(
                          child: Text(
                            'Button',
                            style: Theme.of(context)!.text.paragraph.merge(
                              TextStyle(
                                color: () {
                                  if (state == ClickState.hover) {
                                    return const Color(0xFFFFFFFF);
                                  } else {
                                    return const Color(0xFF0000FF);
                                  }
                                }(),
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: () {
                              if (state == ClickState.hover) {
                                return const Color(0xFF0000FF);
                              } else {
                                return const Color(0x440000FF);
                              }
                            }(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  await app.build();
}
