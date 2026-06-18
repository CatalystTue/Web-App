import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:flutter/material.dart';

class AppContainerWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final Color? bacjgroundColor;

  const AppContainerWidget({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.width,
    this.height,
    this.bacjgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bacjgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(Dimens().small),
        border: Border.all(
          color: AppColors().lightGrayColor,
          width: 0.3,
        ),
      ),
      child: child,
    );
  }
}
