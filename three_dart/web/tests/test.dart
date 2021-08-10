library three_dart.tests;

import 'dart:html' as html;

import '../common/common.dart' as common;

void main() {
  final html.DivElement elem = html.DivElement();
  // Add all tests in the format: addTest(elem, "test000");
  for (int i = 0; i <= 49; i++) {
    addTest(elem, "test"+"$i".padLeft(3, '0'));
  }
  common.ShellPage("3Dart Tests")
    ..addElem(elem)
    ..addPar(["«[Back to Home|../]"]);
}

void addTest(html.Element elem, String testName) {
  final html.ImageElement img = html.ImageElement()
    ..alt = "$testName"
    // ignore: unsafe_html
    ..src = "./$testName/test.png";
  final html.AnchorElement a = html.AnchorElement()
    // ignore: unsafe_html
    ..href = "./$testName/"
    ..children.add(img);
  final html.DivElement innerBox = html.DivElement()
    ..className = "test-link"
    ..children.add(a);
  final html.DivElement outterBox = html.DivElement()
    ..className = "test-box"
    ..children.add(innerBox);
  elem.children.add(outterBox);
}
