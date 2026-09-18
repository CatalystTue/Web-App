import 'dart:io';

import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

Future<void> initTestLocalCache() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final directory = await Directory.systemTemp.createTemp('catalyst_cache');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => directory.path,
  );
  await GetStorage.init(AppConfig().localCacheKeys.databaseName);
  await AppRepo().localCache.clear();
}
