import '../interface/method.dart';
import 'methods.dart';

Method? tryParseMethod(String str) {
  if (str == Methods.get.description) {
    return Methods.get;
  } else if (str == Methods.post.description) {
    return Methods.post;
  } else if (str == Methods.put.description) {
    return Methods.put;
  } else if (str == Methods.delete.description) {
    return Methods.delete;
  } else if (str == Methods.options.description) {
    return Methods.options;
  } else if (str == Methods.all.description) {
    return Methods.all;
  } else if (str == Methods.patch.description) {
    return Methods.patch;
  } else {
    return null;
  }
}
