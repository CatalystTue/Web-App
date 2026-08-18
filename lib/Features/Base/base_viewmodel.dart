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
  List<StackUserModel> get savedIdeas => _model.savedIdeas;
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
    fetchSavedIdeas();
  }

  Future<void> fetchStackUsers() async {
    _model.isLoadingStackUsers = true;
    update();

    try {
      _model.stackUsers = await CardsService().getMeStackUsers();
      debugPrint(
          '[Base] Loaded ${_model.stackUsers.length} users from users/me');
    } catch (e, stackTrace) {
      debugPrint('[Base] Failed to load users/me: $e');
      debugPrint('$stackTrace');
      _model.stackUsers = [];
    }

    _model.isLoadingStackUsers = false;
    update();
  }

  Future<void> fetchSavedIdeas() async {
    try {
      _model.savedIdeas = await CardsService().getSavedIdeas();
      debugPrint('[Base] Loaded ${_model.savedIdeas.length} saved ideas');
    } catch (e, stackTrace) {
      debugPrint('[Base] Failed to load saved ideas: $e');
      debugPrint('$stackTrace');
    }
    update();
  }

  void updateNavigationIndex(int index) {
    _model.updateNavigationIndex(index);
    update();
  }

  Future<void> saveIdea(StackUserModel idea) async {
    if (_model.savedIdeas.any((saved) => saved.id == idea.id)) {
      // saved.name == idea.name && saved.description == idea.description)) {
      return;
    }
    _model.savedIdeas.add(idea);
    update();

    await CardsService().swipeCard(
      interested: 'true',
      cardId: idea.id.toString(),
    );
  }

  void removeSavedIdea(StackUserModel idea) {
    _model.savedIdeas.removeWhere((saved) =>
        saved.name == idea.name && saved.description == idea.description);
    update();
  }
}
