import 'package:catalyst_flutter_app/Core/Components/app_container_widget.dart';
import 'package:catalyst_flutter_app/Core/Components/buttons_widgets.dart';
import 'package:catalyst_flutter_app/Core/Components/tag_container_widget.dart';
import 'package:catalyst_flutter_app/Core/Constants/config.dart';
import 'package:catalyst_flutter_app/Core/Constants/dimens.dart';
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
            'My Ideas',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          backgroundColor: AppConfig().colors.backGroundColor,
          elevation: 0,
        ),
        backgroundColor: AppConfig().colors.backGroundColor,
        body: Padding(
          padding: EdgeInsets.all(
            AppConfig().dimens.medium,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Obx(
                  () {
                    if (controller.userCards.isEmpty) {
                      return Center(
                        child: Text(
                          "You don't have any ideas yet, add one now!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConfig().colors.txtHeaderColor,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.userCards.length + 1,
                      itemBuilder: (context, index) {
                        if (index == controller.userCards.length) {
                          return const Gap(10);
                        } else {
                          return AppContainerWidget(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.userCards[index].title,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppConfig()
                                                .colors
                                                .txtHeaderColor),
                                      ),
                                    ),
                                    Gap(AppConfig().dimens.medium),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_vert_outlined,
                                        color: Colors.black,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          print('Edit tapped');
                                        } else if (value == 'delete') {
                                          print(
                                              'Delete card with UI-index: $index');
                                          controller.deleteProject(controller
                                              .userCards[index].cardId);
                                        }
                                      },
                                      itemBuilder: (BuildContext context) => [
                                        PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit,
                                                  color: AppConfig()
                                                      .colors
                                                      .txtHeaderColor),
                                              const SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  color: AppConfig()
                                                      .colors
                                                      .txtHeaderColor),
                                              const SizedBox(width: 8),
                                              Text('Delete'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Gap(AppConfig().dimens.small),
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    alignment: WrapAlignment.start,
                                    spacing: Dimens().mediumSmall,
                                    runSpacing: Dimens().mediumSmall,
                                    children: List.generate(
                                      controller.userCards[index].tags.length,
                                      (skillIndex) {
                                        return TagContainerWidget(
                                          lable: controller.userCards[index]
                                              .tags[skillIndex],
                                          icon: Icons.label,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Gap(AppConfig().dimens.medium),
                                Row(
                                  children: [
                                    Text(
                                      textAlign: TextAlign.start,
                                      "Status:",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            AppConfig().colors.txtHeaderColor,
                                      ),
                                    ),
                                    Gap(AppConfig().dimens.mediumSmall),
                                    Text(
                                      controller.userCards[index].stage,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppConfig().colors.txtBodyColor,
                                      ),
                                    ),
                                  ],
                                ),
                                Gap(AppConfig().dimens.medium),
                                Text(controller.userCards[index].description),
                                Gap(AppConfig().dimens.medium),
                                GestureDetector(
                                  onTap: () {},
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "See More",
                                      style: TextStyle(
                                          color:
                                              AppConfig().colors.primaryColor,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ),
                              ],
                            ).paddingAll(AppConfig().dimens.medium),
                          );
                        }
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          Gap(AppConfig().dimens.medium),
                    );
                  },
                ),
              ),
              CustomIconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  title: "Add Idea",
                  onTap: () => controller.routeToCreateNewIdeaCard(),
                  txtColor: Colors.white,
                  color: AppConfig().colors.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}
