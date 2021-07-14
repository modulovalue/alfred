import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/html_builder.dart';
import 'package:alfred/alfred/impl/middleware/io.dart';
import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/border_radius.dart';
import 'package:alfred/bluffer/base/color.dart';
import 'package:alfred/bluffer/base/decoration.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/image.dart';
import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/base/util/single_file.dart';
import 'package:alfred/bluffer/widgets/click/click.dart';
import 'package:alfred/bluffer/widgets/container/container.dart';
import 'package:alfred/bluffer/widgets/flex/flex.dart';
import 'package:alfred/bluffer/widgets/image/image.dart';
import 'package:alfred/bluffer/widgets/padding/padding.dart';
import 'package:alfred/bluffer/widgets/sized_box/sized_box.dart';
import 'package:alfred/bluffer/widgets/text/text.dart';
import 'package:alfred/bluffer/widgets/theme/theme.dart';

Future<void> main() async {
  final app = AlfredImpl();
  app.get(
    "/dartlogo.svg",
    ServeFile.at("example/bluffer/simple_example/assets/images/logo_dart_192px.svg"),
  );
  app.get(
    "/",
    ServeHtmlBuilder(
      (c) => singlePage(
        (context) => ApplicationWidget(
          route: WidgetRouteImpl(
            title: (context) => "My title",
            builder: (context) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${c.req.uri} ${c.req.method}",
                    ),
                    const Padding(
                      padding: EdgeInsets.all(100),
                      child: Image(
                        image: ImageProvider.network("/dartlogo.svg"),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Click(
                      newTab: true,
                      url: 'https://www.google.com',
                      builder: (context, state) => Container(
                        child: Text(
                          'Button',
                          style: Theme.of(context)! //
                              .text
                              .paragraph
                              .merge(
                                TextStyle(
                                  color: state == ClickState.hover ? const Color(0xFFFFFFFF) : const Color(0xFF0000FF),
                                ),
                              ),
                        ),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: state == ClickState.hover ? const Color(0xFF0000FF) : const Color(0x440000FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
  await app.build();
}
