import 'package:get/get.dart';

import '../../data/repo/create_new_idea_card_repo_impl.dart';
import '../controller/create_new_idea_card_controller.dart';

class CreateNewIdeaCardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateNewIdeaCardController>(
      () => CreateNewIdeaCardController(
        repo: CreateNewIdeaCardRepositoryImpl(),
      ),
    );
  }
}
