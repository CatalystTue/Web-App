import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';

class RecoverAccountController extends GetxController {
  final emailCtrl = TextEditingController();
  final loading = false.obs;
  final AuthenticationService _authService = AuthenticationService();
  Future<void> recoverAccount() async {
    if (loading.value) return;

    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.isEmail) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please enter a valid email address.',
        position: SnackPosition.TOP,
      );
      return;
    }

    loading.value = true;
    await _authService.sendResetPasswordEmail(email);
    loading.value = false;
    AppRepo().showSnackbar(
      label: 'Recovery',
      text:
          'If this email exists, we will send you account recovery instructions.',
      position: SnackPosition.TOP,
    );
    Get.offAndToNamed(AppConfig().routes.auth);
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    super.onClose();
  }
}
