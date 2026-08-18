import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBaseView extends GetView<BaseViewModel> {
  AppBaseView({super.key});

  final _stackedCardsKey = GlobalKey<StackedCardsScreenState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BaseViewModel>(
      init: controller,
      builder: (_) => Scaffold(
        backgroundColor: AppConfig().colors.backGroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SafeArea(
              child: controller.isLoadingStackUsers
                  ? const Center(child: CircularProgressIndicator())
                  : StackedCardsScreen(
                      key: _stackedCardsKey,
                      users: controller.stackUsers,
                      onCardHearted: controller.saveIdea,
                      onCardUnhearted: controller.removeSavedIdea,
                    ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppConfig().dimens.medium,
                    top: AppConfig().dimens.small,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.black,
                    tooltip: 'Settings',
                    onPressed: () => Get.toNamed(AppConfig().routes.settings),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: AppConfig().dimens.medium,
                    top: AppConfig().dimens.small,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        color: Colors.black,
                        tooltip: 'Undo',
                        onPressed: () =>
                            _stackedCardsKey.currentState?.undoLastDismiss(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        color: Colors.black,
                        tooltip: 'Saved Ideas',
                        onPressed: () => _showSavedIdeas(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedIdeas(BuildContext context) {
    final savedIdeas = controller.savedIdeas;
    showGeneralDialog(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Saved Ideas',
  transitionDuration: const Duration(milliseconds: 250),
  pageBuilder: (_, __, ___) => Align(
    alignment: Alignment.centerRight,
    child: Material(
      color: AppConfig().colors.backGroundColor,
      child: SizedBox(
        width: 420,
        height: double.infinity,
        child: SafeArea(
          child: /* your Saved Ideas list */,
        ),
      ),
    ),
  ),
  transitionBuilder: (_, animation, __, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    );
  },
);
  }
}
