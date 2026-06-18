import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RowIconTitleWidget extends StatelessWidget {
  final String lable;
  final IconData icon;
  const RowIconTitleWidget({
    super.key,
    required this.lable,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors().darkYellow,
        ),
        Gap(Dimens().small),
        Flexible(
          child: Text(
            lable,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
