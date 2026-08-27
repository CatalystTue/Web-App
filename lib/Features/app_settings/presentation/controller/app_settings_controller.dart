import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  bool _deletingAccount = false;

  Future<void> logoutUser() async {
    await AppRepo().logoutUser();
  }

  Future<void> deleteAccount(BuildContext context) async {
    if (_deletingAccount) return;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text(
            'This permanently deletes your account and cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: AppConfig().colors.redColor,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    _deletingAccount = true;
    AppRepo().showLoading();
    final response = await AuthenticationService().deleteMe();
    AppRepo().hideLoading();
    _deletingAccount = false;

    if (response != null && !response.containsKey('detail')) {
      await AppRepo().localCache.clear();
      AppRepo().user = null;
      AppRepo().jwtToken = null;
      Get.offAllNamed(AppConfig().routes.splash);
      return;
    }

    if (response == null && AppRepo().hasAccessToken) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not delete your account. Please try again.',
        position: SnackPosition.TOP,
      );
    }
  }
}
