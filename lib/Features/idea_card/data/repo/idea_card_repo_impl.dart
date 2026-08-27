import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/auth_service.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';

import '../../domain/idea_card_repo.dart';

class IdeaCardRepositoryImpl implements IdeaCardRepository {
  @override
  Future<GetCardModel?> getOwnCard() async {
    final cards = await CardsService().getOwnCards();
    if (cards.isEmpty) return null;
    return cards.first;
  }

  @override
  Future<GetCardModel?> updateOwnCard({
    String? name,
    String? affiliation,
    String? position,
    String? description,
    String? location,
  }) async {
    final response = await AuthenticationService().updateProfile(
      name: name,
      affiliation: affiliation,
      position: position,
      description: description,
      location: location,
    );
    if (response == null) return null;
    if (response.containsKey('detail')) return null;
    if (response['id'] != null) {
      return GetCardModel.fromJson(response);
    }
    // PATCH 204 has no body; keep submitted values, including empty strings.
    return GetCardModel(
      id: 0,
      name: name ?? '',
      description: description ?? '',
      affiliation: affiliation ?? '',
      position: position ?? '',
      location: location ?? '',
    );
  }
}
