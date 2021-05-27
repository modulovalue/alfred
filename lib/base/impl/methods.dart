import '../interface/method.dart';

abstract class Methods {
  static const MethodGet get = MethodGet._();
  static const MethodPost post = MethodPost._();
  static const MethodPut put = MethodPut._();
  static const MethodDelete delete = MethodDelete._();
  static const MethodOptions options = MethodOptions._();
  static const MethodAll all = MethodAll._();
  static const MethodPatch patch = MethodPatch();
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
  static const String string = "PATCH";

  const MethodPatch();

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
