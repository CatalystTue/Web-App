import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Features/Base/base_model.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class BaseViewModel extends GetxController {
  late BaseModel _model;

  BaseViewModel() {
    _model = BaseModel();
  }

  BaseModel get model => _model;
  List<StackUserModel> get stackUsers => _model.stackUsers;
  bool get isLoadingStackUsers => _model.isLoadingStackUsers;

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      final storage = AppRepo().localCache.storage;
      final keys = storage.getKeys<Iterable<dynamic>>();
      final entries = {
        for (final key in keys) '$key': storage.read('$key'),
      };
      debugPrint('[Base] Local cache contents: $entries');
    }
    fetchStackUsers();
  }

  Future<void> fetchStackUsers() async {
    _model.isLoadingStackUsers = true;
    update();

    try {
      _model.stackUsers = await CardsService().getMeStackUsers();
      debugPrint('[Base] Loaded ${_model.stackUsers.length} users from users/me');
    } catch (e, stackTrace) {
      debugPrint('[Base] Failed to load users/me: $e');
      debugPrint('$stackTrace');
      _model.stackUsers = [];
    }

    _model.isLoadingStackUsers = false;
    update();
  }

  void updateNavigationIndex(int index) {
    _model.updateNavigationIndex(index);
    update();
  }
}
