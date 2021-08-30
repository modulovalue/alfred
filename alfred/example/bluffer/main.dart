import 'dart:io';

import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/border_radius.dart';
import 'package:alfred/bluffer/base/color.dart';
import 'package:alfred/bluffer/base/decoration.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/geometry.dart';
import 'package:alfred/bluffer/base/image.dart';
import 'package:alfred/bluffer/base/locale.dart';
import 'package:alfred/bluffer/base/publish/publish.dart';
import 'package:alfred/bluffer/base/publish/serialize.dart';
import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/widgets/click.dart';
import 'package:alfred/bluffer/widgets/container.dart';
import 'package:alfred/bluffer/widgets/flex.dart';
import 'package:alfred/bluffer/widgets/image.dart';
import 'package:alfred/bluffer/widgets/localizations.dart';
import 'package:alfred/bluffer/widgets/padding.dart';
import 'package:alfred/bluffer/widgets/sized_box.dart';
import 'package:alfred/bluffer/widgets/text.dart';
import 'package:alfred/bluffer/widgets/theme.dart';
import 'package:alfred/bluffer/widgets/widget/interface/widget.dart';

// Run 'dart main.dart' so that assets are located correctly.
void main() {
  final app = App(
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
              const SizedBox(height: 20),
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
              ),
            ],
          ),
        ),
      ),
    ],
  );
  publishRaw(
    publishContext: PublishAppContextDefault(
      serialize: (final path, final element) {
        final file = File(path);
        final serializedHtml = serializeHtml(
          html: element,
        );
        file.writeAsStringSync(
          serializedHtml,
        );
      },
      application: app,
    ),
  );
}
