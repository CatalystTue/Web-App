import 'package:catalyst_flutter_app/Features/swipe_cards/data/repo/swipe_cards_repo_impl.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/presentation/controller/swipe_cards_controller.dart';
import 'package:get/get.dart';

class SwipeCardsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SwipeCardsController>(
      () => SwipeCardsController(
        repo: SwipeCardsRepositoryImpl(),
      ),
    );
  }
}
