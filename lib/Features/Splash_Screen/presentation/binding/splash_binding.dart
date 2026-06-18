import 'package:catalyst_flutter_app/Features/splash_screen/data/repository/splash_repository_impl.dart';
import 'package:catalyst_flutter_app/Features/splash_screen/presentation/controller/splash_controller.dart';
import 'package:get/get.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        repo: SplashRepositoryImpl(),
      ),
    );
  }
}
