import '../interface/build_context.dart';
import 'widget_mixin.dart';

String resolveUrl({
  required final BuildContext context,
  required final String url,
  required final String pathSeparator,
}) {
  if (url.startsWith('asset://')) {
    return context.assets.local + pathSeparator + url.replaceAll('asset://', '');
  } else if (url.startsWith('#')) {
    final media = MediaQuery.of(context);
    return url + '-' + media!.size.index.toString();
  } else {
    return url;
  }
}
