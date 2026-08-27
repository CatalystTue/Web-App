import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
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
                                  card.name,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Gap(Dimens().large),
                              if (card.affiliation.isNotEmpty)
                                _MetaRow(
                                  label: 'Affiliation',
                                  value: card.affiliation,
                                ),
                              if (card.position.isNotEmpty) ...[
                                Gap(Dimens().medium),
                                _MetaRow(
                                  label: 'Position',
                                  value: card.position,
                                ),
                              ],
                              if (card.location.isNotEmpty) ...[
                                Gap(Dimens().medium),
                                _MetaRow(
                                  label: 'Location',
                                  value: card.location,
                                ),
                              ],
                              Gap(Dimens().medium),
                              Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppConfig().colors.txtHeaderColor,
                                ),
                              ),
                              Gap(Dimens().small),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Text(
                                    card.description,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppConfig().colors.txtBodyColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
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
                      controller.swipeController.swipeLeft();
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
                      controller.swipeController.swipeRight();
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

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetaRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppConfig().colors.txtHeaderColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConfig().colors.txtBodyColor,
            ),
          ),
        ),
      ],
    );
  }
}
