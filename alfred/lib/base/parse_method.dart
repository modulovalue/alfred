import 'method.dart';

Method? parseHttpMethod({
  required final String str,
}) {
  if (str == MethodGet.getString) {
    return Methods.get;
  } else if (str == MethodPost.postString) {
    return Methods.post;
  } else if (str == MethodPut.putString) {
    return Methods.put;
  } else if (str == MethodDelete.deleteString) {
    return Methods.delete;
  } else if (str == MethodOptions.optionsString) {
    return Methods.options;
  } else if (str == MethodAll.allString) {
    return Methods.all;
  } else if (str == MethodPatch.patchString) {
    return Methods.patch;
  } else {
    return null;
  }
}
