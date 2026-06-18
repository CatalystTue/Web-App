// import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
// import 'package:catalyst_flutter_app/Core/Components/switch_btn_widget.dart';
// import 'package:catalyst_flutter_app/Core/Constants/config.dart';
// import 'package:catalyst_flutter_app/Features/app_settings/presentation/widgets/row_icon_txt_icon_widget.dart';
// import 'package:catalyst_flutter_app/Features/app_settings/presentation/widgets/terms_and_conditions_widgets.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';

// import 'controller/app_settings_controller.dart';

// class AppSettingsScreen extends GetView<AppSettingsController> {
//   const AppSettingsScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppConfig().colors.backGroundColor,
//       appBar: AppBar(
//         title: const Text(
//           'Settings',
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         backgroundColor: AppConfig().colors.backGroundColor,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RowIconTxtIconWidget(
//               firstIcon: Icons.person_pin_sharp,
//               text: 'Profile',
//               secondIcon: Icon(
//                 Icons.arrow_forward_ios,
//                 color: AppConfig().colors.secondaryColor,
//               ),
//             ),
//             Gap(AppConfig().dimens.medium),
//             RowIconTxtIconWidget(
//               firstIcon: Icons.notification_important_rounded,
//               text: 'Notifications',
//               secondIcon: Obx(
//                 () {
//                   return CustomSwitchButton(
//                     value: controller.isNotificationOn.value,
//                     onChanged: (newValue) =>
//                         controller.isNotificationOn.value = newValue,
//                   );
//                 },
//               ),
//             ),
//             Gap(AppConfig().dimens.extraLarge),
//             Text("Terms and Conditions",
//                 style: TextStyle(
//                   color: AppConfig().colors.secondaryColor,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 )),
//             Gap(AppConfig().dimens.medium),
//             const TermsAndConditionsWidget(),
//             Gap(AppConfig().dimens.extraLarge),
//             RowIconTxtIconWidget(
//               firstIcon: Icons.help_center,
//               text: 'Contact Us',
//               secondIcon: Icon(
//                 Icons.arrow_forward_ios,
//                 color: AppConfig().colors.secondaryColor,
//               ),
//             ),
//           ],
//         ).paddingAll(AppConfig().dimens.medium),
//       ),
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.only(
//           left: AppConfig().dimens.medium,
//           right: AppConfig().dimens.medium,
//           // bottom: AppConfig().dimens.large,
//           bottom: MediaQuery.of(context).padding.bottom > 0
//               ? MediaQuery.of(context).padding.bottom
//               : AppConfig().dimens.medium,
//           top: AppConfig().dimens.small,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CustomIconButton(
//               title: "Logout",
//               txtColor: AppConfig().colors.secondaryColor,
//               color: AppConfig().colors.darkYellow,
//               onTap: controller.logout,
//             ),
//             Gap(AppConfig().dimens.medium),
//             CustomOutlineIconButton(
//               title: "Delete Account",
//               onTap: () {},
//               borderColor: AppConfig().colors.secondaryColor,
//               txtColor: AppConfig().colors.secondaryColor,
//             ),
//             Gap(
//               AppConfig().dimens.medium,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:catalyst_flutter_app/Core/components/switch_btn_widget.dart';
import 'package:catalyst_flutter_app/Core/constants/config.dart';
import 'package:catalyst_flutter_app/Features/app_settings/presentation/controller/app_settings_controller.dart';
import 'package:catalyst_flutter_app/Features/app_settings/presentation/widgets/setting_container_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class AppSettingsScreen extends GetView<AppSettingsController> {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(AppConfig().dimens.medium),
            SettingContainerWidget(
              firstIcon: Icons.person_outlined,
              text: 'Profile',
              secondIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.primaryColor,
              ),
            ),
            Gap(AppConfig().dimens.medium),
            SettingContainerWidget(
              firstIcon: Icons.notification_important_outlined,
              text: 'Notifications',
              secondIcon: Obx(
                () {
                  return CustomSwitchButton(
                    value: controller.isNotificationOn.value,
                    onChanged: (newValue) =>
                        controller.isNotificationOn.value = newValue,
                  );
                },
              ),
            ),
            Gap(AppConfig().dimens.medium),
            SettingContainerWidget(
              firstIcon: Icons.privacy_tip_outlined,
              text: 'Privacy',
              secondIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.primaryColor,
              ),
            ),
            Divider(
              height: 0,
              thickness: 1.5,
              color: Colors.grey[300],
            ),
            SettingContainerWidget(
              firstIcon: Icons.lock_outlined,
              text: 'Security',
              secondIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.primaryColor,
              ),
            ),
            Gap(AppConfig().dimens.extraLarge),
            SettingContainerWidget(
              onTap: () => AppRepo().showSnackbar(
                  label: 'General', text: 'You can NOT delete yourself!'),
              firstIcon: Icons.delete_forever_outlined,
              text: 'Delete Account',
              secondIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.primaryColor,
              ),
            ),
            Divider(
              height: 0,
              thickness: 1.5,
              color: Colors.grey[300],
            ),
            SettingContainerWidget(
              onTap: () => controller.logoutUser(),
              firstIcon: Icons.logout,
              text: 'Logout',
              secondIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppConfig().colors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
