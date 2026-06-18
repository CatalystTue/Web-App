import 'package:get/get.dart';

import '../../data/repo/idea_card_repo_impl.dart';
import '../controller/idea_card_controller.dart';

class IdeaCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IdeaCardController>(
      () => IdeaCardController(
        repo: IdeaCardRepositoryImpl(),
      ),
    );
  }
}
