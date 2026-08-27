import 'package:catalyst_flutter_app/Core/Components/app_container_widget.dart';
import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'controller/idea_card_controller.dart';

class IdeaCardScreen extends GetView<IdeaCardController> {
  const IdeaCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Card',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: AppConfig().colors.backGroundColor,
          elevation: 0,
          actions: [
            Obx(() {
              if (controller.loading.value) {
                return const SizedBox.shrink();
              }
              if (controller.isEditing.value) {
                return TextButton(
                  onPressed: controller.saving.value
                      ? null
                      : controller.cancelEditing,
                  child: const Text('Cancel'),
                );
              }
              return IconButton(
                tooltip: 'Edit card',
                onPressed: controller.startEditing,
                icon: const Icon(Icons.edit, color: Colors.black),
              );
            }),
          ],
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        body: Padding(
          padding: EdgeInsets.all(
            AppConfig().dimens.medium,
          ),
          child: Obx(() {
            if (controller.loading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            const emptyCard = GetCardModel(
              id: 0,
              name: '',
              description: '',
              affiliation: '',
              position: '',
              location: '',
            );
            final card = controller.ownCard.value ?? emptyCard;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: AppContainerWidget(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.all(AppConfig().dimens.medium),
                        child: controller.isEditing.value
                            ? _EditForm(controller: controller)
                            : _CardView(card: card),
                      ),
                    ),
                  ),
                ),
                if (controller.isEditing.value) ...[
                  Gap(AppConfig().dimens.medium),
                  CustomIconButton(
                    title: controller.saving.value ? 'Saving...' : 'Save',
                    onTap: controller.saving.value
                        ? null
                        : controller.saveEdits,
                    txtColor: Colors.white,
                    color: AppConfig().colors.primaryColor,
                  ),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _CardView extends StatelessWidget {
  final GetCardModel card;

  const _CardView({required this.card});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          card.name.isNotEmpty ? card.name : '—',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppConfig().colors.txtHeaderColor,
          ),
        ),
        Gap(AppConfig().dimens.medium),
        _LabeledValue(label: 'Affiliation', value: card.affiliation),
        Gap(AppConfig().dimens.medium),
        _LabeledValue(label: 'Position', value: card.position),
        Gap(AppConfig().dimens.medium),
        _LabeledValue(label: 'Location', value: card.location),
        Gap(AppConfig().dimens.medium),
        _LabeledValue(label: 'Description', value: card.description),
      ],
    );
  }
}

class _EditForm extends StatelessWidget {
  final IdeaCardController controller;

  const _EditForm({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller.nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        Gap(AppConfig().dimens.medium),
        TextField(
          controller: controller.affiliationCtrl,
          onChanged: controller.onAffiliationChanged,
          decoration: const InputDecoration(
            labelText: 'Affiliation',
            border: OutlineInputBorder(),
          ),
        ),
        Obx(
          () => controller.loadingAffiliationOptions.value
              ? const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ),
        Obx(
          () => controller.affiliationOptions.isEmpty
              ? const SizedBox.shrink()
              : Container(
                  margin: const EdgeInsets.only(top: 8),
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppConfig().colors.backGroundColor,
                      width: 0.6,
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.affiliationOptions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppConfig().colors.backGroundColor,
                    ),
                    itemBuilder: (context, index) {
                      final option = controller.affiliationOptions[index];
                      return ListTile(
                        dense: true,
                        title: Text(option.label),
                        subtitle: Text(
                          '${option.countryName} - ${option.name}',
                        ),
                        onTap: () => controller.selectAffiliation(option),
                      );
                    },
                  ),
                ),
        ),
        Gap(AppConfig().dimens.medium),
        TextField(
          controller: controller.positionCtrl,
          decoration: const InputDecoration(
            labelText: 'Position',
            border: OutlineInputBorder(),
          ),
        ),
        Gap(AppConfig().dimens.medium),
        TextField(
          controller: controller.locationCtrl,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
          ),
        ),
        Gap(AppConfig().dimens.medium),
        TextField(
          controller: controller.descriptionCtrl,
          minLines: 5,
          maxLines: 10,
          decoration: const InputDecoration(
            labelText: 'Description',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final String value;

  const _LabeledValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppConfig().colors.txtHeaderColor,
          ),
        ),
        Gap(AppConfig().dimens.small),
        Text(
          value.isNotEmpty ? value : '—',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConfig().colors.txtBodyColor,
          ),
        ),
      ],
    );
  }
}
