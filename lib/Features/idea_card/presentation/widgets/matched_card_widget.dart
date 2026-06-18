// import 'package:catalyst_flutter_app/Core/Components/app_container_widget.dart';
// import 'package:catalyst_flutter_app/Core/Constants/config.dart';
// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
// import 'package:get/get.dart';

// class MatchedCardWidget extends StatelessWidget {
//   MatchedCardWidget({
//     super.key,
//   });
//   int totalCards = 3;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppConfig().colors.primaryColor,
//       body: Padding(
//         padding: const EdgeInsets.only(
//           top: 8.0,
//         ),
//         child: ListView.separated(
//           shrinkWrap: true,
//           physics: const BouncingScrollPhysics(),
//           itemCount: totalCards + 1,
//           itemBuilder: (context, index) {
//             if (index == totalCards) {
//               return const Gap(70);
//             } else {
//               return AppContainerWidget(
//                 width: double.infinity,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Matched Research Title",
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
