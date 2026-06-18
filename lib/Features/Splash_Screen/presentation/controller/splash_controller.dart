import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/splash_screen/domain/splash_repository.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class SplashController extends GetxController {
  late SplashRepository repo;

  SplashController({
    required this.repo,
  });

  Future<void> checkUserStatusFromLocalCache() async {
    await Future.delayed(const Duration(seconds: 2));

    Get.offNamed(AppConfig().routes.register);
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserStatusFromLocalCache();
    });
  }
}
