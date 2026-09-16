import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBaseView extends StatefulWidget {
  const AppBaseView({super.key});

  @override
  State<AppBaseView> createState() => _AppBaseViewState();
}

class _AppBaseViewState extends State<AppBaseView> {
  final _stackedCardsKey = GlobalKey<StackedCardsScreenState>();
  bool _introScheduled = false;

  BaseViewModel get controller => Get.find<BaseViewModel>();

  Future<void> _markFeedIntroSeen() async {
    await AppRepo().localCache.write(
          AppConfig().localCacheKeys.feedIntroSeen,
          true,
        );
  }

  void _maybeShowFeedIntro(BuildContext context) {
    if (_introScheduled || controller.isLoadingStackUsers) {
      return;
    }
    final seen = AppRepo().localCache.read<bool>(
              AppConfig().localCacheKeys.feedIntroSeen,
            ) ??
        false;
    if (seen) return;
    _introScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('How this works'),
            content: const Text(
              'We notify people when you show interest.\n\n'
              'Tap the light bulb to show interest.\n\n'
              'Swipe right to skip, swipe left to go back.\n\n'
              'Swipe down if you’re not interested.\n\n'
              'Swipe up if you already know them. We won’t show them again.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  await _markFeedIntroSeen();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Got it'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _openLikedUsers() async {
    await Get.toNamed(AppConfig().routes.likedUsers);
    if (!mounted) return;
    controller.fetchSavedIdeas();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BaseViewModel>(
      builder: (_) {
        _maybeShowFeedIntro(context);
        return Scaffold(
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
                        onUserActed: _markFeedIntroSeen,
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
                          onPressed: () {
                            _stackedCardsKey.currentState?.undoLastDismiss();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline_rounded),
                          color: Colors.black,
                          onPressed: _openLikedUsers,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
