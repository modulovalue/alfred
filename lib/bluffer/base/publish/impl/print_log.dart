import 'dart:io';

import '../../app.dart';
import '../../locale.dart';
import '../interface/publishing_log.dart';

class PublishingLogPrintImpl implements PublishingLog {
  final void Function(String) output;

  const PublishingLogPrintImpl(this.output);

  @override
  void processingLocale(Locale locale) => //
      output('Processing $locale...');

  @override
  void processingAssets(Directory assets) => //
      output('Processing Assets ${assets.path}...');

  @override
  void processingAssetFile(File item, File destination) => //
      output("  - '${item.path}' into > '${destination.path}'");

  @override
  void processingRoute(WidgetRoute route) => //
      output('  [Route(${route.relativeUrl})]');

  @override
  void processingRouteFile(File file) => //
      output("   - '${file.path}");
}
