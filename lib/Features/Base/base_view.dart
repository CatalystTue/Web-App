import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Features/Base/base_viewmodel.dart';
import 'package:catalyst_flutter_app/Features/stacked_cards/presentation/stacked_cards_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBaseView extends GetView<BaseViewModel> {
  AppBaseView({super.key});

  final _stackedCardsKey = GlobalKey<StackedCardsScreenState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BaseViewModel>(
      init: controller,
      builder: (_) => Scaffold(
        backgroundColor: AppConfig().colors.backGroundColor,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            SafeArea(
              child: controller.isLoadingStackUsers
                  ? const Center(child: CircularProgressIndicator())
                  : StackedCardsScreen(
                      key: _stackedCardsKey,
                      users: controller.stackUsers,
                      onCardHearted: controller.saveIdea,
                      onCardUnhearted: controller.removeSavedIdea,
                    ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: AppConfig().dimens.medium,
                    top: AppConfig().dimens.small,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.black,
                    tooltip: 'Settings',
                    onPressed: () =>
                        Get.toNamed(AppConfig().routes.settings),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: AppConfig().dimens.medium,
                    top: AppConfig().dimens.small,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        color: Colors.black,
                        tooltip: 'Undo',
                        onPressed: () =>
                            _stackedCardsKey.currentState?.undoLastDismiss(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        color: Colors.black,
                        tooltip: 'Saved Ideas',
                        onPressed: () => _showSavedIdeas(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedIdeas(BuildContext context) {
    final savedIdeas = controller.savedIdeas;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppConfig().colors.backGroundColor,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConfig().dimens.medium),
          child: savedIdeas.isEmpty
              ? const SizedBox(
                  height: 160,
                  child: Center(
                    child: Text('No saved ideas yet. Heart a card to save it.'),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Saved Ideas',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: savedIdeas.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (_, index) {
                          final idea = savedIdeas[index];
                          return ListTile(
                            leading: Icon(Icons.favorite,
                                color: AppConfig().colors.redColor),
                            title: Text(idea.name),
                            subtitle: idea.description.isEmpty
                                ? null
                                : Text(idea.description),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
