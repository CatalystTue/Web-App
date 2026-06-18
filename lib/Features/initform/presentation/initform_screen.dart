import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/textfields_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/initform/presentation/controller/initform_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class InitFormScreen extends GetView<InitFormController> {
  const InitFormScreen({super.key});

  static const List<String> _careerStages = [
    'PhD Student',
    'Postdoctoral researcher',
    'Junior Professor',
    'Professor',
    'Student',
    'Academic Staff',
    'Group Leader',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Preliminary Information',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please fill the following to complete your profile:',
              style: textTheme.titleMedium,
            ),
            Gap(AppConfig().dimens.medium),
            Text(
              'Affliation',
              style: textTheme.titleMedium,
            ),
            Gap(AppConfig().dimens.small),
            CustomTextField(
              controller: controller.affliationCtrl,
              labelText: 'Affliation',
              onChanged: controller.onAffliationChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Could not be empty';
                }
                return null;
              },
            ),
            Obx(
              () => controller.loadingOptions.value
                  ? const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: LinearProgressIndicator(),
                    )
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => controller.options.isEmpty
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
                        itemCount: controller.options.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AppConfig().colors.backGroundColor,
                        ),
                        itemBuilder: (context, index) {
                          final option = controller.options[index];
                          return ListTile(
                            dense: true,
                            title: Text(option.label),
                            subtitle: Text(
                              '${option.countryName} - ${option.name}',
                            ),
                            onTap: () => controller.selectAffliation(option),
                          );
                        },
                      ),
                    ),
            ),
            Gap(AppConfig().dimens.medium),
            Text(
              'Career Stage',
              style: textTheme.titleMedium,
            ),
            Gap(AppConfig().dimens.small),
            DropdownButtonFormField<String>(
              value: controller.positionCtrl.text.isEmpty
                  ? null
                  : controller.positionCtrl.text,
              isExpanded: true,
              menuMaxHeight: 260,
              decoration: InputDecoration(
                labelText: 'Career Stage',
                hintText: 'Select your career stage',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppConfig().colors.backGroundColor,
                    width: 0.6,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppConfig().colors.backGroundColor,
                    width: 0.6,
                  ),
                ),
              ),
              items: _careerStages
                  .map(
                    (stage) => DropdownMenuItem<String>(
                      value: stage,
                      child: Text(stage),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                controller.positionCtrl.text = value ?? '';
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Could not be empty';
                }
                return null;
              },
            ),
            Gap(AppConfig().dimens.medium),
            Text(
              'Keywords',
              style: textTheme.titleMedium,
            ),
            Gap(AppConfig().dimens.small),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: controller.keywordsCtrl,
                    labelText: 'Keywords',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Could not be empty';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 50,
                  width: 50,
                  child: ElevatedButton(
                    onPressed: controller.addKeyword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig().colors.backGroundColor,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.add),
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.selectedKeywords.isEmpty
                  ? const SizedBox.shrink()
                  : Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppConfig().colors.backGroundColor,
                          width: 0.6,
                        ),
                      ),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.selectedKeywords.map((keyword) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppConfig()
                                  .colors
                                  .darkYellow
                                  .withOpacity(0.35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppConfig().colors.backGroundColor,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(keyword),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () =>
                                      controller.removeKeyword(keyword),
                                  child: const Icon(
                                    Icons.close,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ).paddingAll(AppConfig().dimens.medium),
      ),
      bottomNavigationBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconButton(
              title: controller.submitting.value
                  ? 'Submitting...'
                  : 'Submit and Continue',
              onTap: controller.submitting.value
                  ? null
                  : controller.submitAndContinue,
              txtColor: Colors.white,
              color: AppConfig().colors.primaryColor,
            ),
          ],
        ),
      ).paddingOnly(
        left: AppConfig().dimens.medium,
        right: AppConfig().dimens.medium,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : AppConfig().dimens.medium,
        top: AppConfig().dimens.small,
      ),
    );
  }
}
