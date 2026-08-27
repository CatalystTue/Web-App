import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AppRepo().hasAccessToken) {
      return RouteSettings(name: AppConfig().routes.auth);
    }
    if (AppRepo().isAdminSession) {
      return RouteSettings(name: AppConfig().routes.adminWelcome);
    }
    return null;
  }
}
