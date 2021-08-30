import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/widget.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/widgets/padding.dart';
import 'package:alfred/bluffer/widgets/text.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final built = await helloAlfred(
    routes: [
      Route.get(
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
  openLocalhost(built.args.port);
}