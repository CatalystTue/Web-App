import 'dart:developer';

import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/services_helper.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:catalyst_flutter_app/app_repo.dart';
import 'package:flutter/material.dart';

class CardsService extends ServicesHelper {
  String get apiURL => '$baseURL/cards/';

  Future<List<GetCardModel>> getStack() async {
    // note this method only gets the qi cards of other users but not the ones
    final mappedData = await request(
      '$baseURL/cards/stack',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
      // contentType: 'application/json',
    );

    return mappedData != null
        ? [
            for (final mappedCard in mappedData)
              GetCardModel.fromJson(mappedCard)
          ]
        : [];
  }

  Future<void> createNewCard({
    required String title,
    required String description,
    required List<String> tags,
    required String stage,
  }) async {
    Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "tags": tags,
      "stage": stage,
    };

    debugPrint('Requesting to add new card with token ${AppRepo().jwtToken}');

    await request(
      apiURL,
      serviceType: ServiceType.post,
      requiredDefaultHeader: true,
      body: body,
    );
  }

  Future<List<GetCardModel>> getCardsWithUserId(String userId) async {
    debugPrint('Requesting cards of user with id: $userId');

    // do over users/me endpoint, then no userID is necessary
    final mappedData = await request(
      '$baseURL/users/$userId/cards',
      serviceType: ServiceType.get,
      requiredDefaultHeader: false,
    );

    //TODO adopt the way how data is retrieved in getOwnCards

    return mappedData != null
        ? [
            for (final mappedCard in mappedData)
              GetCardModel.fromJson(mappedCard)
          ]
        : [];
  }

  Future<List<StackUserModel>> getMeStackUsers() async {
    debugPrint('Requesting stack users from users/me.');
    final mappedData = await request(
      '$baseURL/cards_catch/me',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    if (mappedData is! Map<String, dynamic>) {
      return [];
    }

    final rawList = _extractUsersList(mappedData);
    return rawList
        .take(5)
        .map((item) => StackUserModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .toList();
  }

  List<dynamic> _extractUsersList(Map<String, dynamic> data) {
    for (final key in ['users', 'stack', 'matches', 'recommendations']) {
      final value = data[key];
      if (value is List) return value;
    }

    final cards = data['cards'];
    if (cards is List) return cards;

    return [];
  }

  Future<List<GetCardModel>> getOwnCards() async {
    debugPrint('Requesting cards of the user.');
    var mappedCards = null;
    final mappedData = await request(
      '$baseURL/cards_catch/me',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    if (mappedData != null) {
      mappedCards = mappedData["cards"];
    }
    debugPrint('Mapped cards:');
    return mappedCards != null
        ? [
            for (final mappedCard in mappedCards)
              GetCardModel.fromJson(mappedCard)
          ]
        : [];
  }

  Future<void> deleteProject(int cardId) async {
    await request(
      '$baseURL/cards/$cardId',
      serviceType: ServiceType.delete,
      requiredDefaultHeader: true,
    );
  }

  Future<void> swipeCard({
    required String interested,
    required String cardId,
  }) async {
    final url = '$baseURL/swipes/';
    final body = {
      'interested': interested,
      'card_id': cardId,
    };

    log('Sending swipe request to $url with body $body');
    final response = await request(
      url,
      serviceType: ServiceType.post,
      body: body,
      requiredDefaultHeader: true,
    );
    log('Swipe Response: $response');
  }
}
