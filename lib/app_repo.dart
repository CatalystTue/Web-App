import 'dart:convert';

import 'package:catalyst_flutter_app/Core/Components/loading_widget.dart';
import 'package:catalyst_flutter_app/Core/Components/snackbar_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Local_Cache/local_cache_helper.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
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
  bool _redirectingToAuth = false;
  bool onboardingComplete = false;

  bool get hasAccessToken {
    final token = jwtToken?.trim();
    return token != null && token.isNotEmpty;
  }

  bool get isAdminSession => _jwtRole() == 'admin';

  String? _jwtRole() {
    final token = jwtToken?.trim();
    if (token == null || token.isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
      return payloadMap['role']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<bool> refreshOnboardingStatus() async {
    final profile = await AuthenticationService().getProfile();
    onboardingComplete = profile?['onboarding_complete'] == true;
    return onboardingComplete;
  }

  Future<void> initLocalCache() async {
    await localCache.init();
    restoreSession();
  }

  void restoreSession() {
    final stored = localCache.read(AppConfig().localCacheKeys.accessToken);
    final token = stored?.toString().trim();
    jwtToken = (token != null && token.isNotEmpty) ? token : null;
  }

  Future<void> persistAccessToken(String? token) async {
    final value = token?.trim();
    if (value == null || value.isEmpty) {
      await localCache.remove(AppConfig().localCacheKeys.accessToken);
      return;
    }
    await localCache.write(AppConfig().localCacheKeys.accessToken, value);
  }

  Future<void> clearSession() async {
    jwtToken = null;
    user = null;
    onboardingComplete = false;
    await localCache.remove(AppConfig().localCacheKeys.accessToken);
    await localCache.write(
      AppConfig().localCacheKeys.userLoggedInStatus,
      UserStatus.loggedOut.toLocalCacheInt(),
    );
  }

  Future<void> redirectToAuth() async {
    if (_redirectingToAuth) return;
    _redirectingToAuth = true;
    try {
      final adminRoute = Get.currentRoute.contains('admin');
      await clearSession();
      Get.offAllNamed(
        adminRoute ? AppConfig().routes.admin : AppConfig().routes.auth,
      );
    } finally {
      _redirectingToAuth = false;
    }
  }

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
    jwtToken =
        response['access_token']?.toString() ?? response['token']?.toString();
    await persistAccessToken(jwtToken);

    AppRepo().localCache.write(
          AppConfig().localCacheKeys.userLoggedInStatus,
          UserStatus.loggedIn.toLocalCacheInt(),
        );

    return true;
  }

  Future<void> logoutUser() async {
    await clearSession();
    Get.offAllNamed(AppConfig().routes.splash);
  }
}
