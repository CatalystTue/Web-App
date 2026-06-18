import 'dart:html' as html;

void saveCookie(
  String key,
  String value, {
  int maxAgeSeconds = 604800,
  String path = '/',
}) {
  final encodedValue = Uri.encodeComponent(value);
  html.document.cookie =
      '$key=$encodedValue; Max-Age=$maxAgeSeconds; Path=$path; SameSite=Lax';
}

String? readCookie(String key) {
  final allCookies = html.document.cookie;
  if (allCookies == null || allCookies.isEmpty) return null;

  final cookies = allCookies.split(';');
  for (final cookie in cookies) {
    final parts = cookie.trim().split('=');
    if (parts.isEmpty) continue;
    final cookieKey = parts.first;
    if (cookieKey != key) continue;

    final cookieValue = parts.length > 1 ? parts.sublist(1).join('=') : '';
    return Uri.decodeComponent(cookieValue);
  }
  return null;
}
