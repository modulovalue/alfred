import '../impl/get_params.dart';
import '../impl/parse_http_body.dart';
import '../interface/alfred.dart';
import '../interface/http_route_factory.dart';
import '../interface/serve_context.dart';
import 'request.dart';
import 'response.dart';

class ServeContextIOImpl implements ServeContext {
  @override
  final Alfred alfred;
  @override
  final AlfredRequestImpl req;
  @override
  final AlfredResponseImpl res;
  @override
  late AlfredHttpRoute route;

  ServeContextIOImpl({
    required final this.alfred,
    required final this.req,
    required final this.res,
  });

  @override
  Future<Object?> get body async => (await processRequest(req, res)).httpBody.body;

  @override
  Map<String, String>? get arguments => getParams(
        route: route.path,
        input: req.req.uri.path,
      );
}
