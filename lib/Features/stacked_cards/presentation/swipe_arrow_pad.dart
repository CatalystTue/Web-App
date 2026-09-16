import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';

class SwipeArrowPad extends StatelessWidget {
  final bool enabled;
  final bool canSkip;
  final bool canGoBack;
  final VoidCallback onSkip;
  final VoidCallback onGoBack;
  final VoidCallback onKnow;
  final VoidCallback onNotInterested;

  const SwipeArrowPad({
    super.key,
    required this.enabled,
    required this.canSkip,
    required this.canGoBack,
    required this.onSkip,
    required this.onGoBack,
    required this.onKnow,
    required this.onNotInterested,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppConfig().colors.primaryColor;
    final back = _navArrow(
      icon: Icons.arrow_back_ios_new,
      tooltip: 'Back',
      onPressed: enabled && canGoBack ? onGoBack : null,
      color: color,
    );
    final skip = _navArrow(
      icon: Icons.arrow_forward_ios,
      tooltip: 'Skip',
      onPressed: enabled && canSkip ? onSkip : null,
      color: color,
    );
    final know = _navArrow(
      icon: Icons.keyboard_arrow_up,
      tooltip: 'I know this person',
      onPressed: enabled ? onKnow : null,
      color: color,
    );
    final notInterested = _navArrow(
      icon: Icons.keyboard_arrow_down,
      tooltip: "I'm not interested",
      onPressed: enabled ? onNotInterested : null,
      color: color,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        back,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            know,
            notInterested,
          ],
        ),
        skip,
      ],
    );
  }

  Widget _navArrow({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: color,
      iconSize: 32,
      tooltip: tooltip,
    );
  }
}
