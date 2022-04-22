import 'package:alfred/alfred/alfred.dart';
import 'package:alfred/alfred/interface.dart';
import 'package:alfred/alfred/middleware/closing.dart';
import 'package:alfred/alfred/middleware/cors.dart';
import 'package:alfred/alfred/middleware/html.dart';
import 'package:alfred/alfred/middleware/json.dart';
import 'package:alfred/alfred/middleware/middleware.dart';
import 'package:alfred/alfred/middleware/string.dart';
import 'package:alfred/alfred/middleware/websocket.dart';
import 'package:alfred/alfred/middleware/widget.dart';
import 'package:alfred/alfred/middleware_io/io_dir.dart';
import 'package:alfred/alfred/middleware_io/io_download.dart';
import 'package:alfred/alfred/middleware_io/io_file.dart';
import 'package:alfred/alfred/recipes/websocket_chatclient.dart';
import 'package:alfred/alfred/recipes/websocket_users.dart';
import 'package:alfred/base/http_status_code.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/systems/flutter.dart';

// TODO split examples back into separate files.
Future<void> main() async {
  final session = WebSocketSessionUsersImpl();
  final app = makeSimpleAlfred(
    onInternalError: (final e) => MiddlewareBuilder(
      process: (final c) {
        c.res.setStatusCode(httpStatusInternalServerError500);
        return const ServeJson.map(
          map: {
            'message': 'error not handled',
          },
        ).process(c);
      },
    ),
    onNotFound: MiddlewareBuilder(
      process: (final c) {
        c.res.setStatusCode(httpStatusNotFound404);
        return const ServeJson.map(
          map: {'message': 'not found'},
        ).process(c);
      },
    ),
  );
  app.add(
    routes: AlfredRoutes(
      routes: [
        // Bluffer.
        AlfredRoute.get(
          path: "/",
          middleware: ServeWidgetAppImpl(
            title: "Title",
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Builder(
                builder: (context) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Hello"),
                    for (final route in app.routes)
                      Row(
                        children: [
                          Text(route.method.description),
                          const SizedBox(width: 12.0),
                          Text(route.path),
                          const SizedBox(width: 12.0),
                          if (route.usesWildcardMatcher) //
                            const Text("(Uses a wildcard matcher)"),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // CORS.
        AlfredRoute.all(
          path: '*',
          middleware: const CorsMiddleware(),
        ),
        // Custom header.
        AlfredRoute.all(
          path: '*',
          middleware: MiddlewareBuilder(
            process: (final c) async {
              // Perform action
              c.res.setHeaderString(
                'x-custom-header',
                "Alfred isn't bad",
              );
              // No need to call next as we don't send a response.
              // Alfred will find the next matching route
            },
          ),
        ),
        // A wildcard'ed route blocks others from being hit.
        ...resourceBlocking(),
        // String.
        AlfredRoute.get(
          path: '/text',
          middleware: const ServeString(
            string: 'Text response',
          ),
        ),
        // Json.
        AlfredRoute.get(
          path: '/json',
          middleware: const ServeJson.map(
            map: {
              'json_response': true,
            },
          ),
        ),
        // File.
        AlfredRoute.get(
          path: '/file',
          middleware: const ServeFileStringPathImpl(
            path: 'test/files/image.jpg',
          ),
        ),
        // Directory
        AlfredRoute.get(
          path: '/files/*',
          middleware: const ServeDirectoryStringPathImpl(
            path: 'test/files',
          ),
        ),
        // Html.
        AlfredRoute.get(
          path: '/html',
          middleware: const ServeHtml(
            html: '<html><body><h1>Test HTML</h1></body></html>',
          ),
        ),
        // Download.
        AlfredRoute.get(
          path: '/image/download',
          middleware: const ServeDownload(
            filename: 'image.jpg',
            child: ServeFileStringPathImpl(
              path: 'test/files/image.jpg',
            ),
          ),
        ),
        // Arguments.
        AlfredRoute.all(
          path: '/example/:id/:name',
          middleware: MiddlewareBuilder(
            process: (final context) async {
              // ignore: unnecessary_statements
              print(context.arguments!['id']);
              // ignore: unnecessary_statements
              print(context.arguments!['name']);
            },
          ),
        ),
        // Querystring.
        AlfredRoute.post(
          path: '/route',
          middleware: MiddlewareBuilder(
            process: (final c) async {
              // Handle /route?qsvar=true
              final result = c.req.uri.queryParameters['qsvar'];
              // ignore: unnecessary_statements
              print(result == 'true');
              await c.res.close();
            },
          ),
        ),
        // Redirect.
        AlfredRoute.get(
          path: '/redirect',
          middleware: MiddlewareBuilder(
            process: (final c) {
              final googleUri = Uri.parse('https://www.google.com');
              return c.res.redirect(googleUri);
            },
          ),
        ),
        // Throw error.
        AlfredRoute.get(
          path: '/throwserror',
          middleware: MiddlewareBuilder(
            process: (final _) => throw Exception('generic exception'),
          ),
        ),
        // Custom middleware.
        // TODO error is not caught.
        AlfredRoute.get(
          path: '/authorize',
          middleware: const ExampleAuthorizationMiddleware(),
        ),
        // Post body parsing.
        AlfredRoute.post(
          path: '/post-route',
          middleware: MiddlewareBuilder(
            process: (final context) async {
              final body = await context.body; // JSON body.
              assert(body != null, "Body is not null");
            },
          ),
        ),
        // Deliver chat client for the user.
        AlfredRoute.get(
          path: "/websocket",
          middleware: const ServeHtml(
            html: websocket_chatclient,
          ),
        ),
        // Deliver chat server for the client.
        // TODO why does this crash the server when accessed via browser?
        AlfredRoute.get(
          path: '/ws',
          middleware: ServeWebSocket(
            webSocketSession: session,
          ),
        )
      ],
    ),
  );
  const log = AlfredLoggingDelegatePrintImpl();
  await app.build(log: log);
}

class ExampleAuthorizationMiddleware implements AlfredMiddleware {
  const ExampleAuthorizationMiddleware();

  @override
  Future<dynamic> process(
    final ServeContext context,
  ) async {
    if (context.req.headers.getValue('Authorization') != 'apikey') {
      print("Failure");
      context.res.setStatusCode(httpStatusUnauthorized401);
      context.res.writeString('authentication failed.');
      await context.res.close();
    } else {
      print("success");
    }
  }
}

List<AlfredHttpRoute> resourceBlocking() => [
      AlfredRoute.all(
        path: '/resource*',
        middleware: MiddlewareBuilder(
          process: (final c) async {
            c.res.setStatusCode(httpStatusUnauthorized401);
            await c.res.close();
          },
        ),
      ),
      AlfredRoute.get(
        path: '/resource',
        middleware: const ClosingMiddleware(),
      ),
      // Will not be hit
      AlfredRoute.post(
        path: '/resource',
        middleware: const ClosingMiddleware(),
      ),
      // Will not be hit
      AlfredRoute.post(
        path: '/resource/1',
        middleware: const ClosingMiddleware(),
      ),
    ];
