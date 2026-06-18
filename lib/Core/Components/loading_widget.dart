import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:flutter/material.dart';

class CustomLoadingIndicator extends StatelessWidget {
  final double? stroke;
  const CustomLoadingIndicator({super.key, this.stroke});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      color: Colors.white.withOpacity(.4),
      child: Center(
          child: SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          color: AppColors().primaryColor,
          strokeWidth: stroke ?? 4,
        ),
      )),
    );
  }
}
