import 'package:catalyst_flutter_app/core/constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RowIconTxtIconWidget extends StatelessWidget {
  final IconData? firstIcon;
  final Widget text;
  final Widget? secondIcon;

  const RowIconTxtIconWidget({
    this.firstIcon,
    required this.text,
    this.secondIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppConfig().colors.txtBodyColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (firstIcon != null)
            Icon(
              firstIcon,
              color: AppConfig().colors.primaryColor,
            ),
          if (firstIcon != null) Gap(AppConfig().dimens.medium),
          text,
          const Spacer(),
          if (secondIcon != null) secondIcon!,
        ],
      ).paddingAll(AppConfig().dimens.medium),
    );
  }
}
