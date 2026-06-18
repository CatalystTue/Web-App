import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final reEnterPasswordCtrl = TextEditingController();
  final firstnameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final checkboxValue = RxBool(false);

  RxBool loading = false.obs;
  RxBool isCheckboxChecked = true.obs;

  AuthenticationService authService = AuthenticationService();

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    final RegExp passwordRegex = RegExp(
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return passwordRegex.hasMatch(password);
  }

  bool arePasswordsSame() {
    return passwordCtrl.text == reEnterPasswordCtrl.text;
  }

  bool areFieldsFilled() {
    return emailCtrl.text.isNotEmpty &&
        passwordCtrl.text.isNotEmpty &&
        reEnterPasswordCtrl.text.isNotEmpty &&
        firstnameCtrl.text.isNotEmpty &&
        surnameCtrl.text.isNotEmpty &&
        checkboxValue.value;
  }

  Future<void> registerUser() async {
    if (!areFieldsFilled() ||
        !isValidEmail(emailCtrl.text) ||
        !isStrongPassword(passwordCtrl.text) ||
        !arePasswordsSame()) {
      isCheckboxChecked.value = false;
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please fill all the required fields correctly',
        position: SnackPosition.TOP,
      );
      return;
    }

    isCheckboxChecked.value = true;

    final email = emailCtrl.text;
    final password = passwordCtrl.text;
    final name = '${firstnameCtrl.text} ${surnameCtrl.text}';

    loading.value = true;
    final response = await authService.createUser(
      email: email,
      name: name,
      password: password,
    );

    if (response != null) {
      if (response['detail'] != null &&
          response['detail'].contains('already exists')) {
        AppRepo().showSnackbar(
          label: 'Error',
          text: 'A user with this email already exists.',
          position: SnackPosition.TOP,
        );
      } else {
        print('Registration successful: $response');
        loading.value = false;
        await _showVerificationSentDialog();
        routeToLogin();
        return;
      }
    } else {
      print('Registration failed');
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Registration failed. Please try again.',
        position: SnackPosition.TOP,
      );
    }
    loading.value = false;
  }

  void routeToLogin() {
    Get.offAndToNamed(AppConfig().routes.auth);
  }

  Future<void> _showVerificationSentDialog() async {
    Get.dialog(
      const PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Text('Verify your email'),
          content: const Text(
            'Registration successful. We sent a verification link to your email. '
            'Please check your inbox before logging in.',
          ),
        ),
      ),
      barrierDismissible: false,
    );
    await Future.delayed(const Duration(seconds: 10));
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
