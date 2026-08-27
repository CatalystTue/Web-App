import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'dart:async';

import 'package:catalyst_flutter_app/Core/Data/Models/affiliation_option.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InitFormController extends GetxController {
  final nameCtrl = TextEditingController();
  final affliationCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final keywordsCtrl = TextEditingController();

  final options = <AffliationOption>[].obs;
  final selectedKeywords = <String>[].obs;
  final loadingOptions = false.obs;
  final submitting = false.obs;

  final AuthenticationService _authService = AuthenticationService();
  Timer? _debounce;

  void onAffliationChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.length < 3) {
      options.clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      await fetchAffliationOptions(query);
    });
  }

  Future<void> fetchAffliationOptions(String query) async {
    loadingOptions.value = true;
    final response = await _authService.searchAffliation(query);
    options.assignAll(response.map(AffliationOption.fromJson));
    loadingOptions.value = false;
  }

  void selectAffliation(AffliationOption option) {
    affliationCtrl.text = option.label;
    options.clear();
  }

  void addKeyword() {
    final value = keywordsCtrl.text.trim();
    if (value.isEmpty) return;
    if (!selectedKeywords.contains(value)) {
      selectedKeywords.add(value);
    }
    keywordsCtrl.clear();
  }

  void removeKeyword(String value) {
    selectedKeywords.remove(value);
  }

  Future<bool> _saveFilledProfileFields() async {
    final name = nameCtrl.text.trim();
    final affiliation = affliationCtrl.text.trim();
    final position = positionCtrl.text.trim();
    final location = locationCtrl.text.trim();
    final description = descriptionCtrl.text.trim();

    if (name.isEmpty &&
        affiliation.isEmpty &&
        position.isEmpty &&
        location.isEmpty &&
        description.isEmpty) {
      return true;
    }

    final result = await _authService.updateProfile(
      name: name.isEmpty ? null : name,
      affiliation: affiliation.isEmpty ? null : affiliation,
      position: position.isEmpty ? null : position,
      location: location.isEmpty ? null : location,
      description: description.isEmpty ? null : description,
    );

    if (result == null) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not save your profile. Please try again.',
        position: SnackPosition.TOP,
      );
      return false;
    }
    return true;
  }

  Future<void> submitAndContinue() async {
    if (submitting.value) return;

    if (nameCtrl.text.trim().isEmpty) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please enter your name.',
        position: SnackPosition.TOP,
      );
      return;
    }

    final currentKeyword = keywordsCtrl.text.trim();
    if (currentKeyword.isNotEmpty) {
      addKeyword();
    }

    if (descriptionCtrl.text.trim().isEmpty && selectedKeywords.isEmpty) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please enter a description or at least one keyword.',
        position: SnackPosition.TOP,
      );
      return;
    }

    submitting.value = true;

    final saved = await _saveFilledProfileFields();
    if (!saved) {
      submitting.value = false;
      return;
    }

    if (selectedKeywords.isEmpty) {
      await AppRepo().markOnboardingDone();
      submitting.value = false;
      Get.offAllNamed(AppConfig().routes.base);
      return;
    }

    final result =
        await _authService.getLlmKeywordSuggestions(selectedKeywords.toList());
    submitting.value = false;

    if (result == null) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Could not fetch suggestions. Please try again.',
        position: SnackPosition.TOP,
      );
      return;
    }

    Get.toNamed(
      AppConfig().routes.llmChoice,
      arguments: result,
    );
  }

  @override
  void onClose() {
    _debounce?.cancel();
    nameCtrl.dispose();
    affliationCtrl.dispose();
    positionCtrl.dispose();
    locationCtrl.dispose();
    descriptionCtrl.dispose();
    keywordsCtrl.dispose();
    super.onClose();
  }
}
