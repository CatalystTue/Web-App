import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/auth_repo.dart';

class AuthController extends GetxController {
  late AuthRepository repo;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final isPassword = true.obs;

  RxBool loading = false.obs;
  RxBool showResend = false.obs;
  RxBool resending = false.obs;

  AuthController({
    required this.repo,
  });

  bool _hasAccessToken(Map<String, dynamic>? response) {
    final token = response?['access_token']?.toString() ??
        response?['token']?.toString();
    return token != null && token.isNotEmpty;
  }

  Future<void> loginUser() async {
    if (loading.value) return;

    final username = emailCtrl.text.trim();
    final password = passwordCtrl.text;

    if (username.isEmpty || password.isEmpty || !username.isEmail) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Enter a valid email and password.',
        position: SnackPosition.TOP,
      );
      return;
    }

    loading.value = true;
    showResend.value = false;

    final response = await repo.login(username: username, password: password);

    if (_hasAccessToken(response)) {
      await AppRepo().loginUser(response!);
      final onboardingDone = await AppRepo().refreshOnboardingStatus();
      Get.offAllNamed(
        onboardingDone
            ? AppConfig().routes.base
            : AppConfig().routes.initform,
      );
      return;
    }

    if (response?['detail']?.toString() == 'Email not verified') {
      showResend.value = true;
    }

    loading.value = false;
  }

  Future<void> resendVerification() async {
    if (resending.value) return;

    final email = emailCtrl.text.trim();
    if (email.isEmpty || !email.isEmail) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Enter a valid email to resend verification.',
        position: SnackPosition.TOP,
      );
      return;
    }

    resending.value = true;
    final response =
        await AuthenticationService().resendVerificationEmail(email);
    resending.value = false;

    if (response != null && !response.containsKey('detail')) {
      AppRepo().showSnackbar(
        label: 'Sent',
        text:
            'If this email exists, we will send you a verification link.',
        position: SnackPosition.TOP,
      );
    }
  }

  void routeToRegisterScreen() {
    Get.offAndToNamed(AppConfig().routes.register);
  }

  void routeToRecoverAccountScreen() {
    Get.toNamed(AppConfig().routes.recoverAccount);
  }
}
