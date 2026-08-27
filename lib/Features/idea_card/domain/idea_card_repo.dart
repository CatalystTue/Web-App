import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';

abstract class IdeaCardRepository {
  Future<GetCardModel?> getOwnCard();
  Future<GetCardModel?> updateOwnCard({
    String? name,
    String? affiliation,
    String? position,
    String? description,
    String? location,
  });
}
