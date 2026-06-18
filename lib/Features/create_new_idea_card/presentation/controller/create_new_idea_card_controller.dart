import 'package:catalyst_flutter_app/Features/create_new_idea_card/domain/create_new_idea_card_repo.dart';
import 'package:catalyst_flutter_app/Features/idea_card/presentation/controller/idea_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateNewIdeaCardController extends GetxController {
  late CreateNewIdeaCardRepository repo;

  final selectedTags = <String>[].obs;
  final TextEditingController tagTextController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  RxString selectedStage = "Stages".obs;

  Map<String, String> stages = {
    "General interest": "general_interest",
    "Rough direction": "rough_direction",
    "Concrete idea": "concrete_idea",
    "Work in progress": "work_in_progress",
    "Halfway there": "halfway_there",
  };

  CreateNewIdeaCardController({
    required this.repo,
  });

  void removeTag(String tag) {
    selectedTags.remove(tag);
  }

  void addTag(String tag) {
    if (!selectedTags.contains(tag)) {
      selectedTags.add(tag);
      tagTextController.clear();
    }
  }

  void updateStage(String stage) {
    selectedStage.value = stage;
  }

  String getSelectedStageValue() {
    return stages[selectedStage.value] ?? "";
  }

  @override
  void onClose() {
    tagTextController.dispose();
    super.onClose();
  }

  Future<void> createNewCard({
    required String title,
    required String description,
    required List<String> tags,
    required String stage,
  }) async {
    List<String> formattedTags = tags;
    String formattedStage = selectedStage.value;

    await repo.createNewCard(
      title: title,
      description: description,
      tags: formattedTags,
      stage: formattedStage,
    );

    final ideaCardController = Get.find<IdeaCardController>();
    ideaCardController.refreshUserCards();

    Get.back();
  }
}
