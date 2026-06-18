import 'package:catalyst_flutter_app/Core/Components/app_container_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RowIconTxtIconWidget extends StatelessWidget {
  final IconData firstIcon;
  final String text;
  final Widget secondIcon;
  const RowIconTxtIconWidget({
    required this.firstIcon,
    required this.text,
    required this.secondIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainerWidget(
      child: Row(
        children: [
          Icon(
            firstIcon,
            color: AppConfig().colors.secondaryColor,
          ),
          Gap(AppConfig().dimens.medium),
          Text(
            text,
            style: TextStyle(
              color: AppConfig().colors.secondaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          secondIcon,
        ],
      ).paddingAll(AppConfig().dimens.medium),
    );
  }
}
