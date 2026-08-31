import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/legal_documents.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterController extends GetxController {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final reEnterPasswordCtrl = TextEditingController();
  final checkboxValue = RxBool(false);

  RxBool loading = false.obs;
  RxBool isCheckboxChecked = true.obs;

  AuthenticationService authService = AuthenticationService();

  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  bool passwordHasMinimumLength(String password) => password.length >= 8;

  bool passwordHasLowercaseLetter(String password) =>
      RegExp(r'[a-z]').hasMatch(password);

  bool passwordHasUppercaseLetter(String password) =>
      RegExp(r'[A-Z]').hasMatch(password);

  bool passwordHasNumber(String password) => RegExp(r'\d').hasMatch(password);

  bool passwordHasAllowedSymbol(String password) =>
      RegExp(r'[@$!%*?&]').hasMatch(password);

  bool passwordUsesOnlyAllowedCharacters(String password) =>
      password.isNotEmpty && RegExp(r'^[A-Za-z\d@$!%*?&]+$').hasMatch(password);

  bool isStrongPassword(String password) {
    return passwordHasMinimumLength(password) &&
        passwordHasLowercaseLetter(password) &&
        passwordHasUppercaseLetter(password) &&
        passwordHasNumber(password) &&
        passwordHasAllowedSymbol(password) &&
        passwordUsesOnlyAllowedCharacters(password);
  }

  bool arePasswordsSame() {
    return passwordCtrl.text == reEnterPasswordCtrl.text;
  }

  bool areFieldsFilled() {
    return emailCtrl.text.isNotEmpty &&
        passwordCtrl.text.isNotEmpty &&
        reEnterPasswordCtrl.text.isNotEmpty &&
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

    loading.value = true;
    final response = await authService.createUser(
      email: email,
      password: password,
    );

    if (response != null) {
      if (response['detail'] != null) {
        // ServicesHelper already displayed the backend error.
      } else {
        loading.value = false;
        await _showVerificationSentDialog();
        routeToLogin();
        return;
      }
    } else {
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

  void showTermsOfUse() {
    LegalDocuments.openTermsOfUse();
  }

  void showPrivacyNotice() {
    LegalDocuments.openPrivacyNotice();
  }

  Future<void> _showVerificationSentDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Verify your email'),
        content: const Text(
          'If this email exists, we will send you a verification link. '
          'Check your inbox and spam folder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
