library three_dart.web;

import 'common/common.dart';

/// TODO parted libraries are bad.
/// TODO make automated tests work.
/// TODO split units in lib into separate files.
void main() {
  ShellPage("3Dart", false,)
    ..add_header(2, "Examples")
    ..add_par(["[3Dart Craft|./examples/craft/]"])
    ..add_par(["[3Dart Chess|./examples/chess/]"])
    ..add_par(["[Hypersphere|./examples/hypersphere/]"])
    ..add_header(2, "Tutorials")
    ..add_par(["[Tutorial 1|./tutorials/tutorial1/]"])
    ..add_header(2, "Tests")
    ..add_par(["[Tests|./tests/]"]);
}
