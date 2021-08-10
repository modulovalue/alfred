import 'dart:io';

import '../app.dart';
import '../locale.dart';
import 'publish.dart';

class PublishingLogPrintImpl implements PublishingLog, PublishingLocaleLog, PublishingAssetLog, PublishingRouteLog {
  final void Function(String) output;

  const PublishingLogPrintImpl(
    final this.output,
  );

  @override
  void processingLocale({
    required final Locale locale,
  }) =>
      output('Processing ' + locale.localeDebugToString() + '...');

  @override
  void processingAssets({
    required final Directory assets,
  }) =>
      output('Processing Assets ' + assets.path + '...');

  @override
  void processingAssetFile({
    required final File item,
    required final File destination,
  }) =>
      output("  - '" + item.path + "' into > '" + destination.path + "'");

  @override
  void processingRoute({
    required final UrlWidgetRoute route,
  }) =>
      output('  [Route(' + route.relativeUrl + ")]");

  @override
  void processingRouteFile({
    required final File file,
  }) =>
      output("   - '" + file.path + "'");

  @override
  PublishingAssetLog get assetLog => this;

  @override
  PublishingLocaleLog get localeLog => this;

  @override
  PublishingRouteLog get routeLog => this;
}
