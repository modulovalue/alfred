import 'package:alfred/alfred.dart';
import 'package:logging/logging.dart';

// Use 'logging' package instead of default logger

void main() {
  final app = Alfred();

  // Configure root logger
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Create logger for Alfred app
  final log = Logger('HttpServer');

  // Create custom logWriter and map to logging package
  app.logWriter = (messageFn, type) {
    switch (type) {
      case LogType.debug:
        // avoid evaluating too much debug messages
        if (log.level <= Level.FINE) {
          log.fine(messageFn());
        }
        break;
      case LogType.info:
        log.info(messageFn());
        break;
      case LogType.warn:
        log.warning(messageFn());
        break;
      case LogType.error:
        log.severe(messageFn());
        break;
    }
  };

  // Configure routing...
  app.get('/resource', (req, res) => 'response');

  app.listen();
}
