import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/checkbox_btn_widget.dart';
import 'package:catalyst_flutter_app/Core/Components/textfields_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/register/presentation/controller/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text('Register'),
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
            //   "First Name: *",
            //   style: textTheme.titleMedium,
            // ),
            // Gap(AppConfig().dimens.small),
            CustomTextField(
              key: const Key('auth_fn'),
              controller: controller.firstnameCtrl,
              labelText: "First Name *",
              leftIcon: Icons.person_outline,
              validator: (newTextfieldValue) {
                if (newTextfieldValue!.isEmpty) {
                  return "Could not be empty";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.medium),
            // Text(
            //   "Last Name: *",
            //   style: textTheme.titleMedium,
            // ),
            // Gap(AppConfig().dimens.small),
            CustomTextField(
              key: const Key('auth_sn'),
              controller: controller.surnameCtrl,
              labelText: "Last Name *",
              leftIcon: Icons.person_outline,
              validator: (newTextfieldValue) {
                if (newTextfieldValue!.isEmpty) {
                  return "Could not be empty";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.medium),
            // Text(
            //   "Email : *",
            //   style: textTheme.titleMedium,
            // ),
            // Gap(AppConfig().dimens.small),
            CustomTextField(
              key: const Key('auth_email'),
              controller: controller.emailCtrl,
              labelText: "Email *",
              leftIcon: Icons.email_outlined,
              validator: (newTextfieldValue) {
                if (!newTextfieldValue!.isEmail) {
                  return "Invalid email";
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
                  return "could not be empty";
                } else if (!controller.isStrongPassword(newTextfieldValue)) {
                  return "Password is not strong";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.medium),
            // Text(
            //   "Re-enter Password: *",
            //   style: textTheme.titleMedium,
            // ),
            // Gap(AppConfig().dimens.small),
            CustomTextField(
              key: const Key('auth_reEnterPassword'),
              controller: controller.reEnterPasswordCtrl,
              labelText: "Re-enter Password *",
              leftIcon: Icons.lock_outline,
              isPassword: true,
              secondIcon: Icons.remove_red_eye,
              validator: (newTextfieldValue) {
                if (newTextfieldValue!.isEmpty) {
                  return "could not be empty";
                } else if (newTextfieldValue != controller.passwordCtrl.text) {
                  return "Passwords do not match";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.large),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => CustomCheckboxButton(
                      key: UniqueKey(),
                      value: controller.checkboxValue,
                      borderColor: controller.isCheckboxChecked.value
                          ? AppColors().lightGrayColor
                          : AppColors().darkRedColor,
                      onChanged: (value) {
                        controller.checkboxValue.value = value;
                      },
                    )),
                const Gap(10),
                Expanded(
                    child: RichText(
                  text: TextSpan(
                    style: textTheme.titleMedium,
                    children: <TextSpan>[
                      const TextSpan(
                          text: "I have read and agree to the ",
                          style: TextStyle(color: Colors.black)),
                      TextSpan(
                        text: "Terms of Service",
                        style: textTheme.titleMedium!.copyWith(
                          color: AppColors().darkGrayColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
            Gap(AppConfig().dimens.large),
          ],
        ).paddingAll(AppConfig().dimens.medium),
      ),
      bottomNavigationBar: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconButton(
                title: "Register",
                onTap:
                    controller.loading.value ? null : controller.registerUser,
                txtColor: Colors.white,
                color: AppColors().primaryColor,
              ),
              Gap(AppConfig().dimens.medium),
              GestureDetector(
                onTap: () => controller.routeToLogin(),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      WidgetSpan(
                        child: SizedBox(width: 7),
                      ),
                      TextSpan(
                        text: "Login",
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
