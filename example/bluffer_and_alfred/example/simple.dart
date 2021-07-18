import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/middleware/widget.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/widgets/padding/padding.dart';
import 'package:alfred/bluffer/widgets/text/text.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final alfred = AlfredImpl();
  alfred.get(
    "/",
    const ServeWidget.app(
      title: "My title!",
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Text("Hello"),
      ),
    ),
  );
  final built = await alfred.build(port: 6565);
  openLocalhost(built.args.port);
}
