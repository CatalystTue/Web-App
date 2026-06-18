import 'package:catalyst_flutter_app/core/components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/core/components/row_icon_txt_icon_widget.dart';
import 'package:catalyst_flutter_app/core/components/textfields_widget.dart';
import 'package:catalyst_flutter_app/core/constants/color.dart';
import 'package:catalyst_flutter_app/core/constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'controller/create_new_idea_card_controller.dart';

class CreateNewIdeaCardScreen extends GetView<CreateNewIdeaCardController> {
  const CreateNewIdeaCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Create Card',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              labelText: "Titile",
              controller: controller.titleController,
            ),
            Gap(AppConfig().dimens.medium),
            RowIconTxtIconWidget(
              text: Obx(
                () => Text(
                  controller.selectedStage.value,
                  style: controller.selectedStage.value == "Stages"
                      ? TextStyle(
                          color: AppConfig().colors.txtTextFielColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )
                      : TextStyle(
                          color: AppConfig().colors.txtHeaderColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                ),
              ),
              secondIcon: PopupMenuButton<String>(
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 28,
                  color: AppConfig().colors.primaryColor,
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: "General interest",
                    child: Text("General interest"),
                  ),
                  const PopupMenuItem(
                    value: "Rough direction",
                    child: Text("Rough direction"),
                  ),
                  const PopupMenuItem(
                    value: "Concrete idea",
                    child: Text("Concrete idea"),
                  ),
                  const PopupMenuItem(
                    value: "Work in progress",
                    child: Text("Work in progress"),
                  ),
                  const PopupMenuItem(
                    value: "Halfway there",
                    child: Text("Halfway there"),
                  ),
                ],
                onSelected: (value) {
                  controller.updateStage(value);
                },
              ),
            ),
            Gap(AppConfig().dimens.medium),
            TagSelector(controller: controller),
            Gap(AppConfig().dimens.medium),
            CustomMultiLineTextField(
              labelText: "Description",
              controller: controller.descriptionController,
            ),
            Gap(AppConfig().dimens.medium),
          ],
        ).paddingAll(AppConfig().dimens.medium),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: AppConfig().dimens.medium,
          right: AppConfig().dimens.medium,
          bottom: MediaQuery.of(context).padding.bottom > 0
              ? MediaQuery.of(context).padding.bottom
              : AppConfig().dimens.medium,
          top: AppConfig().dimens.small,
        ),
        child: CustomIconButton(
          title: "Create",
          txtColor: Colors.white,
          color: AppConfig().colors.primaryColor,
          onTap: () {
            final title = controller.titleController.text;
            final description = controller.descriptionController.text;
            final skills = controller.selectedTags;
            controller.createNewCard(
              title: title,
              description: description,
              tags: skills,
              stage: controller.getSelectedStageValue(),
            );
          },
        ),
      ),
    );
  }
}

class TagSelector extends StatelessWidget {
  final CreateNewIdeaCardController controller;

  const TagSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: AppConfig().dimens.mediumSmall,
          horizontal: AppConfig().dimens.medium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: AppConfig().colors.txtBodyColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.tagTextController,
                  decoration: InputDecoration(
                    hintText: 'Enter a tag',
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: AppColors().txtTextFielColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final tagText = controller.tagTextController.text;
                  if (tagText.isNotEmpty) {
                    controller.addTag(tagText);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppConfig().colors.primaryColor,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: AppConfig().colors.primaryColor,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                ),
                label: const Text(
                  'Add Tags',
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          Gap(AppConfig().dimens.mediumSmall),
          Obx(
            () => Wrap(
              spacing: 8.0,
              children: controller.selectedTags
                  .map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => controller.removeTag(tag),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
