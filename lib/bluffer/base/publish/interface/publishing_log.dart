import 'dart:io';

import '../../app.dart';
import '../../locale.dart';

abstract class PublishingAssetLog {
  void processingAssets(Directory assets);

  void processingAssetFile(File item, File destination);
}

abstract class PublishingRouteLog {
  void processingRoute(WidgetRoute route);

  void processingRouteFile(File file);
}

abstract class PublishingLocaleLog {
  void processingLocale(Locale locale);
}

abstract class PublishingLog implements PublishingLocaleLog, PublishingAssetLog, PublishingRouteLog {}
