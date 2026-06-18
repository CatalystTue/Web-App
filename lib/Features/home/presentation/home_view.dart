import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:catalyst_flutter_app/Features/Home/presentation/widgets/row_icon_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'dart:developer';

import 'package:gap/gap.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final AppinioSwiperController controller = AppinioSwiperController();
  final List<String> items = [for (int i = 0; i < 20; i++) 'Item $i'];

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(const Duration(seconds: 1)).then((_) {
  //     _shakeCard();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            Expanded(
              child: AppinioSwiper(
                invertAngleOnBottomDrag: true,
                backgroundCardCount: 0,
                swipeOptions: const SwipeOptions.symmetric(
                    horizontal: true, vertical: false),
                controller: controller,
                onSwipeBegin: _swipeEnd,
                onEnd: _onEnd,
                cardCount: items.length,
                cardBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(Dimens().medium),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            "Research Title: ${items[index]}",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Gap(Dimens().large),
                          const RowIconTitleWidget(
                            lable: 'Tags',
                            icon: Icons.person,
                          ),
                          Gap(Dimens().medium),
                          const RowIconTitleWidget(
                            lable: 'Institution/location',
                            icon: Icons.location_on,
                          ),
                          Gap(Dimens().large),
                          const Text(
                            'Description: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et turpis at enim. Donec vel velit in purus.Description: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et turpis at enim. Donec vel velit in purus.Description: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla et turpis at enim. Donec vel velit in purus.',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Inappropriate",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppConfig().colors.darkRedColor,
                                  )),
                              const Gap(8),
                              Icon(
                                Icons.flag,
                                color: AppConfig().colors.darkRedColor,
                                size: 22,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Gap(AppConfig().dimens.extraLarge),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConfig().colors.lightRedColor),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () {
                      controller.swipeLeft();
                    },
                  ),
                ),
                const Gap(70),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppConfig().colors.greenColor),
                  child: IconButton(
                    icon: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () {
                      controller.swipeRight();
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

  void _swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
    if (activity is Swipe) {
      log('The card was swiped to the : ${activity.direction}');
      log('previous index: $previousIndex, target index: $targetIndex');
    } else if (activity is Unswipe) {
      log('A ${activity.direction.name} swipe was undone.');
      log('previous index: $previousIndex, target index: $targetIndex');
    } else if (activity is CancelSwipe) {
      log('A swipe was cancelled');
    } else if (activity is DrivenActivity) {
      log('Driven Activity');
    }
  }

  void _onEnd() {
    log('end reached!');
  }

  Future<void> _shakeCard() async {
    const double distance = 30;
    await controller.animateTo(
      const Offset(-distance, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
    await controller.animateTo(
      const Offset(distance, 0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    await controller.animateTo(
      const Offset(0, 0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }
}
