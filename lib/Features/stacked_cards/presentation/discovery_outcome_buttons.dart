import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stack_card_face.dart';
import 'package:flutter/material.dart';

class DiscoveryOutcomeButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final VoidCallback? onPressed;
  final double? width;
  final double height;

  const DiscoveryOutcomeButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
    this.onPressed,
    this.width,
    this.height = kDiscoveryButtonHeight,
  });

  static const double radius = 16;

  factory DiscoveryOutcomeButton.know({
    Key? key,
    required VoidCallback? onPressed,
    double? width,
  }) {
    return DiscoveryOutcomeButton(
      key: key,
      label: 'I know them',
      icon: const Icon(
        Icons.expand_less,
        color: Colors.white,
        size: kDiscoveryActionIconSize,
      ),
      backgroundColor: kDiscoveryKnowColor,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      width: width,
    );
  }

  factory DiscoveryOutcomeButton.interesting({
    Key? key,
    required VoidCallback? onPressed,
    required bool filled,
    double? width,
  }) {
    final yellow = AppConfig().colors.sparkYellow;
    return DiscoveryOutcomeButton(
      key: key,
      label: 'Interesting!',
      icon: Icon(
        filled ? Icons.lightbulb : Icons.lightbulb_outline_rounded,
        color: yellow,
        size: kDiscoveryActionIconSize,
      ),
      backgroundColor: Colors.white,
      foregroundColor: AppConfig().colors.txtHeaderColor,
      borderColor: Colors.grey[300],
      onPressed: onPressed,
      width: width,
    );
  }

  factory DiscoveryOutcomeButton.notInterested({
    Key? key,
    required VoidCallback? onPressed,
    double? width,
  }) {
    return DiscoveryOutcomeButton(
      key: key,
      label: 'Not interested',
      icon: const Icon(
        Icons.expand_more,
        color: Colors.white,
        size: kDiscoveryActionIconSize,
      ),
      backgroundColor: kDiscoveryRejectColor,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      width: width,
    );
  }

  ButtonStyle _style({required bool outlined}) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    final min = Size(width ?? 0, height);
    final max = Size(width ?? double.infinity, height);
    final fixed =
        width != null ? Size(width!, height) : Size.fromHeight(height);
    if (outlined) {
      return OutlinedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledForegroundColor: foregroundColor,
        side: BorderSide(color: borderColor!, width: 1.5),
        minimumSize: min,
        maximumSize: max,
        fixedSize: fixed,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.standard,
        alignment: Alignment.center,
        shape: shape,
      );
    }
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: backgroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      minimumSize: min,
      maximumSize: max,
      fixedSize: fixed,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      alignment: Alignment.center,
      shape: shape,
    );
  }

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
              fontSize: kDiscoveryActionLabelSize,
              height: 1.0,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: icon,
          ),
        ],
      ),
    );

    final button = borderColor == null
        ? ElevatedButton(
            onPressed: onPressed,
            style: _style(outlined: false),
            child: child,
          )
        : OutlinedButton(
            onPressed: onPressed,
            style: _style(outlined: true),
            child: child,
          );

    return Opacity(
      opacity: onPressed != null ? 1 : 0.4,
      child: SizedBox(
        width: width,
        height: height,
        child: button,
      ),
    );
  }
}
