import '../interface/parse_http_body.dart';

class AlfredContentTypeImpl implements AlfredContentType {
  @override
  final String primaryType;

  @override
  final String subType;

  const AlfredContentTypeImpl({
    required final this.primaryType,
    required final this.subType,
  });
}
