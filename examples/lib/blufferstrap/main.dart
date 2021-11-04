import 'dart:io';

import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/publish/publish.dart';
import 'package:alfred/bluffer/base/publish/serialize.dart';
import 'package:alfred/bluffer/bootstrap_5/button.dart';
import 'package:alfred/bluffer/html/html_impl.dart';
import 'package:alfred/bluffer/widgets/flex.dart';
import 'package:alfred/bluffer/widgets/padding.dart';
import 'package:alfred/bluffer/widgets/sized_box.dart';
import 'package:alfred/bluffer/widgets/widget/interface/widget.dart';

// TODO finish https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
void main() {
  publishRaw(
    publishContext: PublishAppContextDefault(
      serialize: (final path, final element) {
        final file = File(path);
        final serializedHtml = serializeHtmlElement(
          element: element,
        );
        file.writeAsStringSync(
          serializedHtml,
        );
      },
      application: App(
        application: (final route) => AppWidget(
          route: route,
          enableCssReset: false,
          // TODO have a bootstrap include model.
          scriptLinks: [
            ScriptElementImpl(
              // TODO rel crossorigin integrity https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
              src: "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js",
              childNodes: [],
            ),
          ],
          stylesheetLinks: [
            // TODO rel crossorigin integrity https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
            "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css",
          ],
        ),
        routes: [
          UrlWidgetRoute(
            title: (final context) => 'Blufferstrap',
            relativeUrl: 'index',
            builder: (final context) => const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BootstrapButton(
                        type: BootstrapButtonType.primary,
                        text: "Primary",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.secondary,
                        text: "Secondary",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.success,
                        text: "Success",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.danger,
                        text: "Danger",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.warning,
                        text: "Warning",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.info,
                        text: "Info",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.dark,
                        text: "Dark",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.light,
                        text: "Light",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapButton(
                        type: BootstrapButtonType.link,
                        text: "Link",
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.primary,
                        text: "Primary",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.secondary,
                        text: "Secondary",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.success,
                        text: "Success",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.danger,
                        text: "Danger",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.warning,
                        text: "Warning",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.info,
                        text: "Info",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                      BootstrapOutlineButton(
                        type: BootstrapOutlineButtonType.dark,
                        text: "Dark",
                      ),
                      SizedBox(
                        width: 8.0,
                      ),
                    ],
                  ),
                ]
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
