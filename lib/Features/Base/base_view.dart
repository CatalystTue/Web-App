import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBaseView extends GetView<BaseViewModel> {
  const AppBaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BaseViewModel>(
      init: controller,
      builder: (_) => Scaffold(
        backgroundColor: AppConfig().colors.backGroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SafeArea(
              child: controller.isLoadingStackUsers
                  ? const Center(child: CircularProgressIndicator())
                  : StackedCardsScreen(users: controller.stackUsers),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppConfig().dimens.medium,
                    top: AppConfig().dimens.small,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.black,
                    tooltip: 'Settings',
                    onPressed: () =>
                        Get.toNamed(AppConfig().routes.settings),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
