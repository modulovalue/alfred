import 'dart:html';

import '../common/common.dart';

void main() {
  final elem = DivElement();
  // Add all tests in the format: addTest(elem, "test000");
  for (int i = 0; i <= 49; i++) {
    addTest(elem, "test" + "$i".padLeft(3, '0'));
  }
  ShellPage("3Dart Tests")
    ..addElem(elem)
    ..add_par(["«[Back to Home|../]"]);
}

void addTest(
  final Element elem,
  final String testName,
) {
  final img = ImageElement()
    ..alt = "$testName"
    // ignore: unsafe_html
    ..src = "./$testName/test.png";
  final a = AnchorElement()
    // ignore: unsafe_html
    ..href = "./$testName/"
    ..children.add(img);
  final innerBox = DivElement()
    ..className = "test-link"
    ..children.add(a);
  final outterBox = DivElement()
    ..className = "test-box"
    ..children.add(innerBox);
  elem.children.add(outterBox);
}
