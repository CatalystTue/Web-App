import 'dart:developer';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/domain/swipe_cards_repo.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SwipeCardsController extends GetxController {
  late SwipeCardsRepository repo;

  // TODO check despose controller
  final AppinioSwiperController swipeController = AppinioSwiperController();

  var isEndOfCards = false.obs;
  var isLoading = true.obs;

  SwipeCardsController({
    required this.repo,
  });

  void _init() async {
    // note that the stack does NOT consist of all qi cards. instead these cards are provided by the backend in some qay to be defined on the backend
    // Get.context!.loaderOverlay.show();
    isLoading.value = true;
    // TODO make error handling
    final cards = await repo.getStackOfCards();
    AppRepo().cards.clear();
    AppRepo().cards.addAll(cards);
    // Get.context!.loaderOverlay.hide();
    isLoading.value = false;
    print('Cards: ${AppRepo().cards}');
  }

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void onRefresh() async {
    onEnd();
  }

  void onEnd() async {
    isEndOfCards.value = true;

    // TODO update the cards on the stack -> does it work the way how coded below?
    isLoading.value = true;
    final cards = await repo.getStackOfCards();
    AppRepo().cards.clear();
    AppRepo().cards.addAll(cards);
    // Get.context!.loaderOverlay.hide();
    isLoading.value = false;
    print('Cards: ${AppRepo().cards}');
  }

  void swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    if (activity is Swipe) {
      log('The card was swiped to the : ${activity.direction}');
      log('previous index: $previousIndex, target index: $targetIndex');

      swipeCard(
          interested: (activity.direction == AxisDirection.right ? true : false)
              .toString(),
          cardId: "${AppRepo().cards[previousIndex].cardId}");
    } else if (activity is Unswipe) {
      log('A ${activity.direction.name} swipe was undone.');
      log('previous index: $previousIndex, target index: $targetIndex');
    } else if (activity is CancelSwipe) {
      log('A swipe was cancelled');
    } else if (activity is DrivenActivity) {
      log('Driven Activity');
    }
  }

  Future<void> shakeCard() async {
    const double distance = 30;
    await swipeController.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await swipeController.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await swipeController.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  Future<void> swipeCard({
    required String interested,
    required String cardId,
  }) async {
    AppRepo().showLoading();
    await repo.swipeCard(
      interested: interested,
      cardId: cardId,
    );
  }
}
