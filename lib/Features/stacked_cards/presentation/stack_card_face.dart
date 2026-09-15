import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

const double kStackCardWidth = 260;
const double kStackCardHeight = 400;
const double kStackCardGap = -150;
const double kStackBehindScale = 0.4;
const double kStackHorizontalStep = kStackCardWidth + kStackCardGap;
const int kStackVisibleCardCount = 5;
const double kStackMaxWidth =
    kStackCardWidth + (kStackVisibleCardCount - 1) * kStackHorizontalStep;
const double kStackHeight = 440;

const List<Color> kStackCardColors = [
  Color(0xFF4F5D75),
  Color(0xFFA4D294),
  Color(0xFFFF9B9B),
  Color(0xFF605D64),
  Color(0xFFFA7E7E),
];

class StackCardFace extends StatelessWidget {
  final StackUserModel user;
  final Color accentColor;
  final String displayName;
  final bool showInterestBulb;
  final bool interestOn;
  final bool canToggleInterest;
  final VoidCallback? onInterestPressed;

  const StackCardFace({
    super.key,
    required this.user,
    required this.accentColor,
    required this.displayName,
    this.showInterestBulb = true,
    this.interestOn = false,
    this.canToggleInterest = false,
    this.onInterestPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.55),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.affiliation.isNotEmpty
                            ? user.affiliation
                            : 'No affiliation',
                        maxLines: 1,
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
                        maxLines: 1,
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
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppConfig().colors.txtBodyColor,
                          ),
                        ),
                      ],
                      Gap(AppConfig().dimens.small),
                      Expanded(
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            child: Text(
                              user.description.isNotEmpty
                                  ? user.description
                                  : 'No description',
                              style: TextStyle(
                                fontSize: 15,
                                color: AppConfig().colors.txtBodyColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
  }
}
