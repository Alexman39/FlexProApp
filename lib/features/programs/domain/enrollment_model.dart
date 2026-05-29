import 'dart:convert';

class ProgramEnrollment {
  const ProgramEnrollment({
    required this.programId,
    required this.startedAt,
    this.currentWeek = 0,
    this.currentDay = 0,
    this.completedSessionIds = const [],
  });

  final String programId;
  final DateTime startedAt;
  final int currentWeek;    // 0-indexed
  final int currentDay;     // 0-indexed within week
  final List<String> completedSessionIds;

  ProgramEnrollment copyWith({
    int? currentWeek,
    int? currentDay,
    List<String>? completedSessionIds,
  }) =>
      ProgramEnrollment(
        programId: programId,
        startedAt: startedAt,
        currentWeek: currentWeek ?? this.currentWeek,
        currentDay: currentDay ?? this.currentDay,
        completedSessionIds:
            completedSessionIds ?? this.completedSessionIds,
      );

  // Display helpers
  String get weekLabel => 'Week ${currentWeek + 1}';
  String get dayLabel => 'Day ${currentDay + 1}';

  int get totalSessions => completedSessionIds.length;

  Map<String, dynamic> toJson() => {
        'programId': programId,
        'startedAt': startedAt.toIso8601String(),
        'currentWeek': currentWeek,
        'currentDay': currentDay,
        'completedSessionIds': completedSessionIds,
      };

  factory ProgramEnrollment.fromJson(Map<String, dynamic> j) =>
      ProgramEnrollment(
        programId: j['programId'] as String,
        startedAt: DateTime.parse(j['startedAt'] as String),
        currentWeek: j['currentWeek'] as int,
        currentDay: j['currentDay'] as int,
        completedSessionIds:
            List<String>.from(j['completedSessionIds'] as List),
      );

  String toJsonString() => jsonEncode(toJson());

  factory ProgramEnrollment.fromJsonString(String s) =>
      ProgramEnrollment.fromJson(
          jsonDecode(s) as Map<String, dynamic>);
}
