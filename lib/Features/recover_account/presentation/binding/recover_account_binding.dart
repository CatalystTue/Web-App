import 'package:catalyst_flutter_app/Features/recover_account/presentation/controller/recover_account_controller.dart';
import 'package:get/get.dart';

class RecoverAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecoverAccountController>(() => RecoverAccountController());
  }
}
