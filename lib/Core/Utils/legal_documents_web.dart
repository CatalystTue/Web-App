import 'dart:html' as html;

void openLegalDocument(String relativePath) {
  final baseUri = html.document.baseUri;
  final url = baseUri != null
      ? Uri.parse(baseUri).resolve(relativePath).toString()
      : '/$relativePath';
  html.window.open(url, '_blank');
}
