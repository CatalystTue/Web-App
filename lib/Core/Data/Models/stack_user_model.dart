class StackUserModel {
  final String name;
  final String description;
  final String affiliation;
  final String position;

  const StackUserModel({
    required this.name,
    required this.description,
    required this.affiliation,
    required this.position,
  });

  factory StackUserModel.fromJson(Map<String, dynamic> json) {
    return StackUserModel(
      name: json['name']?.toString() ??
          json['username']?.toString() ??
          json['title']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      affiliation: json['affiliation']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
    );
  }
}
