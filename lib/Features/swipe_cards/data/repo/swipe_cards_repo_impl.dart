import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/domain/swipe_cards_repo.dart';

class SwipeCardsRepositoryImpl implements SwipeCardsRepository {
  @override
  Future<List<GetCardModel>> getStackOfCards() async {
    return await CardsService().getStack();
  }

  Future<void> swipeCard({
    required String cardId,
    required String interested,
  }) async {
    return CardsService().swipeCard(cardId: cardId, interested: interested);
  }
}
