import 'package:catalyst_flutter_app/Core/Components/loading_widget.dart';
import 'package:catalyst_flutter_app/Core/Components/snackbar_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Local_Cache/local_cache_helper.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/Core/Utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppRepo {
  static final AppRepo _singleton = AppRepo._internal();
  factory AppRepo() => _singleton;
  AppRepo._internal();

  // Private Resources
  bool _isGlobalLoadingOn = false;

  //  Internal Resources
  final localCache = LocalCacheHelper();

  bool networkConnectivity = true;
  RxList<int> networkConnectivityStream = RxList<int>([]);

  final CustomSnackbar customSnackbar = CustomSnackbar(
    label: '',
    text: '',
  );

  // External Resources
  String? jwtToken;
  User? user;

  List<GetCardModel> cards = [];
  Future<void> getStack() async {
    AppRepo().cards.clear();
    AppRepo().cards.addAll(await CardsService().getStack());
  }

  void showLoading() {
    if (_isGlobalLoadingOn == true) return;

    _isGlobalLoadingOn = true;
    if (Get.context == null) return;

    Get.dialog(PopScope(
        canPop: false,
        onPopInvoked: (didPop) => false,
        child: const CustomLoadingIndicator()));
  }

  void hideLoading() {
    if (_isGlobalLoadingOn == false) return;
    if (Get.context == null) return;

    _isGlobalLoadingOn = false;
    Get.back();
  }

  void showSnackbar({
    required String label,
    required String text,
    IconData icon = Icons.info,
    Color? backgroundColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.BOTTOM,
  }) {
    CustomSnackbar(
      label: label,
      text: text,
      icon: icon,
      backgroundColor: backgroundColor ?? AppConfig().colors.secondaryColor,
      textColor: textColor,
      duration: duration,
      position: position,
      labelStyle: TextStyle(
          fontSize: 16,
          color: AppConfig().colors.primaryColor,
          fontWeight: FontWeight.bold),
      textStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppConfig().colors.primaryColor,
      ),
    ).show();
  }

  Future<bool> loginUser(Map<String, dynamic> response) async {
    /* Update localCache based on Server data */
    user = User.fromJson(response);
    jwtToken = user!.token;

    // await secureLocalCache.write(
    //   AppConfig().localSecureCacheKeys.userObject,
    //   jsonEncode(response),
    // );

    AppRepo().localCache.write(
          AppConfig().localCacheKeys.userLoggedInStatus,
          UserStatus.loggedIn.toLocalCacheInt(),
        );

    return true;
  }

  Future<void> logoutUser() async {
    showLoading();

    await AppRepo().localCache.clear();
    user = null;
    jwtToken = null;

    await Future.delayed(const Duration(seconds: 2));
    AppRepo().hideLoading();

    Get.offAllNamed(AppConfig().routes.splash);
  }
}
