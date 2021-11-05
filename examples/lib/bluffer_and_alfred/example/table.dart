import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/widget.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/widgets/padding.dart';
import 'package:alfred/bluffer/widgets/table.dart';
import 'package:alfred/bluffer/widgets/text.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final built = await helloAlfred(
    routes: [
      AlfredRoute.get(
        path: "/",
        middleware: const ServeWidgetAppImpl(
          title: "My title!",
          child: Padding(
            padding: EdgeInsets.all(
              20.0,
            ),
            child: TableImpl(
              children: [
                TableRowImpl(
                  children: [
                    TableHeadImpl(
                      child: Text("A"),
                    ),
                    TableHeadImpl(
                      child: Text("B"),
                    ),
                    TableHeadImpl(
                      child: Text("C"),
                    ),
                  ],
                ),
                TableRowImpl(
                  children: [
                    TableDataImpl(
                      child: Text("1"),
                    ),
                    TableDataImpl(
                      child: Text("2"),
                    ),
                    TableDataImpl(
                      child: Text("3"),
                    ),
                  ],
                ),
                TableRowImpl(
                  children: [
                    TableDataImpl(
                      child: Text("a"),
                    ),
                    TableDataImpl(
                      child: Text("b"),
                    ),
                    TableDataImpl(
                      child: Text("c"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    ],
  );
  openLocalhost(
    port: built.args.port,
  );
}
