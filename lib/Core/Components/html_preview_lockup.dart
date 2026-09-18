import 'dart:convert';

import 'package:flutter/services.dart';

const mailLockupAssetPath = 'assets/png/catalyst_logo.png';

const mailLockupHotlinkUrls = [
  'https://app.catalyst-app.org/assets/assets/png/catalyst_logo.png',
  'https://app.catalyst-app.org/assets/png/catalyst_logo.png',
];

String pngDataUri(List<int> bytes) =>
    'data:image/png;base64,${base64Encode(bytes)}';

String htmlWithBundledMailLockup(String html, String lockupSrc) {
  var result = html;
  for (final url in mailLockupHotlinkUrls) {
    result = result.replaceAll(url, lockupSrc);
  }
  return result;
}

Future<String> htmlPreviewSrcdoc(String htmlContent) async {
  try {
    final data = await rootBundle.load(mailLockupAssetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    return htmlWithBundledMailLockup(htmlContent, pngDataUri(bytes));
  } on Object {
    return htmlContent;
  }
}
