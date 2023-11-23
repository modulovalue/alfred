import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/border_radius.dart';
import 'package:alfred/bluffer/base/color.dart';
import 'package:alfred/bluffer/base/decoration.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/geometry.dart';
import 'package:alfred/bluffer/base/image.dart';
import 'package:alfred/bluffer/base/locale.dart';
import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/publish/publish.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:alfred/bluffer/widget/widget.dart';

// Run 'dart main.dart' so that assets are located correctly.
void main() {
  publishRaw(
    publishContext: PublishAppContextDefault(
      serialize: serialize_to_disk,
      application: App(
        supportedLocales: [
          const Locale('fr', 'FR'),
          const Locale('en', 'US'),
        ],
        application: (final route) => AppWidget(
          route: route,
        ),
        routes: [
          UrlWidgetRoute(
            title: (final context) {
              final locale = Localizations.localeOf(context);
              if (locale!.languageCode == 'fr') {
                return 'Accueil';
              } else {
                return 'Home';
              }
            },
            relativeUrl: 'index',
            builder: (final context) => Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("abc"),
                  const Text("def"),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Hello world!'),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0000FF),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        const BoxShadow(
                          color: Color(0xAA0000FF),
                          blurRadius: 10,
                          offset: Offset(10, 10),
                        ),
                      ],
                    ),
                  ),
                  Image.asset(
                    'images/logo_dart_192px.svg',
                    fit: BoxFit.cover,
                  ),
                  Column(
                    children: List.generate(
                      5,
                      (final index) => const Text('Hello world!'),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Image(
                    image: dartImg,
                  ),
                  const SizedBox(
                    height: 20,
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
                              return const Color(0xFFFFFFFF);
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

const ImageProvider dartImg = ImageProvider.network(
  "data:image/jpeg;base64,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",
);
