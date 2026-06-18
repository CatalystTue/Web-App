import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/textfields_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/recover_account/presentation/controller/recover_account_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class RecoverAccountScreen extends GetView<RecoverAccountController> {
  const RecoverAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Recover Account',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        foregroundColor: AppColors().secondaryColor,
        backgroundColor: AppConfig().colors.backGroundColor,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Text(
                "The fields marked with * are mandatory",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppConfig().colors.txtColor,
                ),
              ),
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
              validator: (newTextfieldValue) {
                if (newTextfieldValue == null || newTextfieldValue.isEmpty) {
                  return "Could not be empty";
                }
                if (!newTextfieldValue.isEmail) {
                  return "Invalid email";
                }
                return null;
              },
            ),
          ],
        ).paddingAll(AppConfig().dimens.medium),
      ),
      bottomNavigationBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconButton(
              title: "Recover your account",
              onTap:
                  controller.loading.value ? null : controller.recoverAccount,
              txtColor: Colors.white,
              color: AppColors().primaryColor,
            ),
          ],
        ).paddingOnly(
          left: AppConfig().dimens.medium,
          right: AppConfig().dimens.medium,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom
              : AppConfig().dimens.medium,
          top: AppConfig().dimens.small,
        ),
      ),
    );
  }
}
