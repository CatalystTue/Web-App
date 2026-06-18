import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/textfields_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'controller/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: AppConfig().colors.backGroundColor,
        // foregroundColor: AppColors().secondaryColor,
        // iconTheme: IconThemeData(
        //   color: AppColors().secondaryColor,
        // ),
        // centerTitle: true,
        // scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text("The fields marked with * are mandatory",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppConfig().colors.txtColor,
                  )),
            ),
            Gap(AppConfig().dimens.medium),
            // Text(
            //   "Email: *",
            //   style: textTheme.titleMedium,
            // ),
            // Gap(AppConfig().dimens.small),
            CustomTextField(
              controller: controller.emailCtrl,
              labelText: "Email address",
              leftIcon: Icons.email_outlined,
              validator: (newTextfieldValue) {
                if (newTextfieldValue!.isEmpty) {
                  return "Could not be empty";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.medium),
            // Text(
            //   "Password: *",
            //   style: textTheme.titleMedium,
            // ),
            // Gap(AppConfig().dimens.small),
            CustomTextField(
              controller: controller.passwordCtrl,
              labelText: "Password",
              leftIcon: Icons.lock_outline,
              isPassword: true,
              secondIcon: Icons.remove_red_eye,
              validator: (newTextfieldValue) {
                if (newTextfieldValue!.isEmpty) {
                  return "Could not be empty";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.large),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: "",
                  style: const TextStyle(color: Colors.black),
                  children: [
                    const WidgetSpan(
                      child: SizedBox(width: 7),
                    ),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => controller.routeToRecoverAccountScreen(),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(
                            text: "Forgot your password?",
                            style: TextStyle(color: Colors.black),
                            children: [
                              WidgetSpan(
                                child: SizedBox(width: 7),
                              ),
                              TextSpan(
                                text: "Reset it",
                                style: TextStyle(color: Colors.black),
                              ),
                              TextSpan(
                                text: " here",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).paddingAll(AppConfig().dimens.medium),
      ),
      bottomNavigationBar: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconButton(
                title: "Login",
                onTap: controller.loading.value ? null : controller.loginUser,
                txtColor: Colors.white,
                color: AppColors().primaryColor,
              ),
              Gap(AppConfig().dimens.medium),
              GestureDetector(
                onTap: () => controller.routeToRegisterScreen(),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      WidgetSpan(
                        child: SizedBox(width: 7),
                      ),
                      TextSpan(
                        text: "Register",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      TextSpan(
                        text: " here",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )).paddingOnly(
        left: AppConfig().dimens.medium,
        right: AppConfig().dimens.medium,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : AppConfig().dimens.medium,
        top: AppConfig().dimens.small,
      ),
    );
  }
}

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  const CustomAppBarWidget({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title!,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      foregroundColor: AppColors().secondaryColor,
      backgroundColor: AppConfig().colors.primaryColor,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
