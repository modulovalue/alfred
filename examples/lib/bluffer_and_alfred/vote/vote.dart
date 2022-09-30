import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:alfred/alfred/middleware/widget.dart';
import 'package:alfred/bluffer/base/border_radius.dart';
import 'package:alfred/bluffer/base/color.dart';
import 'package:alfred/bluffer/base/decoration.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/base/text.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:alfred/bluffer/widget/widget.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final app = alfredWithRoutes(
    routes: [
      AlfredRoutedRoutes(
        routes: [
          AlfredRoute.get(
            path: "/yes",
            middleware: ServeWidgetAppImpl(
              title: "Yes",
              onProcess: () => yes++,
              child: thankYouWidget(),
            ),
          ),
          AlfredRoute.get(
            path: "/no",
            middleware: ServeWidgetAppImpl(
              title: "No",
              onProcess: () => no++,
              child: thankYouWidget(),
            ),
          ),
          AlfredRoute.get(
            path: "/",
            middleware: ServeWidgetAppImpl(
              title: "Vote",
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Builder(
                  builder: (final context) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Vote"),
                      voteYesWidget(yes),
                      voteNoWidget(no),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    ],
  );
  await app.build();
  openLocalhost();
}

int yes = 0;
int no = 0;

Widget voteNoWidget(
  final int no,
) =>
    voteButton(
      "No (" + no.toString() + ")",
      "/no",
      "Vote No",
    );

Widget voteYesWidget(
  final int yes,
) =>
    voteButton(
      "Yes (" + yes.toString() + ")",
      "/yes",
      "Vote Yes",
    );

Widget thankYouWidget() => Padding(
      padding: const EdgeInsets.all(
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thank you!",
          ),
          const SizedBox(
            height: 20.0,
          ),
          Click(
            newTab: false,
            url: '/',
            builder: (final context) => Container(
              child: Text(
                'Go back',
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
          )
        ],
      ),
    );

Widget voteButton(
  final String text,
  final String target,
  final String info,
) =>
    Row(
      children: [
        Text(
          text,
        ),
        const SizedBox(
          width: 20.0,
        ),
        Click(
          newTab: false,
          url: target,
          builder: (final context) => Container(
            child: Text(
              info,
              style: Theme.of(context)!.text.paragraph.merge(
                TextStyle(
                  color: () {
                    // if (state == ClickState.hover) {
                    //   return const Color(0xFFFFFFFF);
                    // } else {
                    return const Color(0xFF0000FF);
                    // }
                  }(),
                ),
              ),
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: () {
                // if (state == ClickState.hover) {
                //   return const Color(0xFF0000FF);
                // } else {
                return const Color(0x440000FF);
                // }
              }(),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        )
      ],
    );
