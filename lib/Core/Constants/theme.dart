import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:flutter/material.dart';

class AppThemes {
  ThemeData light({double ratio = 1.0}) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        appBarTheme: AppBarTheme(
          color: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors().primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: AppColors().primaryColor,
          ),
        ),
        colorScheme:
            ColorScheme.fromSeed(seedColor: AppColors().backGroundColor),
      );
}
