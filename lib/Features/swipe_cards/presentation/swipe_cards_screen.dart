import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Components/tag_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'controller/swipe_cards_controller.dart';

class SwipeCardsScreen extends GetView<SwipeCardsController> {
  const SwipeCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backGroundColor,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (controller.isEndOfCards.value) {
                  return Center(
                    child: Text(
                      'You have reached the end of the cards.',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConfig().colors.txtHeaderColor,
                      ),
                    ),
                  );
                } else if (AppRepo().cards.isNotEmpty) {
                  return AppinioSwiper(
                    invertAngleOnBottomDrag: true,
                    backgroundCardCount: 1,
                    swipeOptions: const SwipeOptions.symmetric(
                      horizontal: true,
                      vertical: false,
                    ),
                    controller: controller.swipeController,
                    onSwipeBegin: controller.swipeEnd,
                    onEnd: controller.onEnd,
                    cardCount: AppRepo().cards.length,
                    cardBuilder: (BuildContext context, int index) {
                      final card = AppRepo().cards[index];
                      return Card(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.all(Dimens().medium),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  card.title,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Gap(Dimens().large),
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  alignment: WrapAlignment.start,
                                  spacing: Dimens().mediumSmall,
                                  runSpacing: Dimens().mediumSmall,
                                  children: List.generate(card.tags.length,
                                      (skillIndex) {
                                    return TagContainerWidget(
                                      lable: card.tags[skillIndex],
                                      icon: Icons.label,
                                    );
                                  }),
                                ),
                              ),
                              Gap(Dimens().large),
                              Row(
                                children: [
                                  Text(
                                    textAlign: TextAlign.start,
                                    "Status:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppConfig().colors.txtHeaderColor,
                                    ),
                                  ),
                                  Gap(AppConfig().dimens.mediumSmall),
                                  Text(
                                    "Approved",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppConfig().colors.txtBodyColor,
                                    ),
                                  ),
                                ],
                              ),
                              Gap(Dimens().medium),
                              Text(
                                "Summary:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppConfig().colors.txtHeaderColor,
                                ),
                              ),
                              Gap(Dimens().small),
                              Text(
                                card.description,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppConfig().colors.txtBodyColor,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(
                    child: Text(
                      'No cards available',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConfig().colors.txtHeaderColor,
                      ),
                    ),
                  );
                }
              }),
            ),
            Gap(AppConfig().dimens.extraLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 42,
                      color: AppConfig().colors.primaryColor,
                    ),
                    onPressed: () {
                      if (controller.swipeController.cardIndex != null) {
                        controller.swipeCard(
                            interested: "true",
                            cardId: AppRepo()
                                .cards[
                                    controller.swipeController.cardIndex ?? 0]
                                .cardId
                                .toString());
                      }
                    },
                  ),
                ),
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.refresh,
                      color: AppConfig().colors.primaryColor,
                      size: 26,
                    ),
                    onPressed: () {
                      controller.onRefresh();
                    },
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: AppConfig().colors.pinkColor,
                      size: 36,
                    ),
                    onPressed: () {
                      if (controller.swipeController.cardIndex != null) {
                        controller.swipeCard(
                            interested: "true",
                            cardId: AppRepo()
                                .cards[
                                    controller.swipeController.cardIndex ?? 0]
                                .cardId
                                .toString());
                      }
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
