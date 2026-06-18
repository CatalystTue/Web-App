import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:catalyst_flutter_app/Features/splash_screen/data/repository/splash_repository_impl.dart';
import 'package:catalyst_flutter_app/Features/splash_screen/presentation/controller/splash_controller.dart';
import 'package:catalyst_flutter_app/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  SplashView({super.key});

  @override
  final controller = Get.put(SplashController(repo: SplashRepositoryImpl()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Gap(150),
            Image.asset(
              Assets.png.logo.path,
              fit: BoxFit.fill,
              width: 170,
              height: 170,
            ),
            Gap(Dimens().medium),
            const Text(
              "Unite, Motivate, \nCooperate.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
