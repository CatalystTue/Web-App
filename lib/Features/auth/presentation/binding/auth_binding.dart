import 'package:get/get.dart';

import '../../data/repo/auth_repo_impl.dart';
import '../controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        repo: AuthRepositoryImpl(),
      ),
    );
  }
}
