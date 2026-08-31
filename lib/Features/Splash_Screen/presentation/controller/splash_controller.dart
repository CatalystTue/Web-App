import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class SplashController extends GetxController {
  Future<void> checkUserStatusFromLocalCache() async {
    if (!AppRepo().hasAccessToken) {
      Get.offAllNamed(AppConfig().routes.auth);
      return;
    }

    if (AppRepo().isAdminSession) {
      Get.offAllNamed(AppConfig().routes.adminWelcome);
      return;
    }

    final onboardingDone = await AppRepo().refreshOnboardingStatus();
    Get.offAllNamed(
      onboardingDone
          ? AppConfig().routes.base
          : AppConfig().routes.initform,
    );
  }

  @override
  void onInit() {
    super.onInit();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserStatusFromLocalCache();
    });
  }
}
