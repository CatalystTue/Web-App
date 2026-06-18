import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:get/get.dart';

import '../../domain/app_settings_repo.dart';

class AppSettingsController extends GetxController {
  late AppSettingsRepository repo;

  RxBool isNotificationOn = false.obs;

  AppSettingsController({
    required this.repo,
  });

  Future<void> logoutUser() async {
    await AppRepo().logoutUser();
  }
}
