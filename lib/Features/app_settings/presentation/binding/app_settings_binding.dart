import 'package:get/get.dart';

import '../../data/repo/app_settings_repo_impl.dart';
import '../controller/app_settings_controller.dart';

class AppSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppSettingsController>(
      () => AppSettingsController(
        repo: AppSettingsRepositoryImpl(),
      ),
    );
  }
}
