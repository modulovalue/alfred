library three_dart.web;

import 'common/common.dart';

/// TODO parted libraries are bad.
/// TODO make automated tests work.
/// TODO split units in lib into separate files.
void main() {
  ShellPage("3Dart", false,)
    ..addHeader(2, "Examples")
    ..addPar(["[3Dart Craft|./examples/craft/]"])
    ..addPar(["[3Dart Chess|./examples/chess/]"])
    ..addPar(["[Hypersphere|./examples/hypersphere/]"])
    ..addHeader(2, "Tutorials")
    ..addPar(["[Tutorial 1|./tutorials/tutorial1/]"])
    ..addHeader(2, "Tests")
    ..addPar(["[Tests|./tests/]"]);
}
