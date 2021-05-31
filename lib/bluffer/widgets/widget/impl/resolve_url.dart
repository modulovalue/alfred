import 'dart:io';

import '../interface/build_context.dart';
import 'widget_mixin.dart';

String resolveUrl(BuildContext context, String url) {
  if (url.startsWith('asset://')) {
    return context.assets.local.path + Platform.pathSeparator + url.replaceAll('asset://', '');
  } else if (url.startsWith('#')) {
    final media = MediaQuery.of(context);
    return url + '-${media!.size.index}';
  } else {
    return url;
  }
}
