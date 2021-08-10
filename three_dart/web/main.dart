library three_dart.web;

import 'common/common.dart' as common;

/// TODO parted libraries are bad.
/// TODO make automated tests work.
/// TODO split units in lib into separate files.
void main() {
  common.ShellPage("3Dart", false)
    ..addHeader(2, "Examples")
    ..addPar(["[3Dart Craft|./examples/craft/]"])
    ..addPar(["[3Dart Chess|./examples/chess/]"])
    ..addPar(["[Hypersphere|./examples/hypersphere/]"])
    ..addHeader(2, "Tutorials")
    ..addPar(["[Getting Started|./tutorials/tutorial1/]"])
    ..addHeader(6, "Tutorials still need to be written", "")
    ..addPar(["Material Lighting"])
    ..addPar(["Advanced Movers"])
    ..addPar(["Advanced Shapes"])
    ..addPar(["Advanced Techniques"])
    ..addPar(["Scene Compositing"])
    ..addHeader(2, "Tests")
    ..addPar(["[Tests|./tests/]"]);
}
