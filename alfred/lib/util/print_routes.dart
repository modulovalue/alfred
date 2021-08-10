import '../alfred/interface/alfred.dart';

/// Print out the registered routes to the console.
///
/// Helpful to see whats available.
/// TODO consider giving Method a visitor instead of a matcher.
void printRoutes(
  final Alfred alfred,
) {
  for (final route in alfred.routes) {
    print(
      route.route +
          ' - ' +
          route.method.matchBuiltinMethods(
            get: (final _) => '\x1B[33m' + _.description + '\x1B[0m',
            post: (final _) => '\x1B[31m' + _.description + '\x1B[0m',
            put: (final _) => '\x1B[32m' + _.description + '\x1B[0m',
            delete: (final _) => '\x1B[34m' + _.description + '\x1B[0m',
            options: (final _) => '\x1B[36m' + _.description + '\x1B[0m',
            all: (final _) => '\x1B[37m' + _.description + '\x1B[0m',
            patch: (final _) => '\x1B[35m' + _.description + '\x1B[0m',
          ) +
          ' String',
    );
  }
}
