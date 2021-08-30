/// https://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Request_methods
abstract class Methods {
  static const MethodGet get = MethodGet._();
  static const MethodPost post = MethodPost._();
  static const MethodPut put = MethodPut._();
  static const MethodDelete delete = MethodDelete._();
  static const MethodOptions options = MethodOptions._();
  static const MethodAll all = MethodAll._();
  static const MethodPatch patch = MethodPatch._();
  static const MethodHead head = MethodHead._();
  static const MethodConnect connect = MethodConnect._();
  static const MethodTrace trace = MethodTrace._();
}

abstract class Method {
  String get description;

  bool isMethod(
    final String method,
  );
}

abstract class BuiltinMethod implements Method {
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  });
}

class MethodGet implements BuiltinMethod {
  static const String getString = "GET";

  const MethodGet._();

  @override
  String get description => getString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      get(this);

  @override
  bool isMethod(
    final String method,
  ) =>
      method == getString;
}

class MethodHead implements BuiltinMethod {
  static const String headString = "HEAD";

  const MethodHead._();

  @override
  String get description => headString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      head(this);

  @override
  bool isMethod(
    final String method,
  ) =>
      method == headString;
}

class MethodConnect implements BuiltinMethod {
  static const String connectString = "CONNECT";

  const MethodConnect._();

  @override
  String get description => connectString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      connect(this);

  @override
  bool isMethod(
    final String method,
  ) =>
      method == connectString;
}

class MethodTrace implements BuiltinMethod {
  static const String traceString = "TRACE";

  const MethodTrace._();

  @override
  String get description => traceString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      trace(this);

  @override
  bool isMethod(
    final String method,
  ) =>
      method == traceString;
}

class MethodPost implements BuiltinMethod {
  static const String postString = "POST";

  const MethodPost._();

  @override
  String get description => postString;

  @override
  bool isMethod(
    final String method,
  ) =>
      method == postString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      post(this);
}

class MethodPut implements BuiltinMethod {
  static const String putString = "PUT";

  const MethodPut._();

  @override
  String get description => putString;

  @override
  bool isMethod(
    final String method,
  ) =>
      method == putString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      put(this);
}

class MethodDelete implements BuiltinMethod {
  static const String deleteString = "DELETE";

  const MethodDelete._();

  @override
  String get description => deleteString;

  @override
  bool isMethod(
    final String method,
  ) =>
      method == deleteString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      delete(this);
}

class MethodOptions implements BuiltinMethod {
  static const String optionsString = "OPTIONS";

  const MethodOptions._();

  @override
  String get description => optionsString;

  @override
  bool isMethod(
    final String method,
  ) =>
      method == optionsString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      options(this);
}

class MethodAll implements BuiltinMethod {
  static const String allString = "ALL";

  const MethodAll._();

  @override
  String get description => allString;

  @override
  bool isMethod(
    final String method,
  ) =>
      method == allString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      all(this);
}

class MethodPatch implements BuiltinMethod {
  static const String patchString = "PATCH";

  const MethodPatch._();

  @override
  String get description => patchString;

  @override
  bool isMethod(
    final String method,
  ) =>
      method == patchString;

  @override
  R matchBuiltinMethods<R>({
    required final R Function(MethodGet) get,
    required final R Function(MethodPost) post,
    required final R Function(MethodPut) put,
    required final R Function(MethodDelete) delete,
    required final R Function(MethodOptions) options,
    required final R Function(MethodAll) all,
    required final R Function(MethodPatch) patch,
    required final R Function(MethodHead) head,
    required final R Function(MethodConnect) connect,
    required final R Function(MethodTrace) trace,
  }) =>
      patch(this);
}
