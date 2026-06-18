import 'package:catalyst_flutter_app/Core/Constants/config.dart';
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

  AuthController({
    required this.repo,
  });

  Future<void> loginUser() async {
    if (loading.value) return;

    final username = emailCtrl.text;
    final password = passwordCtrl.text;

    print('Attempting to log in with username: $username, password: $password');

    if (username.isNotEmpty && password.isNotEmpty && username.isEmail) {
      loading.value = true;

      final response = await repo.login(username: username, password: password);

      if (response != null) {
        await AppRepo().loginUser(response);
        Get.offAllNamed(AppConfig().routes.initform);
      } else {
        loading.value = false;
        print('Login failed');
      }
    }
  }

  void routeToRegisterScreen() {
    Get.offAndToNamed(AppConfig().routes.register);
  }

  void routeToRecoverAccountScreen() {
    Get.toNamed(AppConfig().routes.recoverAccount);
  }
}
