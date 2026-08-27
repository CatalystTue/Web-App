class AffliationOption {
  final String countryName;
  final String name;
  final String label;

  AffliationOption({
    required this.countryName,
    required this.name,
    required this.label,
  });

  factory AffliationOption.fromJson(Map<String, dynamic> json) {
    return AffliationOption(
      label: json['label']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }
}
