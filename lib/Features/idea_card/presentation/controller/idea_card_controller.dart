import 'dart:async';

import 'package:catalyst_flutter_app/Core/Data/Models/affiliation_option.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Features/idea_card/domain/idea_card_repo.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IdeaCardController extends GetxController {
  late IdeaCardRepository repo;

  final Rxn<GetCardModel> ownCard = Rxn<GetCardModel>();
  final RxBool loading = false.obs;
  final RxBool saving = false.obs;
  final RxBool isEditing = false.obs;

  final nameCtrl = TextEditingController();
  final affiliationCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final affiliationOptions = <AffliationOption>[].obs;
  final loadingAffiliationOptions = false.obs;

  final AuthenticationService _authService = AuthenticationService();
  Timer? _affiliationDebounce;

  IdeaCardController({
    required this.repo,
  });

  @override
  void onReady() {
    super.onReady();
    loadOwnCard();
  }

  Future<void> loadOwnCard() async {
    loading.value = true;
    final card = await repo.getOwnCard();
    ownCard.value = card;
    _fillEditors(card);
    loading.value = false;
  }

  void _fillEditors(GetCardModel? card) {
    nameCtrl.text = card?.name ?? '';
    affiliationCtrl.text = card?.affiliation ?? '';
    positionCtrl.text = card?.position ?? '';
    locationCtrl.text = card?.location ?? '';
    descriptionCtrl.text = card?.description ?? '';
    _clearAffiliationOptions();
  }

  void onAffiliationChanged(String value) {
    _affiliationDebounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      affiliationOptions.clear();
      return;
    }

    _affiliationDebounce = Timer(const Duration(milliseconds: 400), () async {
      await fetchAffiliationOptions(query);
    });
  }

  Future<void> fetchAffiliationOptions(String query) async {
    loadingAffiliationOptions.value = true;
    final response = await _authService.searchAffliation(query);
    affiliationOptions.assignAll(response.map(AffliationOption.fromJson));
    loadingAffiliationOptions.value = false;
  }

  void selectAffiliation(AffliationOption option) {
    affiliationCtrl.text = option.label;
    _clearAffiliationOptions();
  }

  void _clearAffiliationOptions() {
    _affiliationDebounce?.cancel();
    affiliationOptions.clear();
    loadingAffiliationOptions.value = false;
  }

  void startEditing() {
    _fillEditors(ownCard.value);
    isEditing.value = true;
  }

  void cancelEditing() {
    _fillEditors(ownCard.value);
    isEditing.value = false;
  }

  Future<void> saveEdits() async {
    if (saving.value) return;
    saving.value = true;
    final name = nameCtrl.text.trim();
    final affiliation = affiliationCtrl.text.trim();
    final position = positionCtrl.text.trim();
    final location = locationCtrl.text.trim();
    final description = descriptionCtrl.text.trim();
    final updated = await repo.updateOwnCard(
      name: name,
      affiliation: affiliation,
      position: position,
      location: location,
      description: description,
    );
    saving.value = false;

    if (updated == null) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not save your card. Please try again.',
        position: SnackPosition.TOP,
      );
      return;
    }

    ownCard.value = GetCardModel(
      id: updated.id != 0 ? updated.id : (ownCard.value?.id ?? 0),
      name: updated.name,
      description: updated.description,
      affiliation: updated.affiliation,
      position: updated.position,
      location: updated.location,
    );
    _fillEditors(ownCard.value);
    isEditing.value = false;
  }

  @override
  void onClose() {
    _affiliationDebounce?.cancel();
    nameCtrl.dispose();
    affiliationCtrl.dispose();
    positionCtrl.dispose();
    locationCtrl.dispose();
    descriptionCtrl.dispose();
    super.onClose();
  }
}
