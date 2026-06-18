import 'package:catalyst_flutter_app/core/components/app_container_widget.dart';
import 'package:catalyst_flutter_app/core/components/tag_container_widget.dart';
import 'package:catalyst_flutter_app/core/constants/config.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'controller/matches_controller.dart';

class MatchesScreen extends GetView<MatchesController> {
  const MatchesScreen({super.key});

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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: controller.totalCards + 1,
            itemBuilder: (context, index) {
              if (index == controller.totalCards) {
                return const Gap(10);
              } else {
                return AppContainerWidget(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              "Clustering Method Searches for Application ",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConfig().colors.txtHeaderColor),
                            ),
                          ),
                          Gap(AppConfig().dimens.small),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.more_vert_outlined,
                                color: Colors.black,
                              ))
                        ],
                      ),
                      Gap(AppConfig().dimens.medium),
                      const TagContainerWidget(
                        lable: 'User Interface',
                        icon: Icons.label,
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
                              color: AppConfig().colors.txtHeaderColor,
                            ),
                          ),
                          Gap(AppConfig().dimens.mediumSmall),
                          Text(
                            "Approved",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConfig().colors.txtBodyColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(AppConfig().dimens.medium),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textAlign: TextAlign.start,
                            "Matched With:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppConfig().colors.txtHeaderColor,
                            ),
                          ),
                          Gap(AppConfig().dimens.extraSmall),
                          Text(
                            "Clustering Method Searches for Application",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppConfig().colors.txtBodyColor,
                            ),
                          ),
                        ],
                      ),
                      Gap(AppConfig().dimens.medium),
                      const Text(
                        "Short Description, Lorem ipsum dolor sit amet consectetur. Nisl mi morbi tempus enim adipiscing Short Description, Lorem ipsum dolor sit amet consectetur. Nisl mi morbi tempus enim adipiscing Short Description, Lorem ipsum dolor sit amet consectetur. Nisl mi morbi tempus enim adipiscing ",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(AppConfig().dimens.small),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "See More",
                          style: TextStyle(
                              color: AppConfig().colors.primaryColor,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                      const Divider(
                        thickness: 1,
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.send,
                            color: AppConfig().colors.primaryColor,
                            size: 18,
                          ),
                          Gap(AppConfig().dimens.small),
                          Text(
                            "Message",
                            style: TextStyle(
                              fontSize: 18,
                              color: AppConfig().colors.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ).paddingAll(AppConfig().dimens.medium),
                );
              }
            },
            separatorBuilder: (BuildContext context, int index) =>
                Gap(AppConfig().dimens.medium),
          ),
        ),
      ),
    );
  }
}
