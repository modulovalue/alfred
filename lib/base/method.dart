abstract class Method {
  String get description;
}

abstract class Methods {
  static const MethodGet get = MethodGet._();
  static const MethodPost post = MethodPost._();
  static const MethodPut put = MethodPut._();
  static const MethodDelete delete = MethodDelete._();
  static const MethodOptions options = MethodOptions._();
  static const MethodAll all = MethodAll._();
  static const MethodPatch patch = MethodPatch._();

  // TODO This should add no overhead. benchmark [tryParse] against [tryParseIfElse].
  static const Map<String, BuiltinMethod> parseMap = {
    ...MethodGet.parseContributor,
    ...MethodPost.parseContributor,
    ...MethodPut.parseContributor,
    ...MethodDelete.parseContributor,
    ...MethodOptions.parseContributor,
    ...MethodAll.parseContributor,
    ...MethodPatch.parseContributor,
  };

  static Method? tryParse(String str) => parseMap[str];

  static Method? tryParseIfElse(String str) {
    if (str == MethodGet.string) {
      return Methods.get;
    } else if (str == MethodPost.string) {
      return Methods.post;
    } else if (str == MethodPut.string) {
      return Methods.put;
    } else if (str == MethodDelete.string) {
      return Methods.delete;
    } else if (str == MethodOptions.string) {
      return Methods.options;
    } else if (str == MethodAll.string) {
      return Methods.all;
    } else if (str == MethodPatch.string) {
      return Methods.patch;
    } else {
      return null;
    }
  }
}

abstract class BuiltinMethod implements Method {
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  });
}

class MethodGet implements BuiltinMethod {
  static const Map<String, MethodGet> parseContributor = {string: MethodGet._()};

  static const String string = "GET";

  const MethodGet._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      get(this);
}

class MethodPost implements BuiltinMethod {
  static const Map<String, MethodPost> parseContributor = {string: MethodPost._()};

  static const String string = "POST";

  const MethodPost._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      post(this);
}

class MethodPut implements BuiltinMethod {
  static const Map<String, MethodPut> parseContributor = {string: MethodPut._()};

  static const String string = "PUT";

  const MethodPut._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      put(this);
}

class MethodDelete implements BuiltinMethod {
  static const Map<String, MethodDelete> parseContributor = {string: MethodDelete._()};

  static const String string = "DELETE";

  const MethodDelete._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      delete(this);
}

class MethodOptions implements BuiltinMethod {
  static const Map<String, MethodOptions> parseContributor = {string: MethodOptions._()};

  static const String string = "OPTIONS";

  const MethodOptions._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      options(this);
}

class MethodAll implements BuiltinMethod {
  static const Map<String, MethodAll> parseContributor = {string: MethodAll._()};

  static const String string = "ALL";

  const MethodAll._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      all(this);
}

class MethodPatch implements BuiltinMethod {
  static const Map<String, MethodPatch> parseContributor = {string: MethodPatch._()};

  static const String string = "PATCH";

  const MethodPatch._();

  @override
  String get description => string;

  @override
  R matchBuiltinMethods<R>({
    required R Function(MethodGet) get,
    required R Function(MethodPost) post,
    required R Function(MethodPut) put,
    required R Function(MethodDelete) delete,
    required R Function(MethodOptions) options,
    required R Function(MethodAll) all,
    required R Function(MethodPatch) patch,
  }) =>
      patch(this);
}
