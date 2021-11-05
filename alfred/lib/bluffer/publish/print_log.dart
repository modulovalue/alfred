import '../base/app.dart';
import '../base/locale.dart';
import 'publish.dart';

/// A [PublishingLog] that exposes log messages using [print].
class PublishingLogPrintImpl implements PublishingLog, PublishingLocaleLog, PublishingAssetLog, PublishingRouteLog {
  final void Function(String) output;

  const PublishingLogPrintImpl({
    required final this.output,
  });

  @override
  void processingLocale({
    required final Locale locale,
  }) =>
      output(
        'Processing ' + locale.localeDebugToString() + '...',
      );

  @override
  void processingAssets({
    required final String assetsDirectory,
  }) =>
      output(
        'Processing Assets ' + assetsDirectory + '...',
      );

  @override
  void processingAssetFile({
    required final String itemFilePath,
    required final String destinationFilePath,
  }) =>
      output(
        "  - '" + itemFilePath + "' into > '" + destinationFilePath + "'",
      );

  @override
  void processingRoute({
    required final UrlWidgetRoute route,
  }) =>
      output(
        '  [Route(' + route.relativeUrl + ")]",
      );

  @override
  void processingRouteFile({
    required final String filePath,
  }) =>
      output(
        "   - '" + filePath + "'",
      );

  @override
  PublishingAssetLog get assetLog => this;

  @override
  PublishingLocaleLog get localeLog => this;

  @override
  PublishingRouteLog get routeLog => this;
}
