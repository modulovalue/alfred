abstract class Method {
  static const MethodGet get = MethodGet();
  static const MethodPost post = MethodPost();
  static const MethodPut put = MethodPut();
  static const MethodDelete delete = MethodDelete();
  static const MethodOptions options = MethodOptions();
  static const MethodAll all = MethodAll();
  static const MethodPatch patch = MethodPatch();

  static Method? tryParse(String str) {
    if (str == get.description) {
      return get;
    } else if (str == post.description) {
      return post;
    } else if (str == put.description) {
      return put;
    } else if (str == delete.description) {
      return delete;
    } else if (str == options.description) {
      return options;
    } else if (str == all.description) {
      return all;
    } else if (str == patch.description) {
      return patch;
    } else {
      return null;
    }
  }

  String get description;
}

class MethodGet implements Method {
  const MethodGet();

  @override
  String get description => "GET";
}

class MethodPost implements Method {
  const MethodPost();

  @override
  String get description => "POST";
}

class MethodPut implements Method {
  const MethodPut();

  @override
  String get description => "PUT";
}

class MethodDelete implements Method {
  const MethodDelete();

  @override
  String get description => "DELETE";
}

class MethodOptions implements Method {
  const MethodOptions();

  @override
  String get description => "OPTIONS";
}

class MethodAll implements Method {
  const MethodAll();

  @override
  String get description => "ALL";
}

class MethodPatch implements Method {
  const MethodPatch();

  @override
  String get description => "PATCH";
}
