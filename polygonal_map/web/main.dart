import 'dart:html' as html;

void main() {
  final elem = html.DivElement();
  addExamples(elem);
  final scrollPage = html.DivElement();
  scrollPage.className = "scroll_page";
  final pageCenter = html.DivElement();
  pageCenter.className = "page_center";
  scrollPage.append(pageCenter);
  final elemContainer = html.DivElement();
  pageCenter.append(elemContainer);
  elemContainer.append(elem);
  final endPage = html.DivElement();
  endPage.className = "end_page";
  elemContainer.append(endPage);
  html.document.title = "Examples";
  final body = html.document.body!;
  body.append(scrollPage);
}

void addExamples(
  final html.DivElement elem,
) {
  addExample(elem, "pointsLines");
  addExample(elem, "regions");
}

void addExample(
  final html.Element elem,
  final String expName,
) {
  final img = html.ImageElement()
    ..alt = expName
    // ignore: unsafe_html
    ..src = "./" + expName + "/tn.png";
  final a = html.AnchorElement()
    // ignore: unsafe_html
    ..href = "./" + expName + "/"
    ..children.add(img);
  final innerBox = html.DivElement()
    ..className = "exp-link"
    ..children.add(a);
  final outterBox = html.DivElement()
    ..className = "exp-box"
    ..children.add(innerBox);
  elem.children.add(outterBox);
}
