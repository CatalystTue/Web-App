import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Utils/external_links.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/Base/feedback_prompt.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/discovery_chrome.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const kFeedIntroBody = 'We notify people when you show interest.\n\n'
    'Tap Interesting! to show interest.\n\n'
    'Swipe down or tap Not interested if you’re not interested.\n\n'
    'Swipe up or tap I know them if you already know them. We won’t show them again.\n\n'
    'The light bulb at the top right opens the liked people page, where you can review people you’ve marked interesting.\n\n'
    'Tap Undo at the top right if you act by mistake.';

class AppBaseView extends StatefulWidget {
  const AppBaseView({super.key});

  @override
  State<AppBaseView> createState() => _AppBaseViewState();
}

class _AppBaseViewState extends State<AppBaseView> {
  final _stackedCardsKey = GlobalKey<StackedCardsScreenState>();
  bool _introScheduled = false;
  bool _feedbackScheduled = false;

  BaseViewModel get controller => Get.find<BaseViewModel>();

  Future<void> _markFeedIntroSeen() async {
    await AppRepo().localCache.write(
          AppConfig().localCacheKeys.feedIntroSeen,
          true,
        );
  }

  Future<void> _onCountedSwipe() async {
    await incrementDiscoverySwipeCount();
    if (!mounted) return;
    _maybeShowFeedbackPrompt(context);
  }

  void _maybeShowFeedIntro(BuildContext context) {
    if (_introScheduled || controller.isLoadingStackUsers) {
      return;
    }
    if (readFeedIntroSeen()) return;
    _introScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('How this works'),
            content: const Text(kFeedIntroBody),
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
      ).whenComplete(() {
        if (!context.mounted) return;
        _maybeShowFeedbackPrompt(context);
      });
    });
  }

  void _maybeShowFeedbackPrompt(BuildContext context) {
    if (_feedbackScheduled || controller.isLoadingStackUsers) {
      return;
    }
    if (!shouldShowFeedbackPrompt(
      introSeen: readFeedIntroSeen(),
      promptSeen: readFeedbackPromptSeen(),
      swipeCount: readDiscoverySwipeCount(),
      threshold: AppConfig().feedbackSwipeThreshold,
    )) {
      return;
    }
    _feedbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("We'd love your feedback"),
            content: const Text(
              "You've been using Catalyst for a while. "
              'Tell us what works and what we should improve.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Maybe later'),
              ),
              TextButton(
                onPressed: () {
                  ExternalLinks.openFeedbackForm();
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Give feedback'),
              ),
            ],
          );
        },
      ).whenComplete(markFeedbackPromptSeen);
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
        _maybeShowFeedbackPrompt(context);
        return Scaffold(
          backgroundColor: AppConfig().colors.backGroundColor,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              controller.isLoadingStackUsers
                  ? const SafeArea(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : StackedCardsScreen(
                      key: _stackedCardsKey,
                      users: controller.stackUsers,
                      onCardHearted: controller.saveIdea,
                      onCardUnhearted: controller.removeSavedIdea,
                      onUserActed: _markFeedIntroSeen,
                      onCountedSwipe: _onCountedSwipe,
                      onHistoryChanged: () {
                        if (mounted) setState(() {});
                      },
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
                      iconSize: kDiscoveryChromeIconSize,
                      color: AppConfig().colors.primaryColor,
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
                    child: DiscoveryUndoLikesSwitch(
                      likesOpen: false,
                      canUndo: _stackedCardsKey.currentState?.canUndo ?? false,
                      onUndo: () {
                        _stackedCardsKey.currentState?.undoLastDismiss();
                      },
                      onLikesPressed: _openLikedUsers,
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
