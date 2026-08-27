import 'dart:convert';

import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/cookie_storage.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminAuthController extends GetxController {
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final loading = false.obs;
  final AuthenticationService _authService = AuthenticationService();

  Future<void> loginAdmin() async {
    if (loading.value) return;

    final username = usernameCtrl.text.trim();
    final password = passwordCtrl.text;
    if (username.isEmpty || password.isEmpty) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please enter a username and password.',
        position: SnackPosition.TOP,
      );
      return;
    }

    loading.value = true;
    final response = await _authService.adminLogin({
      'username': username,
      'password': password,
    });
    loading.value = false;

    if (response == null) {
      return;
    }

    final token =
        response['access_token']?.toString() ?? response['token']?.toString();
    if (token == null || token.isEmpty) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Admin login failed.',
        position: SnackPosition.TOP,
      );
      return;
    }
    CookieStorage.saveToken(token);
    final name = response['name']?.toString();
    CookieStorage.saveAdminName(
      (name != null && name.isNotEmpty) ? name : username,
    );
    final expiresAt = _extractExpiryFromJwt(token);
    if (expiresAt != null) {
      CookieStorage.saveAdminExpiresAt(expiresAt.toIso8601String());
    }

    final normalizedResponse = Map<String, dynamic>.from(response);
    normalizedResponse['token'] ??= token;

    await AppRepo().loginUser(normalizedResponse);
    Get.offAllNamed(AppConfig().routes.adminWelcome);
  }

  DateTime? _extractExpiryFromJwt(String? jwt) {
    if (jwt == null || jwt.isEmpty) return null;
    final parts = jwt.split('.');
    if (parts.length < 2) return null;

    try {
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
      final exp = payloadMap['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      }
      if (exp is String) {
        final expInt = int.tryParse(exp);
        if (expInt != null) {
          return DateTime.fromMillisecondsSinceEpoch(expInt * 1000,
              isUtc: true);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
