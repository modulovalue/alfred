import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/middleware/widget.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/systems/flutter.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final built = await helloAlfred(
    routes: [
      AlfredRoute.get(
        path: "/",
        middleware: const ServeWidgetAppImpl(
          title: "My title!",
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text("Hello"),
          ),
        ),
      )
    ],
  );
  openLocalhost(
    port: built.args.port,
  );
}
