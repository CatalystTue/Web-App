import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';

abstract class SwipeCardsRepository {
  Future<List<GetCardModel>> getStackOfCards();
  Future<void> swipeCard({
    required String cardId,
    required String interested,
  });
}
