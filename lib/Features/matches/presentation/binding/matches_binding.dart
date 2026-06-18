import 'package:get/get.dart';

import '../../data/repo/matches_repo_impl.dart';
import '../controller/matches_controller.dart';

class MatchesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MatchesController>(
      () => MatchesController(
        repo: MatchesRepositoryImpl(),
      ),
    );
  }
}
