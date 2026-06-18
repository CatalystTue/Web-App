import 'package:catalyst_flutter_app/Core/Data/Models/card_model.dart';
import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';

import '../../domain/idea_card_repo.dart';

class IdeaCardRepositoryImpl implements IdeaCardRepository {
  @override
  Future<List<GetCardModel>> getOwnCards() {
    return CardsService().getOwnCards();
  }

  @override
  Future<void> deleteCard(int cardId) {
    return CardsService().deleteProject(cardId);
  }
}
