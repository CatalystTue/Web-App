class GetCardModel {
  final String title;
  final String description;
  final List<String> tags;
  final String stage;
  final int cardId;
  final int ownerId;

  GetCardModel({
    required this.title,
    required this.description,
    required this.tags,
    required this.stage,
    required this.cardId,
    required this.ownerId,
  });

  factory GetCardModel.fromJson(Map<String, dynamic> json) {
    return GetCardModel(
      title: json['title'],
      description: json['description'],
      tags: List<String>.from(json['tags']),
      stage: json['stage'],
      cardId: json['id'],
      ownerId: json['owner_id'],
    );
  }
}
