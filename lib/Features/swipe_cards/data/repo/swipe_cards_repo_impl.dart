import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Features/swipe_cards/domain/swipe_cards_repo.dart';

class SwipeCardsRepositoryImpl implements SwipeCardsRepository {
  @override
  Future<List<GetCardModel>> getStackOfCards() async {
    return await CardsService().getStack();
  }

  @override
  Future<bool> swipeCard({
    required int targetUserId,
    required bool interested,
  }) async {
    return CardsService().swipeCard(
      targetUserId: targetUserId,
      interested: interested,
    );
  }
}
