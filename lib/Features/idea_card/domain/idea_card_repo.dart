import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';

abstract class IdeaCardRepository {
  Future<List<GetCardModel>> getOwnCards();
  Future<void> deleteCard(int cardId);
}
