import 'dart:io';

import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/print.dart';
import 'package:alfred/alfred/impl/middleware/closing.dart';
import 'package:alfred/alfred/impl/middleware/cors.dart';
import 'package:alfred/alfred/impl/middleware/html.dart';
import 'package:alfred/alfred/impl/middleware/io_dir.dart';
import 'package:alfred/alfred/impl/middleware/io_download.dart';
import 'package:alfred/alfred/impl/middleware/io_file.dart';
import 'package:alfred/alfred/impl/middleware/json.dart';
import 'package:alfred/alfred/impl/middleware/middleware.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';
import 'package:alfred/alfred/impl/middleware/websocket.dart';
import 'package:alfred/alfred/impl/middleware/widget.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/alfred/interface/middleware.dart';
import 'package:alfred/alfred/interface/serve_context.dart';
import 'package:alfred/base/http_status_code.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/widgets/builder.dart';
import 'package:alfred/bluffer/widgets/flex.dart';
import 'package:alfred/bluffer/widgets/padding.dart';
import 'package:alfred/bluffer/widgets/sized_box.dart';
import 'package:alfred/bluffer/widgets/text.dart';

// TODO split examples back into separate files.
// TODO move all examples into a new package?
Future<void> main() async {
  final session = MyWebSocketSession();
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
    routes: Routes(
      routes: [
        // Bluffer.
        Route.get(
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
        Route.all(
          path: '*',
          middleware: const CorsMiddleware(),
        ),
        // Custom header.
        Route.all(
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
        Route.get(
          path: '/text',
          middleware: const ServeString(
            string: 'Text response',
          ),
        ),
        // Json.
        Route.get(
          path: '/json',
          middleware: const ServeJson.map(
            map: {
              'json_response': true,
            },
          ),
        ),
        // File.
        Route.get(
          path: '/file',
          middleware: const ServeFileStringPathImpl(
            path: 'test/files/image.jpg',
          ),
        ),
        // Directory
        Route.get(
          path: '/files/*',
          middleware: const ServeDirectoryStringPathImpl(
            path: 'test/files',
          ),
        ),
        // Html.
        Route.get(
          path: '/html',
          middleware: const ServeHtml(
            html: '<html><body><h1>Test HTML</h1></body></html>',
          ),
        ),
        // Download.
        Route.get(
          path: '/image/download',
          middleware: const ServeDownload(
            filename: 'image.jpg',
            child: ServeFileStringPathImpl(
              path: 'test/files/image.jpg',
            ),
          ),
        ),
        // Arguments.
        Route.all(
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
        Route.post(
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
        Route.get(
          path: '/redirect',
          middleware: MiddlewareBuilder(
            process: (final c) {
              final googleUri = Uri.parse('https://www.google.com');
              return c.res.redirect(googleUri);
            },
          ),
        ),
        // Throw error.
        Route.get(
          path: '/throwserror',
          middleware: MiddlewareBuilder(
            process: (final _) => throw Exception('generic exception'),
          ),
        ),
        // Custom middleware.
        // TODO error is not caught.
        Route.get(
          path: '/authorize',
          middleware: const ExampleAuthorizationMiddleware(),
        ),
        // Post body parsing.
        Route.post(
          path: '/post-route',
          middleware: MiddlewareBuilder(
            process: (final context) async {
              final body = await context.body; // JSON body.
              assert(body != null, "Body is not null");
            },
          ),
        ),
        // Deliver chat client for the user.
        webSocketClientRoute(
          path: "/websocket",
        ),
        // Deliver chat server for the client.
        webSocketServerRoute(
          session: session,
        ),
      ],
    ),
  );
  const log = AlfredLoggingDelegatePrintImpl();
  await app.build(log: log);
}

class ExampleAuthorizationMiddleware implements Middleware {
  const ExampleAuthorizationMiddleware();

  @override
  Future<dynamic> process(
    final ServeContext context,
  ) async {
    if (context.req.headers.value('Authorization') != 'apikey') {
      print("Failure");
      context.res.setStatusCode(httpStatusUnauthorized401);
      context.res.writeString('authentication failed.');
      await context.res.close();
    } else {
      print("success");
    }
  }
}

HttpRoute webSocketServerRoute({
  required final WebSocketSession session,
}) =>
    Route.get(
      path: '/ws',
      middleware: ServeWebSocket(
        webSocketSession: session,
      ),
    );

/// TODO it would be great if the javascript portion could come from a dart file that was dart2js'ed.
HttpRoute webSocketClientRoute({
  required final String path,
}) =>
    Route.get(
      path: path,
      middleware: const ServeHtml(
        html: r"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WebSocket</title>
    <style>
        body {font-family: sans-serif;}
        #messages {background: #d8edf5; border-radius: 8px; min-height: 100px; margin-bottom: 8px; display: flex; flex-direction: column;}
        #messages div {background: #eff6f8; border-radius: 8px;  margin: 8px; padding: 6px 12px; display: inline-block; width: fit-content}
    </style>
</head>
<body>
<div id="messages"></div>
<div class="panel">
    <label>Type message and hit <i>&lt;Enter&gt;</i>: <input autofocus id="input" type="text"></label>
</div>
<script type="module">
    document.addEventListener('DOMContentLoaded', () => {
        const input = document.querySelector('#input');
        const messages = document.querySelector('#messages');
        const socket = new WebSocket(`ws://${location.host}/ws`);
        socket.onopen = () => {
            console.log('WebSocket connection established.');
        }
        socket.onmessage = (e) => {
            const el = document.createElement('div');
            el.innerText = e.data;
            messages.appendChild(el);
        }
        socket.onclose = () => {
            console.log('WebSocket connection closed');
        }
        socket.onerror = () => {
            location.reload();
        }
        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && input.value.length > 0) {
                socket.send(input.value);
                input.value = '';
            }
        });
    })
</script>
</body>
</html>
""",
      ),
    );

class MyWebSocketSession with WebSocketSessionStartMixin implements InitiatedWebSocketSession {
  final List<WebSocket> users = [];

  MyWebSocketSession();

  @override
  void onClose(
    final WebSocket ws,
  ) {
    users.remove(ws);
    users.forEach(
      (final user) => user.add('A user has left.'),
    );
  }

  @override
  void onError(
    final WebSocket ws,
    final dynamic error,
  ) {
    // Do nothing. this is an example.
  }

  @override
  void onMessage(
    final WebSocket ws,
    dynamic data,
  ) {
    users.forEach(
      (final user) => user.add(data),
    );
  }

  @override
  InitiatedWebSocketSession onOpen(
    final WebSocket ws,
  ) {
    users.add(ws);
    users
        .where(
          (final user) => user != ws,
        )
        .forEach(
          (final user) => user.add('A new user joined the chat.'),
        );
    return this;
  }
}

List<HttpRoute> resourceBlocking() => [
      Route.all(
        path: '/resource*',
        middleware: MiddlewareBuilder(
          process: (final c) async {
            c.res.setStatusCode(httpStatusUnauthorized401);
            await c.res.close();
          },
        ),
      ),
      Route.get(
        path: '/resource',
        middleware: const ClosingMiddleware(),
      ),
      // Will not be hit
      Route.post(
        path: '/resource',
        middleware: const ClosingMiddleware(),
      ),
      // Will not be hit
      Route.post(
        path: '/resource/1',
        middleware: const ClosingMiddleware(),
      ),
    ];
