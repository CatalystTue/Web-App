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
            CustomTextField(
              key: const Key('auth_email'),
              controller: controller.emailCtrl,
              labelText: "Email *",
              leftIcon: Icons.email_outlined,
              textInputAction: TextInputAction.next,
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
              labelText: "Password *",
              leftIcon: Icons.lock_outline,
              isPassword: true,
              secondIcon: Icons.remove_red_eye,
              textInputAction: TextInputAction.next,
              validator: (newTextfieldValue) {
                if (newTextfieldValue!.isEmpty) {
                  return "could not be empty";
                } else if (!controller.isStrongPassword(newTextfieldValue)) {
                  return "Password is not strong";
                }
                return null;
              },
            ),
            const Gap(8),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.passwordCtrl,
              builder: (context, value, child) {
                final password = value.text;
                return _PasswordRequirements(
                  requirements: [
                    _PasswordRequirement(
                      label: 'At least 8 characters',
                      isMet: controller.passwordHasMinimumLength(password),
                    ),
                    _PasswordRequirement(
                      label: 'One lowercase letter',
                      isMet: controller.passwordHasLowercaseLetter(password),
                    ),
                    _PasswordRequirement(
                      label: 'One uppercase letter',
                      isMet: controller.passwordHasUppercaseLetter(password),
                    ),
                    _PasswordRequirement(
                      label: 'One number',
                      isMet: controller.passwordHasNumber(password),
                    ),
                    _PasswordRequirement(
                      label: r'One symbol: @ $ ! % * ? &',
                      isMet: controller.passwordHasAllowedSymbol(password),
                    ),
                    _PasswordRequirement(
                      label: r'Only letters, numbers, and @ $ ! % * ? &',
                      isMet: controller
                          .passwordUsesOnlyAllowedCharacters(password),
                    ),
                  ],
                );
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
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => controller.registerUser(),
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
                    child: Text.rich(
                  TextSpan(
                    style: textTheme.titleMedium,
                    children: [
                      const TextSpan(
                          text: "I have read and agree to the ",
                          style: TextStyle(color: Colors.black)),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: controller.showTermsOfUse,
                          child: Text(
                            "Terms of Use",
                            style: textTheme.titleMedium!.copyWith(
                              color: AppColors().darkGrayColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      const TextSpan(
                          text: " and ",
                          style: TextStyle(color: Colors.black)),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.baseline,
                        baseline: TextBaseline.alphabetic,
                        child: GestureDetector(
                          onTap: controller.showPrivacyNotice,
                          child: Text(
                            "Privacy Notice",
                            style: textTheme.titleMedium!.copyWith(
                              color: AppColors().darkGrayColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
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

class _PasswordRequirement {
  const _PasswordRequirement({
    required this.label,
    required this.isMet,
  });

  final String label;
  final bool isMet;
}

class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({
    required this.requirements,
  });

  final List<_PasswordRequirement> requirements;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your password needs:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors().darkGrayColor,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Gap(6),
        ...requirements.map(
          (requirement) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Semantics(
              excludeSemantics: true,
              label:
                  '${requirement.label}: ${requirement.isMet ? 'met' : 'not met'}',
              child: Row(
                children: [
                  Icon(
                    requirement.isMet
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: requirement.isMet
                        ? AppColors().greenColor
                        : AppColors().lightGrayColor,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      requirement.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: requirement.isMet
                                ? AppColors().txtColor
                                : AppColors().lightGrayColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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
