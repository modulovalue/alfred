pub run test --coverage=./coverage
format_coverage --packages=coverage_packages -i ./coverage -l -o ./coverage.lcov
rm -rf coverage;
mkdir coverage;
remove_from_coverage -f coverage.lcov -r _test.dart
genhtml coverage.lcov -o ./coverage
open coverage/index.html