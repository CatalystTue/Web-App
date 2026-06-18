import 'package:flutter/widgets.dart';

import 'html_preview_widget_stub.dart'
    if (dart.library.html) 'html_preview_widget_web.dart';

Widget buildHtmlPreview(String htmlContent, {Key? key}) {
  return createHtmlPreview(htmlContent, key: key);
}
