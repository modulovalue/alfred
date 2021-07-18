import 'package:alfred/alfred/impl/alfred.dart';
import 'package:alfred/alfred/impl/logging/log_type.dart';
import 'package:alfred/alfred/impl/logging/mixin.dart';
import 'package:alfred/alfred/impl/middleware/string.dart';
import 'package:logging/logging.dart';

// Use 'logging' package instead of default logger

Future<void> main() async {
  final app = AlfredImpl();
  app.get('/resource', const ServeString('response'));
  await app.build(log: CustomLogger());
}

// Create custom logWriter and map to logging package
class CustomLogger with AlfredLoggingDelegateGeneralizingMixin {
  CustomLogger() {
    // Configure root logger
    // defaults to Level.INFO
    Logger.root
      ..level = Level.ALL
      ..onRecord.listen(
        (record) => print(
          record.level.name + ': ' + record.time.toString() + ': ' + record.message,
        ),
      );
  }

  @override
  LogType get logLevel => LogType.info;

  // Create logger for Alfred app.
  final Logger logger = Logger('Alfred');

  @override
  void log(
    final dynamic Function() messageFn,
    final LogType type,
  ) {
    switch (type) {
      case LogType.debug:
        // avoid evaluating too many debug messages.
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
