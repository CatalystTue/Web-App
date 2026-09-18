class AdminMailPlan {
  const AdminMailPlan({
    required this.enabled,
    this.repeat,
    this.nextAt,
  });

  final bool enabled;
  final String? repeat;
  final DateTime? nextAt;

  static AdminMailPlan parse(Map<String, dynamic> json) {
    return AdminMailPlan(
      enabled: json['enabled'] == true,
      repeat: json['repeat']?.toString(),
      nextAt: parseMailPlanNextAt(json['next_at']),
    );
  }
}

final _offsetSuffix = RegExp(r'[+-]\d{2}:?\d{2}$');

DateTime? parseMailPlanNextAt(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  final hasZone =
      raw.endsWith('Z') || raw.endsWith('z') || _offsetSuffix.hasMatch(raw);
  final parsed = DateTime.parse(hasZone ? raw : '${raw}Z');
  return parsed.toLocal();
}

String toMailPlanDateIso(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day, 12).toIso8601String();

bool canPutEnabledMailDate(DateTime? date, {DateTime? now}) {
  if (date == null) return false;
  final n = now ?? DateTime.now();
  final selected = DateTime(date.year, date.month, date.day);
  final today = DateTime(n.year, n.month, n.day);
  return !selected.isBefore(today);
}

Map<String, dynamic> digestPlanBody({
  required bool enabled,
  required String repeat,
  required DateTime nextAt,
}) {
  return <String, dynamic>{
    'enabled': enabled,
    'repeat': repeat,
    'next_at': toMailPlanDateIso(nextAt),
  };
}

Map<String, dynamic> introPlanBody({
  required bool enabled,
  DateTime? nextAt,
}) {
  return <String, dynamic>{
    'enabled': enabled,
    'next_at': enabled && nextAt != null ? toMailPlanDateIso(nextAt) : null,
  };
}

const digestRepeatValues = <String>[
  'daily',
  'weekly',
  'biweekly',
  'monthly',
];

String normalizeDigestRepeat(String? repeat) {
  if (repeat != null && digestRepeatValues.contains(repeat)) return repeat;
  return 'daily';
}
