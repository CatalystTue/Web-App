abstract class CreateNewIdeaCardRepository {
  Future<void> createNewCard({
    required String title,
    required String description,
    required String stage,
    required List<String> tags,
  });
}
