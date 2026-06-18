import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Features/idea_card/domain/idea_card_repo.dart';
import 'package:get/get.dart';

class IdeaCardController extends GetxController {
  late IdeaCardRepository repo;

  var userCards = <GetCardModel>[].obs;

  final RxBool loading = false.obs;

  IdeaCardController({
    required this.repo,
  });

  @override
  void onReady() {
    super.onReady();
    getOwnCards();
  }

  void getOwnCards() async {
    final cards = await repo.getOwnCards();
    userCards.value = cards;
  }

  void deleteProject(int cardId) async {
    loading.value = true;
    update();
    await repo.deleteCard(cardId);
    userCards.removeWhere((card) => card.cardId == cardId);

    loading.value = false;
    update();
  }

  void routeToCreateNewIdeaCard() {
    Get.toNamed(AppConfig().routes.createNewIdeaCard);
  }

  void refreshUserCards() {
    getOwnCards();
  }
}
