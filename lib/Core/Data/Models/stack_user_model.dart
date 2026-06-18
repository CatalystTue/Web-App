class StackUserModel {
  final String name;
  final String description;

  const StackUserModel({
    required this.name,
    required this.description,
  });

  factory StackUserModel.fromJson(Map<String, dynamic> json) {
    return StackUserModel(
      name: json['name']?.toString() ??
          json['username']?.toString() ??
          json['title']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
    );
  }
}
