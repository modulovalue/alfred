import 'dart:io';

import '../../html/html.dart';
import '../../widgets/localization/localizations.dart';
import '../../widgets/widget/impl/build_context.dart';
import '../../widgets/widget/interface/build_context.dart';
import '../app.dart';
import '../assets.dart';
import '../locale.dart';
import 'print_log.dart';

void publishApp({
  required final App root,
  required final void Function(String targetPath, HtmlElement element) serializeTo,
}) {
  const log = PublishingLogPrintImpl(print);
  const assets = AssetsDefaultImpl();
  final dir = Directory('build');
  final assetDir = Directory('example/assets');
  publishRaw(
    application: root,
    serializeTo: serializeTo,
    directory: dir,
    assetsDirectory: assetDir,
    assetLog: log.assetLog,
    localeLog: log.localeLog,
    routeLog: log.routeLog,
    assets: assets,
  );
}

// TODO push this to publishRaw.
// TODO have defaults from publishApp and remove publishApp.
abstract class PublishAppContext {
  App get application;

  Directory get directory;

  Directory get assetsDirectory;

  PublishingLocaleLog get localeLog;

  PublishingAssetLog get assetLog;

  PublishingRouteLog get routeLog;

  Assets get assets;

  void serializeTo(
    final String targetPath,
    final HtmlElement element,
  );
}

abstract class PublishingLog {
  PublishingLocaleLog get localeLog;

  PublishingAssetLog get assetLog;

  PublishingRouteLog get routeLog;
}

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

void publishRaw({
  required final App application,
  required final Directory directory,
  required final Directory assetsDirectory,
  required final PublishingLocaleLog localeLog,
  required final PublishingAssetLog assetLog,
  required final PublishingRouteLog routeLog,
  required final Assets assets,
  required final void Function(String targetPath, HtmlElement element) serializeTo,
}) {
  final context = BuildContextImpl(assets: assets, styles: {});
  final supportedLocales = application.supportedLocales;
  for (final locale in supportedLocales) {
    final localeDirectory = processLocale(
      locale: locale,
      log: localeLog,
      directory: directory,
    );
    processAssets(
      log: assetLog,
      localeDirectory: localeDirectory,
      assets: assetsDirectory,
    );
    processRoutes(
      application: application,
      locale: locale,
      localeDirectory: localeDirectory,
      log: routeLog,
      context: context,
      serializeTo: serializeTo,
    );
  }
}

Directory processLocale({
  required final Locale locale,
  required final PublishingLocaleLog log,
  required final Directory directory,
}) {
  log.processingLocale(locale);
  final localeDirectoryPath = directory.path + Platform.pathSeparator + locale.toString();
  final localeDirectory = Directory(localeDirectoryPath);
  localeDirectory.createSync(recursive: true);
  return localeDirectory;
}

void processAssets({
  required final Directory assets,
  required final Directory localeDirectory,
  required final PublishingAssetLog log,
}) {
  if (assets.existsSync()) {
    log.processingAssets(assets);
    final targetLocaleAssetPath = localeDirectory.path + Platform.pathSeparator + 'assets';
    final localAssetDestination = Directory(targetLocaleAssetPath);
    localAssetDestination.createSync(recursive: true);
    final listedAssetEntities = assets.listSync(recursive: true);
    for (final item in listedAssetEntities.toList()) {
      if (item is File) {
        final relativePath = item.path.replaceFirst(assets.path + '/', '');
        final destinationPath = localAssetDestination.path + Platform.pathSeparator + relativePath;
        final destination = File(destinationPath);
        destination.createSync(recursive: true);
        log.processingAssetFile(item, destination);
        item.copySync(destination.path);
      } else {
        print(" == Listed asset was " + item.toString() + ", ignoring == ");
        // TODO handle other types?
      }
    }
  } else {
    print(" == Asset directory not found " + assets.path + " == ");
    // TODO handle directory not found?
  }
}

void processRoutes({
  required final App application,
  required final PublishingRouteLog log,
  required final BuildContext context,
  required final Locale locale,
  required final Directory localeDirectory,
  required final void Function(String targetPath, HtmlElement element) serializeTo,
}) {
  for (final route in application.routes) {
    log.processingRoute(route);
    final routedApp = application.withCurrentRoute(route.relativeUrl);
    final localizedApp = Localizations(
      locale: locale,
      delegates: application.delegates,
      child: routedApp,
    );
    final result = localizedApp.render(context);
    final absoluteLocalDirectory = localeDirectory.path;
    final relativeTargetUrl = route.relativeUrl + '.html';
    final targetPath = absoluteLocalDirectory + Platform.pathSeparator + relativeTargetUrl;
    final file = File(targetPath);
    log.processingRouteFile(file);
    serializeTo(targetPath, result);
  }
}
