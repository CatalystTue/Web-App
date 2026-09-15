import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Utils/enum.dart';

abstract class SwipeCardsRepository {
  Future<List<GetCardModel>> getStackOfCards();
  Future<bool> swipeCard({
    required int targetUserId,
    required SwipeOutcome outcome,
  });
}
