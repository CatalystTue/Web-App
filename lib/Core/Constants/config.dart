import 'package:catalyst_flutter_app/Core/Constants/color.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
import 'package:catalyst_flutter_app/Core/Constants/local_cache_keys.dart';
import 'package:catalyst_flutter_app/Core/Constants/route.dart';

class AppConfig {
  static final AppConfig _singleton = AppConfig._internal();
  factory AppConfig() => _singleton;
  AppConfig._internal();

  String get baseURL => "https://catalyst-app.org/server/api/v1";

  final routes = AppRoutes();
  final dimens = Dimens();
  final colors = AppColors();
  final localCacheKeys = LocalCacheKeys();
}
