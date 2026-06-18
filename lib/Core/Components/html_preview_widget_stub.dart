import 'package:flutter/material.dart';

Widget createHtmlPreview(String htmlContent, {Key? key}) {
  return SingleChildScrollView(
    key: key,
    padding: const EdgeInsets.all(20),
    child: SelectableText(htmlContent),
  );
}
