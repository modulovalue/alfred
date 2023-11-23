import 'dart:io';

import '../base/app.dart';
import '../base/assets.dart';
import '../base/locale.dart';
import '../base/media_query_data.dart';
import '../html/html.dart';
import '../systems/flutter.dart';
import '../widget/widget.dart';

void publishRaw({
  required final PublishAppContext publishContext,
}) {
  final context = BuildContextImpl(
    assets: publishContext.assets,
    styles: {},
  );
  final supportedLocales = publishContext.application.supportedLocales;
  for (final locale in supportedLocales) {
    final absoluteLocaleDirectory = process_locale(
      locale: locale,
      log: publishContext.localeLog,
      directory: publishContext.directory,
    );
    process_assets(
      assetsDirectory: publishContext.assetsDirectory,
      absoluteLocaleDirectory: absoluteLocaleDirectory,
      log: publishContext.assetLog,
    );
    process_routes(
      absoluteLocaleDirectory: absoluteLocaleDirectory,
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
    required this.application,
    required this.serialize,
  });

  @override
  void serializeTo({
    required final String targetPath,
    required final HtmlElement element,
  }) =>
      serialize(targetPath, element);
}

mixin PublishAppContextDefaultMixin implements PublishAppContext {
  @override
  App get application;

  @override
  Assets get assets => const AssetsDefaultPublishImpl();

  @override
  String get assetsDirectory => 'assets';

  @override
  String get directory => 'build';

  @override
  PublishingAssetLog get assetLog => const PublishingLogPrintImpl(
        output: print,
      );

  @override
  PublishingLocaleLog get localeLog => const PublishingLogPrintImpl(
        output: print,
      );

  @override
  PublishingRouteLog get routeLog => const PublishingLogPrintImpl(
        output: print,
      );

  @override
  void serializeTo({
    required final String targetPath,
    required final HtmlElement element,
  });
}

class AssetsDefaultPublishImpl implements Assets {
  static const String dir = 'assets';

  const AssetsDefaultPublishImpl();

  @override
  String get local => dir;
}

abstract class PublishAppContext {
  App get application;

  String get directory;

  String get assetsDirectory;

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
    required final String assetsDirectory,
  });

  void processingAssetFile({
    required final String itemFilePath,
    required final String destinationFilePath,
  });
}

abstract class PublishingRouteLog {
  void processingRoute({
    required final UrlWidgetRoute route,
  });

  void processingRouteFile({
    required final String filePath,
  });
}

abstract class PublishingLocaleLog {
  void processingLocale({
    required final Locale locale,
  });
}

String process_locale({
  required final Locale locale,
  required final PublishingLocaleLog log,
  required final String directory,
}) {
  log.processingLocale(
    locale: locale,
  );
  final localeDirectoryPath = directory + Platform.pathSeparator + locale.toString();
  final dir = Directory(localeDirectoryPath);
  dir.createSync(
    recursive: true,
  );
  return localeDirectoryPath;
}

void process_assets({
  required final String assetsDirectory,
  required final String absoluteLocaleDirectory,
  required final PublishingAssetLog log,
}) {
  if (!Directory(assetsDirectory).existsSync()) {
    // TODO handle directory not found?
    print(" == Asset directory not found " + assetsDirectory + " == " + Uri.base.toString());
  } else {
    log.processingAssets(
      assetsDirectory: assetsDirectory,
    );
    final targetLocaleAssetPath = absoluteLocaleDirectory + Platform.pathSeparator + 'assets';
    final localAssetDestination = Directory(targetLocaleAssetPath);
    localAssetDestination.createSync(
      recursive: true,
    );
    final listedAssetEntities = Directory(assetsDirectory).listSync(
      recursive: true,
    );
    for (final item in listedAssetEntities.toList()) {
      if (item is File) {
        final relativePath = item.path.replaceFirst(
          assetsDirectory + '/',
          '',
        );
        final destinationPath = localAssetDestination.path + Platform.pathSeparator + relativePath;
        final destination = File(destinationPath);
        destination.createSync(
          recursive: true,
        );
        log.processingAssetFile(
          itemFilePath: item.path,
          destinationFilePath: destination.path,
        );
        item.copySync(
          destination.path,
        );
      } else {
        print(" == Listed asset was not a file: " + item.toString() + ", ignoring == ");
      }
    }
  }
}

void process_routes({
  required final App application,
  required final PublishingRouteLog log,
  required final BuildContext context,
  required final Locale locale,
  required final String absoluteLocaleDirectory,
  required final void Function({
    required String targetPath,
    required HtmlElement element,
  }) serializeTo,
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
    final result = localizedApp.render(
      context: context,
    );
    final relativeTargetUrl = route.relativeUrl + '.html';
    final targetPath = absoluteLocaleDirectory + Platform.pathSeparator + relativeTargetUrl;
    log.processingRouteFile(
      filePath: targetPath,
    );
    serializeTo(
      targetPath: targetPath,
      element: result,
    );
  }
}

/// Writes the given element to the given path.
void serialize_to_disk(
  final String path,
  final HtmlElement element,
) {
  final file = File(path);
  final serializedHtml = html_element_to_string(
    element: element,
  );
  file.writeAsStringSync(
    serializedHtml,
  );
}

String single_page({
  required final Widget Function(BuildContext) builder,
  final Assets assets = const AssetsDefaultSinglePageImpl(),
}) =>
    constructSinglePageWithMediaQuery(
      child: Builder(
        builder: (final context) => Theme(
          data: ThemeData.base(context),
          child: builder(context),
        ),
      ),
      assets: assets,
    );

String constructSinglePageWithMediaQuery({
  required final Widget child,
  required final Assets assets,
}) =>
    constructSinglePage(
      child: MediaQuery(
        data: const MediaQueryDataImpl(
          size: MediaSize.medium,
        ),
        child: child,
      ),
      assets: assets,
    );

String constructSinglePage({
  required final Widget child,
  required final Assets assets,
}) {
  return html_element_to_string(
    element: child.render(
      context: BuildContextImpl(
        assets: assets,
        styles: <String, CssStyleDeclaration>{},
      ),
    ),
  );
}

class AssetsDefaultSinglePageImpl implements Assets {
  static const String dir = 'assets';

  const AssetsDefaultSinglePageImpl();

  @override
  String get local => dir;
}

/// A [PublishingLog] that exposes log messages using [print].
class PublishingLogPrintImpl
    implements PublishingLog, PublishingLocaleLog, PublishingAssetLog, PublishingRouteLog {
  final void Function(String) output;

  const PublishingLogPrintImpl({
    required this.output,
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
