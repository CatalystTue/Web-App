import 'dart:developer';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/domain/swipe_cards_repo.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class SwipeCardsController extends GetxController {
  late SwipeCardsRepository repo;

  final AppinioSwiperController swipeController = AppinioSwiperController();

  var isEndOfCards = false.obs;
  var isLoading = true.obs;

  SwipeCardsController({
    required this.repo,
  });

  Future<void> _loadCards() async {
    isLoading.value = true;
    isEndOfCards.value = false;
    final cards = await repo.getStackOfCards();
    AppRepo().cards.clear();
    AppRepo().cards.addAll(cards);
    isLoading.value = false;
    isEndOfCards.value = cards.isEmpty;
  }

  @override
  void onInit() {
    super.onInit();
    _loadCards();
  }

  void onRefresh() async {
    await _loadCards();
  }

  void onEnd() async {
    await _loadCards();
  }

  void swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    if (activity is Swipe) {
      log('The card was swiped to the : ${activity.direction}');
      log('previous index: $previousIndex, target index: $targetIndex');

      swipeCard(
        interested: activity.direction == AxisDirection.right,
        targetUserId: AppRepo().cards[previousIndex].id,
      );
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
    required bool interested,
    required int targetUserId,
  }) async {
    await repo.swipeCard(
      interested: interested,
      targetUserId: targetUserId,
    );
  }
}
