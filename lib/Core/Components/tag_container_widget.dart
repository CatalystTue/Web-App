import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TagContainerWidget extends StatelessWidget {
  final String lable;
  final IconData icon;
  const TagContainerWidget({
    super.key,
    required this.lable,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors().secondaryColor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors().primaryColor,
            ),
            Gap(Dimens().small),
            Flexible(
              child: Text(
                lable,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConfig().colors.txtHeaderColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
