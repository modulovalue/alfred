import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:alfred/alfred/middleware/widget.dart';
import 'package:alfred/alfred/middleware_io/io_file.dart';
import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/border_radius.dart';
import 'package:alfred/bluffer/base/color.dart';
import 'package:alfred/bluffer/base/decoration.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/image.dart';
import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  const dartLogoRelativePath = "/dartlogo.svg";
  final app = makeSimpleAlfred()
    ..add(
      routes: AlfredRoutedRoutes(
        routes: [
          AlfredRoute.get(
            path: dartLogoRelativePath,
            middleware: const ServeFileStringPathImpl(
              path: "../../bluffer/example/assets/images/logo_dart_192px.svg",
            ),
          ),
          AlfredRoute.get(
            path: "/",
            middleware: ServeWidgetBuilder(
              builder: (final c, final context) => AppWidget(
                route: WidgetRouteImpl(
                  title: (final context) => "My title",
                  builder: (final context) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Uri: '" + c.req.uri.toString() + "' • Method: '" + c.req.method + "'",
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
                          builder: (final context) => Container(
                            child: Text(
                              'Button',
                              style: Theme.of(context)!.text.paragraph.merge(
                                TextStyle(
                                  color: () {
                                    // if (state == ClickState.hover) {
                                    //   return const Color(0xFFFFFFFF);
                                    // } else {
                                    //   return const Color(0xFF0000FF);
                                    // }
                                  }(),
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: () {
                                // if (state == ClickState.hover) {
                                return const Color(0xFF0000FF);
                                // } else {
                                //   return const Color(0x440000FF);
                                // }
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
      ),
    );
  final built = await app.build();
  openLocalhost(
    port: built.args.port,
  );
}
