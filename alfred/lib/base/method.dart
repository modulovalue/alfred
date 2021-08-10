abstract class Method {
  String get description;

  bool isMethod(
    final String method,
  );
}

abstract class Methods {
  static const MethodGet get = MethodGet._();
  static const MethodPost post = MethodPost._();
  static const MethodPut put = MethodPut._();
  static const MethodDelete delete = MethodDelete._();
  static const MethodOptions options = MethodOptions._();
  static const MethodAll all = MethodAll._();
  static const MethodPatch patch = MethodPatch._();
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
  }) =>
      get(this);

  @override
  bool isMethod(
    final String method,
  ) =>
      method == getString;
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
  }) =>
      patch(this);
}
