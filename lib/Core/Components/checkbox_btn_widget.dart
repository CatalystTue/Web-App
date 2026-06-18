import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomCheckboxButton extends StatelessWidget {
  final RxBool value;
  final ValueChanged<bool> onChanged;
  final Color borderColor;

  const CustomCheckboxButton(
      {required Key key,
      required this.value,
      required this.borderColor,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          value.value = !value.value;
          onChanged(value.value);
        },
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors().backGroundColor,
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: value.value
              ? Icon(
                  Icons.check,
                  size: 16.0,
                  color: AppColors().darkGrayColor,
                )
              : null,
        ),
      ),
    );
  }
}
