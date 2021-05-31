import '../alfred/interface/alfred.dart';

/// Print out the registered routes to the console.
///
/// Helpful to see whats available.
/// TODO consider giving Method a visitor instead of a matcher.
void printRoutes(Alfred alfred) {
  for (final route in alfred.routes) {
    print(
      route.route +
          ' - ' +
          route.method.matchBuiltinMethods(
            get: (_) => '\x1B[33m' + _.description + '\x1B[0m',
            post: (_) => '\x1B[31m' + _.description + '\x1B[0m',
            put: (_) => '\x1B[32m' + _.description + '\x1B[0m',
            delete: (_) => '\x1B[34m' + _.description + '\x1B[0m',
            options: (_) => '\x1B[36m' + _.description + '\x1B[0m',
            all: (_) => '\x1B[37m' + _.description + '\x1B[0m',
            patch: (_) => '\x1B[35m' + _.description + '\x1B[0m',
          ) +
          ' String',
    );
  }
}
