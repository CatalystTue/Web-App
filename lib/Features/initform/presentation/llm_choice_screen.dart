import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LlmChoiceScreen extends StatefulWidget {
  const LlmChoiceScreen({super.key});

  @override
  State<LlmChoiceScreen> createState() => _LlmChoiceScreenState();
}

class _LlmChoiceScreenState extends State<LlmChoiceScreen> {
  static const String _customOptionHint = 'Write your own description...';

  int? _selectedIndex;
  bool _isEditStep = false;
  final TextEditingController _chosenTextCtrl = TextEditingController();

  @override
  void dispose() {
    _chosenTextCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments ?? {}) as Map;
    final string1 = args['string1']?.toString() ?? '';
    final string2 = args['string2']?.toString() ?? '';

    final suggestions = [string1, string2].where((s) => s.isNotEmpty).toList();
    final optionCount = suggestions.length + 1;
    final isCustomChoice =
        _selectedIndex != null && _selectedIndex == suggestions.length;

    return Scaffold(
      backgroundColor: AppConfig().colors.backGroundColor,
      appBar: AppBar(
        title: const Text(
          'Choose Your Preference',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditStep
                  ? 'Edit your selected description before continuing.'
                  : 'Which one of the following descriptions do you prefer for your profile?',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isEditStep
                  ? TextField(
                      controller: _chosenTextCtrl,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: isCustomChoice ? _customOptionHint : null,
                        border: const OutlineInputBorder(),
                      ),
                    )
                  : ListView.separated(
                      itemCount: optionCount,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final isCustomOption = index == suggestions.length;
                        final option = isCustomOption
                            ? _customOptionHint
                            : suggestions[index];
                        final selected = _selectedIndex == index;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppConfig()
                                      .colors
                                      .backGroundColor
                                      .withOpacity(0.35)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected
                                    ? AppConfig().colors.secondaryColor
                                    : AppConfig().colors.lightGrayColor,
                                width: selected ? 1.4 : 0.8,
                              ),
                            ),
                            child: Text(
                              option,
                              style: isCustomOption
                                  ? TextStyle(
                                      color: Colors.grey.shade600,
                                      fontStyle: FontStyle.italic,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconButton(
            title: _isEditStep ? 'Continue' : 'Continue and Edit',
            onTap: !_isEditStep && _selectedIndex == null
                ? null
                : () {
                    if (!_isEditStep) {
                      setState(() {
                        _isEditStep = true;
                        _chosenTextCtrl.text =
                            isCustomChoice ? '' : suggestions[_selectedIndex!];
                      });
                      return;
                    }
                    Get.offAllNamed(AppConfig().routes.base);
                  },
            txtColor: Colors.white,
            color: AppConfig().colors.primaryColor,
          ),
        ],
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
