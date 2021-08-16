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
import 'package:alfred/alfred/interface/alfred.dart';
import 'package:alfred/alfred/interface/http_route_factory.dart';
import 'package:alfred/alfred/interface/middleware.dart';
import 'package:alfred/alfred/interface/serve_context.dart';
import 'package:alfred/bluffer/base/edge_insets.dart';
import 'package:alfred/bluffer/widgets/builder/builder.dart';
import 'package:alfred/bluffer/widgets/flex/flex.dart';
import 'package:alfred/bluffer/widgets/padding/padding.dart';
import 'package:alfred/bluffer/widgets/sized_box/sized_box.dart';
import 'package:alfred/bluffer/widgets/text/text.dart';

// TODO move all examples into a new package.
Future<void> main() async {
  final session = MyWebSocketSession();
  final app = makeSimpleAlfred(
    onInternalError: (final e) => MiddlewareBuilder(
      (final c) {
        c.res.statusCode = 500;
        return const ServeJson.map(
          {'message': 'error not handled'},
        ).process(c);
      },
    ),
    onNotFound: MiddlewareBuilder(
      (final c) {
        c.res.statusCode = 404;
        return const ServeJson.map(
          {'message': 'not found'},
        ).process(c);
      },
    ),
  );
  app.addRoutes(
    [
      // Bluffer.
      RouteGet(
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
                        Text(route.route),
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
      // Cors
      const RouteAll(
        path: '*',
        middleware: CorsMiddleware(),
      ),
      // Custom header.
      RouteAll(
        path: '*',
        middleware: MiddlewareBuilder(
          (final c) async {
            // Perform action
            c.res.headers.add(
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
      const RouteGet(
        path: '/text',
        middleware: ServeString('Text response'),
      ),
      // Json.
      const RouteGet(
        path: '/json',
        middleware: ServeJson.map({'json_response': true}),
      ),
      // File.
      const RouteGet(
        path: '/file',
        middleware: ServeFileStringPathImpl('test/files/image.jpg'),
      ),
      // Directory
      const RouteGet(
        path: '/files/*',
        middleware: ServeDirectoryStringPathImpl('test/files'),
      ),
      // Html.
      const RouteGet(
        path: '/html',
        middleware: ServeHtml('<html><body><h1>Test HTML</h1></body></html>'),
      ),
      // Download.
      const RouteGet(
        path: '/image/download',
        middleware: ServeDownload(
          filename: 'image.jpg',
          child: ServeFileStringPathImpl('test/files/image.jpg'),
        ),
      ),
      // Arguments.
      RouteAll(
        path: '/example/:id/:name',
        middleware: MiddlewareBuilder(
          (final context) async {
            // ignore: unnecessary_statements
            print(context.arguments!['id']);
            // ignore: unnecessary_statements
            print(context.arguments!['name']);
          },
        ),
      ),
      // Querystring.
      RoutePost(
        path: '/route',
        middleware: MiddlewareBuilder(
          (final c) async {
            // Handle /route?qsvar=true
            final result = c.req.uri.queryParameters['qsvar'];
            // ignore: unnecessary_statements
            print(result == 'true');
            await c.res.close();
          },
        ),
      ),
      // Redirect.
      RouteGet(
        path: '/redirect',
        middleware: MiddlewareBuilder(
          (final c) {
            final googleUri = Uri.parse('https://www.google.com');
            return c.res.redirect(googleUri);
          },
        ),
      ),
      // Throw error.
      RouteGet(
        path: '/throwserror',
        middleware: MiddlewareBuilder(
          (final _) => throw Exception('generic exception'),
        ),
      ),
      // Custom middleware.
      // TODO error is not caught.
      const RouteGet(
        path: '/authorize',
        middleware: ExampleAuthorizationMiddleware(),
      ),
      // Post body parsing.
      RoutePost(
        path: '/post-route',
        middleware: MiddlewareBuilder(
          (final context) async {
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
      throw const _AlfredExceptionImpl(401, {'message': 'authentication failed.'});
    } else {
      print("success");
    }
  }
}

/// Throw these exceptions to bubble up an error from sub functions and have them
/// handled automatically for the client
class _AlfredExceptionImpl implements AlfredResponseException {
  /// The response to send to the client
  @override
  final Object? response;

  /// The statusCode to send to the client
  @override
  final int statusCode;

  const _AlfredExceptionImpl(
    final this.statusCode,
    final this.response,
  );

  @override
  Z match<Z>({
    required final Z Function(AlfredResponseException p1) response,
    required final Z Function(AlfredNotFoundException p1) notFound,
  }) =>
      response(this);
}

RouteGet webSocketServerRoute({
  required final WebSocketSession session,
}) =>
    RouteGet(
      path: '/ws',
      middleware: WebSocketValueMiddleware(session),
    );

/// TODO it would be great if the javascript portion could come from a dart file that was dart2js'ed.
RouteGet webSocketClientRoute({
  required final String path,
}) =>
    RouteGet(
      path: path,
      middleware: const ServeHtml(
        r"""<!DOCTYPE html>
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

class MyWebSocketSession with WebSocketSessionStartMixin {
  final List<WebSocket> users = [];

  MyWebSocketSession();

  @override
  void onClose(WebSocket ws) {
    users.remove(ws);
    users.forEach((final user) => user.add('A user has left.'));
  }

  @override
  void onError(WebSocket ws, dynamic error) {
    // Do nothing. this is an example.
  }

  @override
  void onMessage(WebSocket ws, dynamic data) {
    users.forEach((user) => user.add(data));
  }

  @override
  void onOpen(WebSocket ws) {
    users.add(ws);
    users.where((user) => user != ws).forEach((user) => user.add('A new user joined the chat.'));
  }
}

List<Route> resourceBlocking() => [
      RouteAll(
        path: '/resource*',
        middleware: MiddlewareBuilder(
          (final c) async {
            c.res.statusCode = 401;
            await c.res.close();
          },
        ),
      ),
      const RouteGet(
        path: '/resource',
        middleware: ClosingMiddleware(),
      ),
      // Will not be hit
      const RoutePost(
        path: '/resource',
        middleware: ClosingMiddleware(),
      ),
      // Will not be hit
      const RoutePost(
        path: '/resource/1',
        middleware: ClosingMiddleware(),
      ),
    ];
