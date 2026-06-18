import 'package:catalyst_flutter_app/Features/admin_auth/presentation/controller/admin_auth_controller.dart';
import 'package:get/get.dart';

class AdminAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminAuthController>(() => AdminAuthController());
  }
}
