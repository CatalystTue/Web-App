import 'package:catalyst_flutter_app/Features/initform/presentation/controller/initform_controller.dart';
import 'package:get/get.dart';

class InitFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InitFormController>(() => InitFormController());
  }
}
