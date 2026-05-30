class BodyWeightEntry {
  const BodyWeightEntry({required this.date, required this.weightKg});

  final DateTime date;
  final double weightKg;

  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'weightKg': weightKg,
      };

  factory BodyWeightEntry.fromJson(Map<String, dynamic> j) => BodyWeightEntry(
        date: DateTime.parse(j['date'] as String),
        weightKg: (j['weightKg'] as num).toDouble(),
      );
}
