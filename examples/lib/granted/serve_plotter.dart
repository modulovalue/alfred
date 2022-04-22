import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/middleware/html.dart';
import 'package:alfred/util/open.dart';

Future<void> main() async {
  final built = await helloAlfred(
    routes: [
      AlfredRoute.get(
        path: "/*",
        middleware: const ServeHtml(
          html: r"""
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Plotter - Test</title>
    <style>
      html, body {
        width: 100%;
        height: 100%;
        margin: 0;
        padding: 0;
        overflow: hidden;
      }
      #output {
        width: 100%;
        height: 100%;
        margin: 0;
        padding: 0;
        overflow: hidden;
      }
    </style>
  </head>
  <body>
    <div id="output"></div>
    <script>
</script>
  </body>
</html>
""",
        ),
        // middleware: const ServeDirectoryStringPathImpl(
        //   path: "/Users/valauskasmodestas/Desktop/alfred/alfred/build",
        // ),
      ),
    ],
  );
  openLocalhost(
    port: built.args.port,
  );
}
