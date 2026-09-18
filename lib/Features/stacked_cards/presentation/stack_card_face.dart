import 'dart:math' as math;

import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

const double kStackCardWidth = 312;
const double kStackCardHeight = 480;
const double kStackPeekScale = 0.72;
const double kStackPeekOverlap = 0.35;
const double kDiscoveryButtonHeight = 54;
const double kDiscoveryButtonGap = 10;
const double kDiscoveryInterestingAfterGap = 5;
const double kDiscoveryChromeInset = 100;
const double kDiscoveryActionLabelSize = 16;
const double kDiscoveryActionIconSize = 28;
const double kDiscoveryChromeIconSize = 32;
const double kDiscoveryChevronExtent = 48;
const Color kDiscoveryKnowColor = Color(0xFF647086);
const Color kDiscoveryRejectColor = Color(0xFFCE6E6E);

const List<Color> kStackCardColors = [
  Color(0xFF4F5D75),
  Color(0xFF4F6D75),
  Color(0xFF4F756C),
  Color(0xFF5A7554),
  Color(0xFF645575),
];

double stackPeekOffset(double cardWidth) {
  return cardWidth * (0.5 * (1 + kStackPeekScale) - kStackPeekOverlap);
}

double discoveryPeekPad(double cardWidth) {
  return cardWidth * (kStackPeekScale - kStackPeekOverlap);
}

double discoveryCarouselRowWidth(double cardWidth) {
  return cardWidth +
      2 * kDiscoveryChevronExtent +
      2 * discoveryPeekPad(cardWidth);
}

double discoveryCarouselClipWidth({
  required double cardWidth,
  required double maxWidth,
}) {
  final row = discoveryCarouselRowWidth(cardWidth);
  return maxWidth >= row ? row : maxWidth;
}

double discoveryCardWidth({
  required double maxWidth,
}) {
  return math.min(kStackCardWidth, math.max(0.0, maxWidth));
}

double discoveryCardHeight({
  required double maxHeight,
}) {
  const reserved = 3 * kDiscoveryButtonHeight +
      2 * kDiscoveryButtonGap +
      kDiscoveryInterestingAfterGap;
  return math.min(
    kStackCardHeight,
    math.max(120.0, maxHeight - reserved),
  );
}

Color stackCardColorFor(int index) {
  final i = index.abs() % kStackCardColors.length;
  return kStackCardColors[i];
}

class StackCardFace extends StatelessWidget {
  final StackUserModel user;
  final Color accentColor;
  final String displayName;
  final bool showInterestBulb;
  final bool interestOn;
  final bool canToggleInterest;
  final VoidCallback? onInterestPressed;
  final double? width;
  final double? height;

  const StackCardFace({
    super.key,
    required this.user,
    required this.accentColor,
    required this.displayName,
    this.showInterestBulb = false,
    this.interestOn = false,
    this.canToggleInterest = false,
    this.onInterestPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      margin: EdgeInsets.zero,
      elevation: 10.0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(AppConfig().dimens.medium),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Gap(AppConfig().dimens.medium),
                Text(
                  displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConfig().colors.txtHeaderColor,
                  ),
                ),
                Gap(AppConfig().dimens.small),
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.affiliation.isNotEmpty
                                ? user.affiliation
                                : 'No affiliation',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppConfig().colors.txtBodyColor,
                            ),
                          ),
                          Gap(AppConfig().dimens.small),
                          Text(
                            user.position.isNotEmpty
                                ? user.position
                                : 'No position',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppConfig().colors.txtBodyColor,
                            ),
                          ),
                          if (user.location.isNotEmpty) ...[
                            Gap(AppConfig().dimens.small),
                            Text(
                              user.location,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppConfig().colors.txtBodyColor,
                              ),
                            ),
                          ],
                          Gap(AppConfig().dimens.small),
                          Text(
                            user.description.isNotEmpty
                                ? user.description
                                : 'No description',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppConfig().colors.txtBodyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showInterestBulb)
              Positioned(
                right: 0,
                bottom: 0,
                child: IconButton(
                  onPressed: canToggleInterest ? onInterestPressed : null,
                  tooltip: canToggleInterest
                      ? (interestOn ? 'Remove interest' : 'Show interest')
                      : null,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints.tightFor(width: 40, height: 40),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      interestOn
                          ? Icons.lightbulb
                          : Icons.lightbulb_outline_rounded,
                      key: ValueKey(interestOn),
                      color: AppConfig().colors.sparkYellow,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (width == null && height == null) return card;
    return SizedBox(
      width: width,
      height: height,
      child: card,
    );
  }
}
