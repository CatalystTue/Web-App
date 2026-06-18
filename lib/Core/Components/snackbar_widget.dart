import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomSnackbar {
  String label;
  String text;
  IconData icon;
  Color? backgroundColor;
  Color textColor;
  Duration duration;
  SnackPosition position;
  TextStyle labelStyle;
  TextStyle textStyle;

  CustomSnackbar({
    required this.label,
    required this.text,
    this.icon = Icons.info,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.duration = const Duration(seconds: 3),
    this.position = SnackPosition.BOTTOM,
    this.labelStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    ),
    this.textStyle = const TextStyle(
      fontSize: 14,
    ),
  });

  void show() {
    backgroundColor ??= AppConfig().colors.primaryColor;

    Get.snackbar(
      label,
      text,
      icon: Icon(icon, color: textColor),
      shouldIconPulse: true,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      snackPosition: position,
      titleText: Text(
        label,
        style: labelStyle,
      ),
      messageText: Text(
        text,
        style: textStyle,
      ),
    );
  }
}
