import 'package:alfred/base.dart';
import 'package:alfred/logging/impl/generalizing/mixin.dart';
import 'package:alfred/middleware/impl/value.dart';
import 'package:logging/logging.dart';

// Use 'logging' package instead of default logger

void main() {
  final app = Alfred(
    LOG: const CustomLogger(),
  );
  // Configure root logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  // Configure routing...
  app.get('/resource', const ValueMiddleware('response'));
  app.listen();
}


// Create custom logWriter and map to logging package
class CustomLogger with AlfredLoggingDelegateGeneralizingMixin {
  const CustomLogger();

  @override
  LogType get logLevel => LogType.info;

  @override
  void log(dynamic Function() messageFn, LogType type) {
    // Create logger for Alfred app
    final logger = Logger('HttpServer');
    switch (type) {
      case LogType.debug:
      // avoid evaluating too much debug messages
        if (logger.level <= Level.FINE) {
          logger.fine(messageFn());
        }
        break;
      case LogType.info:
        logger.info(messageFn());
        break;
      case LogType.warn:
        logger.warning(messageFn());
        break;
      case LogType.error:
        logger.severe(messageFn());
        break;
    }
  }

}
