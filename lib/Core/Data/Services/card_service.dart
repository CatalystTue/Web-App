import 'dart:developer';

import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Models/stack_user_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/services_helper.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';
import 'package:flutter/material.dart';

class CardsService extends ServicesHelper {
  static const int _defaultStackSize = 5;

  String get apiURL => '$baseURL/swipes';

  Future<List<GetCardModel>> getStack({int? limit}) async {
    return _fetchNextStack(limit: limit ?? _defaultStackSize);
  }

  Future<List<StackUserModel>> getMeStackUsers() async {
    debugPrint('Requesting home preview cards.');
    return _fetchNextStack(limit: _defaultStackSize);
  }

  Future<List<GetCardModel>> getOwnCards() async {
    debugPrint('Requesting the current user card.');
    final mappedData = await request(
      '$baseURL/profile/me',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    final card = _parseCard(mappedData);
    return card == null ? [] : [card];
  }

  Future<bool> swipeCard({
    required bool interested,
    required int targetUserId,
  }) async {
    final url = '$baseURL/swipes/$targetUserId';
    final body = {
      'interested': interested,
    };

    log('Sending swipe request to $url with body $body');
    final response = await request(
      url,
      serviceType: ServiceType.post,
      body: body,
      requiredDefaultHeader: true,
    );
    log('Swipe Response: $response');
    if (response == null) return false;
    if (response is Map && response.containsKey('detail')) return false;
    return true;
  }

  Future<void> deleteSwipe({required int targetUserId}) async {
    await request(
      '$baseURL/swipes/$targetUserId',
      serviceType: ServiceType.delete,
      requiredDefaultHeader: true,
    );
  }

  Future<List<StackUserModel>> getSavedIdeas() async {
    final data = await request(
      '$baseURL/swipes',
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    return _parseCardList(data);
  }

  Future<StackUserModel?> getReplacementUser({
    required List<int> remainingUserIds,
    required int dismissedUserId,
  }) async {
    final excludeIds = <int>{
      ...remainingUserIds,
      dismissedUserId,
    }.where((id) => id > 0).toList();
    return _fetchNext(excludeIds: excludeIds);
  }

  Future<List<GetCardModel>> _fetchNextStack({required int limit}) async {
    if (limit <= 0) return [];

    final first = await _fetchNext();
    if (first == null) return [];
    if (limit == 1) return [first];

    final firstExclude = first.id > 0 ? [first.id] : <int>[];
    final rest = await Future.wait(
      List.generate(
        limit - 1,
        (_) => _fetchNext(excludeIds: firstExclude),
      ),
    );

    final seen = <int>{if (first.id > 0) first.id};
    final cards = <GetCardModel>[first];
    for (final card in rest) {
      if (card == null) continue;
      if (card.id > 0 && !seen.add(card.id)) continue;
      cards.add(card);
    }

    while (cards.length < limit) {
      final excludeIds =
          cards.map((card) => card.id).where((id) => id > 0).toList();
      final card = await _fetchNext(excludeIds: excludeIds);
      if (card == null) break;
      if (card.id > 0 && !seen.add(card.id)) continue;
      cards.add(card);
    }
    return cards;
  }

  Future<GetCardModel?> _fetchNext({List<int> excludeIds = const []}) async {
    final query = excludeIds.map((id) => 'exclude_ids=$id').join('&');
    final url =
        query.isEmpty ? '$baseURL/swipes/next' : '$baseURL/swipes/next?$query';

    final data = await request(
      url,
      serviceType: ServiceType.get,
      requiredDefaultHeader: true,
    );

    return _parseCard(data);
  }

  GetCardModel? _parseCard(dynamic data) {
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    if (map['id'] == null || map.containsKey('detail')) {
      return null;
    }
    return GetCardModel.fromJson(map);
  }

  List<GetCardModel> _parseCardList(dynamic data) {
    if (data is! List) return [];
    return [
      for (final item in data)
        if (item is Map && item['id'] != null && !item.containsKey('detail'))
          GetCardModel.fromJson(Map<String, dynamic>.from(item)),
    ];
  }
}
