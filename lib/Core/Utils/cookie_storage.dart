import 'cookie_storage_stub.dart'
    if (dart.library.html) 'cookie_storage_web.dart';

class CookieStorage {
  CookieStorage._();

  static void saveToken(String token, {int maxAgeSeconds = 604800}) {
    saveCookie(
      'admin_token',
      token,
      maxAgeSeconds: maxAgeSeconds,
      path: '/',
    );
  }

  static String? readToken() {
    return readCookie('admin_token');
  }

  static void saveAdminName(String name, {int maxAgeSeconds = 604800}) {
    saveCookie(
      'admin_name',
      name,
      maxAgeSeconds: maxAgeSeconds,
      path: '/',
    );
  }

  static String? readAdminName() {
    return readCookie('admin_name');
  }

  static void saveAdminExpiresAt(String expiresAtIso,
      {int maxAgeSeconds = 604800}) {
    saveCookie(
      'admin_expires_at',
      expiresAtIso,
      maxAgeSeconds: maxAgeSeconds,
      path: '/',
    );
  }

  static String? readAdminExpiresAt() {
    return readCookie('admin_expires_at');
  }
}
