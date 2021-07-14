import 'dart:io';

import '../../app.dart';
import '../../locale.dart';

abstract class PublishingAssetLog {
  void processingAssets(
    final Directory assets,
  );

  void processingAssetFile(
    final File item,
    final File destination,
  );
}

abstract class PublishingRouteLog {
  void processingRoute(
    final UrlWidgetRoute route,
  );

  void processingRouteFile(
    final File file,
  );
}

abstract class PublishingLocaleLog {
  void processingLocale(
    final Locale locale,
  );
}

abstract class PublishingLog
    implements //
        PublishingLocaleLog,
        PublishingAssetLog,
        PublishingRouteLog {}
