// import 'package:catalyst_flutter_app/Core/Components/app_container_widget.dart';
// import 'package:catalyst_flutter_app/Core/Constants/config.dart';
// import 'package:catalyst_flutter_app/Features/idea_card/presentation/controller/idea_card_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';

// class MyCardWidget extends GetView<IdeaCardController> {
//   const MyCardWidget({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppConfig().colors.primaryColor,
//       floatingActionButton: FloatingActionButton(
//         focusColor: AppConfig().colors.primaryColor,
//         backgroundColor: AppConfig().colors.darkYellow,
//         onPressed: () => controller.routeToCreateNewIdeaCard(),
//         child: const Icon(Icons.add),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.only(
//           top: 8.0,
//         ),
//         child: ListView.separated(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: controller.totalCards + 1,
//           itemBuilder: (context, index) {
//             if (index == controller.totalCards) {
//               return const Gap(70);
//             } else {
//               return AppContainerWidget(
//                 width: double.infinity,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("My Research Title",
//                         style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black)),
//                     Gap(AppConfig().dimens.small),
//                     const Text(
//                         "Short Description, Lorem ipsum dolor sit amet consectetur. Nisl mi morbi tempus enim adipiscing "),
//                     Gap(AppConfig().dimens.medium),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Text(
//                         "See More",
//                         style: TextStyle(
//                             color: AppConfig().colors.darkGrayColor,
//                             decoration: TextDecoration.underline),
//                       ),
//                     ),
//                   ],
//                 ).paddingAll(AppConfig().dimens.medium),
//               );
//             }
//           },
//           separatorBuilder: (BuildContext context, int index) =>
//               Gap(AppConfig().dimens.medium),
//         ),
//       ),
//     );
//   }
// }
