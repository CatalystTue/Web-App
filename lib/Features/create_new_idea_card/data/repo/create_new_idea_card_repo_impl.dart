import 'package:catalyst_flutter_app/Core/Data/Services/card_service.dart';
import 'package:catalyst_flutter_app/Features/create_new_idea_card/domain/create_new_idea_card_repo.dart';

class CreateNewIdeaCardRepositoryImpl implements CreateNewIdeaCardRepository {
  @override
  Future<void> createNewCard(
      {required String title,
      required String description,
      required String stage,
      required List<String> tags}) async {
    return CardsService().createNewCard(
      title: title,
      description: description,
      tags: tags,
      stage: stage,
    );
  }
}
