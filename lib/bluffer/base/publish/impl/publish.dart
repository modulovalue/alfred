import 'dart:io';

import '../../../html/interface/html.dart';
import '../../../widgets/localization/localizations.dart';
import '../../../widgets/widget/impl/build_context.dart';
import '../../../widgets/widget/interface/build_context.dart';
import '../../../widgets/widget/interface/widget.dart';
import '../../app.dart';
import '../../assets.dart';
import '../../locale.dart';
import '../interface/publishing_log.dart';
import 'print_log.dart';

void publishApp({
  required Widget root,
  required void Function(String targetPath, HtmlElement2 element) serializeTo,
  Directory? directory,
  Directory? assets,
}) =>
    publishRaw(
      application: root is Application ? root : defaultApplication(child: root),
      directory: directory ?? Directory('build'),
      assetsDirectory: assets ?? Directory('example/assets'),
      log: const PublishingLogPrintImpl(print),
      assets: const AssetsDefaultImpl(),
      serializeTo: serializeTo,
    );

Application defaultApplication({
  required Widget child,
}) =>
    Application(
      routes: [
        WidgetRoute(
          title: (context) => 'Index',
          builder: (context) => child,
          relativeUrl: 'index',
        ),
      ],
    );

void publishRaw({
  required Application application,
  required Directory directory,
  required Directory assetsDirectory,
  required PublishingLog log,
  required Assets assets,
  required void Function(String targetPath, HtmlElement2 element) serializeTo,
}) {
  final context = BuildContextImpl(assets: assets);
  for (final locale in application.supportedLocales) {
    log.processingLocale(locale);
    final localeDirectoryPath = directory.path + Platform.pathSeparator + locale.toString();
    final localeDirectory = Directory(localeDirectoryPath);
    localeDirectory.createSync(recursive: true);
    processAssets(
      log: log,
      localeDirectory: localeDirectory,
      assets: assetsDirectory,
    );
    processRoutes(
      application: application,
      locale: locale,
      localeDirectory: localeDirectory,
      log: log,
      context: context,
      serializeTo: serializeTo,
    );
  }
}

void processAssets({
  required Directory assets,
  required Directory localeDirectory,
  required PublishingAssetLog log,
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
        print(" == Listed asset was $item, ignoring == ");
        // TODO handle other types?
      }
    }
  } else {
    print(" == Asset directory not found ${assets.path} == ");
    // TODO handle directory not found?
  }
}

void processRoutes({
  required Application application,
  required PublishingRouteLog log,
  required BuildContext context,
  required Locale locale,
  required Directory localeDirectory,
  required void Function(String targetPath, HtmlElement2 element) serializeTo,
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
