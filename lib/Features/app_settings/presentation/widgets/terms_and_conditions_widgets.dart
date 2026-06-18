import 'package:catalyst_flutter_app/Core/Components/app_container_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  const TermsAndConditionsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppContainerWidget(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.sticky_note_2,
                color: AppConfig().colors.secondaryColor,
              ),
              Gap(AppConfig().dimens.medium),
              Text(
                "Terms and Conditions",
                style: TextStyle(
                  color: AppConfig().colors.secondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.secondaryColor,
              ),
            ],
          ),
          Gap(AppConfig().dimens.small),
          Divider(
            color: AppConfig().colors.lightGrayColor,
            thickness: 0.6,
          ),
          Gap(AppConfig().dimens.small),
          Row(
            children: [
              Icon(
                Icons.privacy_tip,
                color: AppConfig().colors.secondaryColor,
              ),
              Gap(AppConfig().dimens.medium),
              Text(
                "Privacy Policy",
                style: TextStyle(
                  color: AppConfig().colors.secondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.secondaryColor,
              ),
            ],
          ),
        ],
      ).paddingAll(AppConfig().dimens.medium),
    );
  }
}
