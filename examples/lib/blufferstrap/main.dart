import 'package:alfred/bluffer/base/app.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/publish/publish.dart';
import 'package:alfred/bluffer/systems/bootstrap_5.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:alfred/bluffer/widget/widget.dart';

// TODO implement more from https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
// TODO bootstrap navbar, better with an html element that is less typesafe by passing on pure html?
void main() {
  publishRaw(
    publishContext: PublishAppContextDefault(
      serialize: serialize_to_disk,
      application: App(
        application: (final route) => AppWidget(
          route: route,
          enableCssReset: false,
          includes: bootstrapIncludes,
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
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
