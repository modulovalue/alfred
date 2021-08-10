// @dart = 2.9
import 'dart:html' as html;

void main() {
  final html.DivElement elem = html.DivElement();
  addExamples(elem);
  final html.DivElement scrollPage = html.DivElement();
  scrollPage.className = "scroll_page";
  final html.DivElement pageCenter = html.DivElement();
  pageCenter.className = "page_center";
  scrollPage.append(pageCenter);
  final html.DivElement elemContainer = html.DivElement();
  pageCenter.append(elemContainer);
  elemContainer.append(elem);
  final html.DivElement endPage = html.DivElement();
  endPage.className = "end_page";
  elemContainer.append(endPage);
  html.document.title = "Examples";
  final html.BodyElement body = html.document.body;
  body.append(scrollPage);
}

void addExamples(html.DivElement elem) {
  addExample(elem, "pointsLines");
  addExample(elem, "regions");
}

void addExample(
  final html.Element elem,
  final String expName,
) {
  final html.ImageElement img = html.ImageElement()
    ..alt = expName
    // ignore: unsafe_html
    ..src = "./$expName/tn.png";
  final html.AnchorElement a = html.AnchorElement()
    // ignore: unsafe_html
    ..href = "./$expName/"
    ..children.add(img);
  final html.DivElement innerBox = html.DivElement()
    ..className = "exp-link"
    ..children.add(a);
  final html.DivElement outterBox = html.DivElement()
    ..className = "exp-box"
    ..children.add(innerBox);
  elem.children.add(outterBox);
}
