import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:get_storage/get_storage.dart';

class LocalCacheHelper {
  final storage = GetStorage(AppConfig().localCacheKeys.databaseName);

  Future<void> init() async {
    await GetStorage.init();
  }

  Future<void> write(String key, dynamic value) async {
    await storage.write(key, value);
  }

  T? read<T>(String key) {
    return storage.read<T>(key);
  }

  Future<void> clear() async {
    await storage.erase();
  }
}
