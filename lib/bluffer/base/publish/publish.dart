import 'dart:io';

import '../../html/html.dart';
import '../../widgets/localization/localizations.dart';
import '../../widgets/widget/impl/build_context.dart';
import '../../widgets/widget/interface/build_context.dart';
import '../app.dart';
import '../assets.dart';
import '../locale.dart';
import 'print_log.dart';

void publishRaw({
  required final PublishAppContext publishContext,
}) {
  final context = BuildContextImpl(
    assets: publishContext.assets,
    styles: {},
  );
  final supportedLocales = publishContext.application.supportedLocales;
  for (final locale in supportedLocales) {
    final localeDirectory = processLocale(
      locale: locale,
      log: publishContext.localeLog,
      directory: publishContext.directory,
    );
    processAssets(
      localeDirectory: localeDirectory,
      log: publishContext.assetLog,
      assets: publishContext.assetsDirectory,
    );
    processRoutes(
      localeDirectory: localeDirectory,
      application: publishContext.application,
      locale: locale,
      log: publishContext.routeLog,
      context: context,
      serializeTo: publishContext.serializeTo,
    );
  }
}

class PublishAppContextDefault with PublishAppContextDefaultMixin {
  final void Function(String targetPath, HtmlElement element) serialize;
  @override
  final App application;

  const PublishAppContextDefault({
    required final this.application,
    required final this.serialize,
  });

  @override
  void serializeTo({
    required String targetPath,
    required HtmlElement element,
  }) =>
      serialize(targetPath, element);
}

mixin PublishAppContextDefaultMixin implements PublishAppContext {
  @override
  App get application;

  @override
  Assets get assets => const AssetsDefaultImpl();

  @override
  Directory get assetsDirectory => Directory('assets');

  @override
  Directory get directory => Directory('build');

  @override
  PublishingAssetLog get assetLog => const PublishingLogPrintImpl(print);

  @override
  PublishingLocaleLog get localeLog => const PublishingLogPrintImpl(print);

  @override
  PublishingRouteLog get routeLog => const PublishingLogPrintImpl(print);

  @override
  void serializeTo({
    required String targetPath,
    required HtmlElement element,
  });
}

abstract class PublishAppContext {
  App get application;

  Directory get directory;

  Directory get assetsDirectory;

  PublishingLocaleLog get localeLog;

  PublishingAssetLog get assetLog;

  PublishingRouteLog get routeLog;

  Assets get assets;

  void serializeTo({
    required final String targetPath,
    required final HtmlElement element,
  });
}

abstract class PublishingLog {
  PublishingLocaleLog get localeLog;

  PublishingAssetLog get assetLog;

  PublishingRouteLog get routeLog;
}

abstract class PublishingAssetLog {
  void processingAssets({
    required final Directory assets,
  });

  void processingAssetFile({
    required final File item,
    required final File destination,
  });
}

abstract class PublishingRouteLog {
  void processingRoute({
    required final UrlWidgetRoute route,
  });

  void processingRouteFile({
    required final File file,
  });
}

abstract class PublishingLocaleLog {
  void processingLocale({
    required final Locale locale,
  });
}

Directory processLocale({
  required final Locale locale,
  required final PublishingLocaleLog log,
  required final Directory directory,
}) {
  log.processingLocale(
    locale: locale,
  );
  final localeDirectoryPath = directory.path + Platform.pathSeparator + locale.toString();
  final localeDirectory = Directory(localeDirectoryPath);
  localeDirectory.createSync(
    recursive: true,
  );
  return localeDirectory;
}

void processAssets({
  required final Directory assets,
  required final Directory localeDirectory,
  required final PublishingAssetLog log,
}) {
  if (assets.existsSync()) {
    log.processingAssets(
      assets: assets,
    );
    final targetLocaleAssetPath = localeDirectory.path + Platform.pathSeparator + 'assets';
    final localAssetDestination = Directory(targetLocaleAssetPath);
    localAssetDestination.createSync(
      recursive: true,
    );
    final listedAssetEntities = assets.listSync(
      recursive: true,
    );
    for (final item in listedAssetEntities.toList()) {
      if (item is File) {
        final relativePath = item.path.replaceFirst(
          assets.path + '/',
          '',
        );
        final destinationPath = localAssetDestination.path + Platform.pathSeparator + relativePath;
        final destination = File(destinationPath);
        destination.createSync(
          recursive: true,
        );
        log.processingAssetFile(
          item: item,
          destination: destination,
        );
        item.copySync(
          destination.path,
        );
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
  required final void Function({
    required String targetPath,
    required HtmlElement element,
  })
      serializeTo,
}) {
  for (final route in application.routes) {
    log.processingRoute(
      route: route,
    );
    final routedApp = application.withCurrentRoute(
      route.relativeUrl,
    );
    final localizedApp = Localizations(
      locale: locale,
      delegates: application.delegates,
      child: routedApp,
    );
    final result = localizedApp.renderElement(
      context: context,
    );
    final absoluteLocalDirectory = localeDirectory.path;
    final relativeTargetUrl = route.relativeUrl + '.html';
    final targetPath = absoluteLocalDirectory + Platform.pathSeparator + relativeTargetUrl;
    final file = File(targetPath);
    log.processingRouteFile(
      file: file,
    );
    serializeTo(
      targetPath: targetPath,
      element: result,
    );
  }
}
