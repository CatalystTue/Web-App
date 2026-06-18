import 'package:catalyst_flutter_app/core/constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class SettingContainerWidget extends StatelessWidget {
  final IconData firstIcon;
  final String text;
  final Function()? onTap;
  final Widget secondIcon;
  const SettingContainerWidget({
    this.onTap,
    required this.firstIcon,
    required this.text,
    required this.secondIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              firstIcon,
              color: AppConfig().colors.primaryColor,
            ),
            Gap(AppConfig().dimens.medium),
            Text(
              text,
              style: TextStyle(
                color: AppConfig().colors.txtHeaderColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            secondIcon,
          ],
        ).paddingAll(AppConfig().dimens.medium),
      ),
    );
  }
}
