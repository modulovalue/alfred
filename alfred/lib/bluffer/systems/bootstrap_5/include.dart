import '../../base/app.dart';
import '../../html/html.dart';

const AppIncludes bootstrapIncludes = AppIncludesImpl(
  stylesheetLinks: [
    // TODO rel crossorigin integrity https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
    "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css",
  ],
  scriptLinks: [
    HtmlElementScriptImpl(
      async: null,
      defer: null,
      className: null,
      content: null,
      id: null,
      // TODO rel crossorigin integrity https://www.tutorialrepublic.com/twitter-bootstrap-tutorial/bootstrap-get-started.php
      src: "https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js",
      childNodes: [],
    )
  ],
);
