import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

void closeLikedUsersToHome(BuildContext context) {
  final base = AppConfig().routes.base;
  if (Get.key.currentState?.canPop() ?? false) {
    Get.back();
    return;
  }
  final navigator = Navigator.maybeOf(context);
  if (navigator != null && navigator.canPop()) {
    navigator.pop();
    return;
  }
  if (Get.key.currentState != null) {
    Get.offNamed(base);
  }
}

class DiscoveryUndoLikesSwitch extends StatelessWidget {
  final bool likesOpen;
  final bool canUndo;
  final VoidCallback? onUndo;
  final VoidCallback onLikesPressed;

  const DiscoveryUndoLikesSwitch({
    super.key,
    required this.likesOpen,
    required this.canUndo,
    required this.onUndo,
    required this.onLikesPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppConfig().colors.primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            likesOpen ? Icons.lightbulb : Icons.lightbulb_outline_rounded,
          ),
          iconSize: kDiscoveryChromeIconSize,
          color: AppConfig().colors.sparkYellow,
          tooltip: 'Liked people',
          onPressed: onLikesPressed,
        ),
        Opacity(
          opacity: canUndo ? 1 : 0.4,
          child: IconButton(
            icon: const Icon(Icons.undo),
            iconSize: kDiscoveryChromeIconSize,
            color: primary,
            tooltip: 'Undo',
            onPressed: canUndo ? onUndo : null,
          ),
        ),
      ],
    );
  }
}

class DiscoveryActionCluster extends StatelessWidget {
  final double cardWidth;
  final Widget cardRow;
  final Widget topAction;
  final Widget? secondaryAction;
  final Widget bottomAction;

  const DiscoveryActionCluster({
    super.key,
    required this.cardWidth,
    required this.cardRow,
    required this.topAction,
    this.secondaryAction,
    required this.bottomAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(width: cardWidth, child: topAction),
        const Gap(kDiscoveryButtonGap),
        cardRow,
        const Gap(kDiscoveryButtonGap),
        if (secondaryAction != null) ...[
          SizedBox(width: cardWidth, child: secondaryAction),
          const Gap(kDiscoveryInterestingAfterGap),
        ],
        SizedBox(width: cardWidth, child: bottomAction),
        if (secondaryAction == null) ...[
          const Gap(kDiscoveryInterestingAfterGap),
          const SizedBox(height: kDiscoveryButtonHeight),
        ],
      ],
    );
  }
}
