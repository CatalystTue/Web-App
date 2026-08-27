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
                    onPressed: () => Get.toNamed(AppConfig().routes.settings),
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
                        tooltip: 'Liked Users',
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

  Future<void> _showSavedIdeas(BuildContext context) async {
    await controller.fetchSavedIdeas();
    if (!context.mounted) return;

    final savedIdeas = controller.savedIdeas;
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Liked Users',
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (dialogContext, _, __) => Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: AppConfig().colors.backGroundColor,
          child: SizedBox(
            width: 420,
            height: double.infinity,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppConfig().dimens.medium),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Liked Users',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: savedIdeas.isEmpty
                        ? const Center(child: Text('No liked users yet.'))
                        : ListView.separated(
                            padding: EdgeInsets.all(
                              AppConfig().dimens.medium,
                            ),
                            itemCount: savedIdeas.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (_, index) {
                              final idea = savedIdeas[index];
                              return Card(
                                child: ListTile(
                                  title: Text(idea.name),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      [
                                        if (idea.affiliation.isNotEmpty)
                                          idea.affiliation,
                                        if (idea.position.isNotEmpty)
                                          idea.position,
                                        if (idea.location.isNotEmpty)
                                          idea.location,
                                        if (idea.description.isNotEmpty)
                                          idea.description,
                                      ].join('\n'),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
      },
    );
  }
}
