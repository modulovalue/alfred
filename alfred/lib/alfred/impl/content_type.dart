import '../interface/serve_context.dart';

class AlfredContentTypeImpl implements AlfredContentType {
  @override
  final String primaryType;

  @override
  final String subType;

  @override
  final String mimeType;

  @override
  final String? charset;

  final String? Function(String) getParam;

  const AlfredContentTypeImpl({
    required final this.primaryType,
    required final this.subType,
    required final this.charset,
    required final this.mimeType,
    required final this.getParam,
  });

  @override
  String? getParameter(
    final String key,
  ) =>
      getParam(key);
}
