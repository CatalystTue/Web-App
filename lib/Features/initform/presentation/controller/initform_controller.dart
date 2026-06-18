import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'dart:async';

import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AffliationOption {
  final String countryName;
  final String name;
  final String label;

  AffliationOption({
    required this.countryName,
    required this.name,
    required this.label,
  });

  factory AffliationOption.fromJson(Map<String, dynamic> json) {
    return AffliationOption(
      label: json['label']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}

class InitFormController extends GetxController {
  final affliationCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
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
    if (query.isEmpty) {
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

  Future<void> submitAndContinue() async {
    if (submitting.value) return;

    final currentKeyword = keywordsCtrl.text.trim();
    if (currentKeyword.isNotEmpty) {
      addKeyword();
    }

    if (selectedKeywords.isEmpty) {
      AppRepo().showSnackbar(
        label: 'Error',
        text: 'Please add at least one keyword.',
        position: SnackPosition.TOP,
      );
      return;
    }

    submitting.value = true;
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
    affliationCtrl.dispose();
    positionCtrl.dispose();
    keywordsCtrl.dispose();
    super.onClose();
  }
}
