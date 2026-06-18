// import 'dart:developer';

// import 'package:catalyst_flutter_app/core/data/models/card_model.dart';
// import 'package:catalyst_flutter_app/core/data/services/services_helper.dart';
// import 'package:catalyst_flutter_app/core/utils/enum.dart';
// import 'package:catalyst_flutter_app/app_repo.dart';

// class CardsService extends ServicesHelper {

//   String get apiURL => '$baseURL/cards/';

//   Future<List<GetCardModel>> getStack() async {
//     // note this method only gets the qi cards of other users but not the ones
//     final mappedData = await request(
//       '$baseURL/cards/stack',
//       serviceType: ServiceType.get,
//       requiredDefaultHeader: true,
//       contentType: 'application/json',
//     );

//     return mappedData != null
//         ? [
//             for (final mappedCard in mappedData)
//               GetCardModel.fromJson(mappedCard)
//           ]
//         : [];
//   }

//   Future<void> createNewCard({
//     required String title,
//     required String description,
//     required List<String> tags,
//     required String stage,
//   }) async {
//     Map<String, dynamic> body = {
//       "title": title,
//       "description": description,
//       "tags": tags,
//       "stage": stage,
//     };

//     print('Requesting to add new card with token ${AppRepo().jwtToken}');

//     await request(
//       apiURL,
//       serviceType: ServiceType.post,
//       requiredDefaultHeader: true,
//       body: body,
//     );
//   }

//   Future<List<GetCardModel>> getCardsWithUserId(String userId) async {
//     print('Requesting cards of user with id: $userId');

//     // do over users/me endpoint, then no userID is necessary
//     final mappedData = await request(
//       '$baseURL/users/$userId/cards',
//       serviceType: ServiceType.get,
//       requiredDefaultHeader: false,
//     );

//     //TODO adopt the way how data is retrieved in getOwnCards

//     return mappedData != null
//         ? [
//             for (final mappedCard in mappedData)
//               GetCardModel.fromJson(mappedCard)
//           ]
//         : [];
//   }

//   Future<List<GetCardModel>> getOwnCards() async {
//     print('Requesting cards of the user.');


//     final mappedData = await request(
//       '$baseURL/users/me',
//       serviceType: ServiceType.get,
//       requiredDefaultHeader: true,
//     );

//     var mappedCards = null;
//     if(mappedData != null) {
//       mappedCards = mappedData["cards"];
//     }


//     return mappedCards != null
//         ? [
//       for (final mappedCard in mappedCards)
//         GetCardModel.fromJson(mappedCard)
//     ]
//         : [];
//   }

//   Future<void> deleteProject(int cardId) async {
//     await request(
//       '$baseURL/cards/$cardId',
//       serviceType: ServiceType.delete,
//       requiredDefaultHeader: true,
//     );
//   }

//   Future<void> swipeCard({
//     required String interested,
//     required String cardId,
//   }) async {
//     final url = '$baseURL/swipes/';
//     final body = {
//       'interested': interested,
//       'card_id': cardId,
//     };

//     log('Sending swipe request to $url with body $body');
//     final response = await request(
//       url,
//       serviceType: ServiceType.post,
//       body: body,
//       requiredDefaultHeader: true,
//     );
//     log('Swipe Response: $response');
//   }
// }
