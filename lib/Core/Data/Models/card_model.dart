class GetCardModel {
  final int id;
  final String name;
  final String description;
  final String affiliation;
  final String position;
  final String location;

  const GetCardModel({
    required this.id,
    required this.name,
    required this.description,
    required this.affiliation,
    required this.position,
    required this.location,
  });

  factory GetCardModel.fromJson(Map<String, dynamic> json) {
    return GetCardModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ??
          json['username']?.toString() ??
          json['title']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      affiliation: json['affiliation']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
    );
  }
}
