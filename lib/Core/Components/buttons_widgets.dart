import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomIconButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Icon? icon;
  final Color? color;
  final double? size;
  final ShapeBorder? shape;
  final double? paddingHorizontal;
  final double? paddingVertical;
  final double? height;
  final double? width;
  final Color? txtColor;

  const CustomIconButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.color,
    this.size,
    this.height,
    this.txtColor,
    this.width,
    this.shape,
    this.paddingHorizontal,
    this.paddingVertical,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50.0,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon ?? const SizedBox.shrink(),
        label: Text(title,
            style: TextStyle(
                color: txtColor ?? Colors.white, fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppConfig().colors.secondaryColor,
          shape: shape as OutlinedBorder?,
        ),
      ),
    ).paddingSymmetric(
        horizontal: paddingHorizontal ?? 0.0, vertical: paddingVertical ?? 0.0);
  }
}

class CustomOutlineIconButton extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final Icon? icon;
  final Color? color;
  final Color? txtColor;
  final Color? borderColor;
  final double? height;
  final double? width;
  final ShapeBorder? shape;
  final double? paddingHorizontal;
  final double? paddingVertical;

  const CustomOutlineIconButton({
    super.key,
    required this.title,
    this.icon,
    this.onTap,
    this.color,
    this.height,
    this.width,
    this.shape,
    this.txtColor,
    this.borderColor,
    this.paddingHorizontal,
    this.paddingVertical,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap != null ? 1 : 0.4,
      child: SizedBox(
        width: width ?? double.infinity,
        height: height ?? 50.0,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: icon ?? const SizedBox.shrink(),
          label: Text(title,
              textAlign: TextAlign.center,
              // maxLines: 1,
              style: TextStyle(
                color: txtColor ?? AppConfig().colors.primaryColor,
                fontWeight: FontWeight.w700,
              )),
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? AppConfig().colors.primaryColor,
            side: BorderSide(
              color: borderColor ?? AppConfig().colors.primaryColor,
              width: 1.5,
            ),
            shape: shape as OutlinedBorder?,
          ),
        ),
      ).paddingSymmetric(
          horizontal: paddingHorizontal ?? 0.0,
          vertical: paddingVertical ?? 0.0),
    );
  }
}
