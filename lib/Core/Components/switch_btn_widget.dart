import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';

class CustomSwitchButton extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
        activeColor: AppConfig().colors.darkGrayColor,
        inactiveTrackColor: Colors.white,
        activeTrackColor: AppConfig().colors.darkYellow,
        thumbColor: WidgetStateProperty.resolveWith<Color>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.white;
            }
            return AppColors().lightGrayColor;
          },
        ),
        value: value,
        onChanged: onChanged);
  }
}
