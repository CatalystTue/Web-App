import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/textfields_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/admin_auth/presentation/controller/admin_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class AdminAuthScreen extends GetView<AdminAuthController> {
  const AdminAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text('Admin Login'),
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
            Text(
              "Username: *",
              style: textTheme.titleMedium,
            ),
            Gap(AppConfig().dimens.small),
            CustomTextField(
              controller: controller.usernameCtrl,
              labelText: "Username",
              validator: (newTextfieldValue) {
                if (newTextfieldValue == null || newTextfieldValue.isEmpty) {
                  return "Could not be empty";
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.medium),
            Text(
              "Password: *",
              style: textTheme.titleMedium,
            ),
            Gap(AppConfig().dimens.small),
            CustomTextField(
              controller: controller.passwordCtrl,
              labelText: "Password",
              isPassword: true,
              secondIcon: Icons.remove_red_eye,
              validator: (newTextfieldValue) {
                if (newTextfieldValue == null || newTextfieldValue.isEmpty) {
                  return "Could not be empty";
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
              title: "Login as Admin",
              onTap: controller.loading.value ? null : controller.loginAdmin,
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

class _AdminAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const _AdminAppBarWidget({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
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
