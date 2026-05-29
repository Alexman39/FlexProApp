import 'dart:convert';

class LoggedSet {
  const LoggedSet({
    required this.reps,
    required this.weight,
    this.rpe,
  });

  final int reps;
  final double weight;
  final double? rpe;

  double get volume => weight * reps;

  Map<String, dynamic> toJson() => {
        'reps': reps,
        'weight': weight,
        if (rpe != null) 'rpe': rpe,
      };

  factory LoggedSet.fromJson(Map<String, dynamic> j) => LoggedSet(
        reps: j['reps'] as int,
        weight: (j['weight'] as num).toDouble(),
        rpe: j['rpe'] != null ? (j['rpe'] as num).toDouble() : null,
      );
}

class LoggedExercise {
  const LoggedExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
  });

  final String exerciseId;
  final String exerciseName;
  final List<LoggedSet> sets;

  double get totalVolume =>
      sets.fold(0, (sum, s) => sum + s.volume);

  double get bestSet =>
      sets.isEmpty ? 0 : sets.map((s) => s.weight).reduce((a, b) => a > b ? a : b);

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'exerciseName': exerciseName,
        'sets': sets.map((s) => s.toJson()).toList(),
      };

  factory LoggedExercise.fromJson(Map<String, dynamic> j) => LoggedExercise(
        exerciseId: j['exerciseId'] as String,
        exerciseName: j['exerciseName'] as String,
        sets: (j['sets'] as List)
            .map((s) => LoggedSet.fromJson(s as Map<String, dynamic>))
            .toList(),
      );
}

class WorkoutLog {
  const WorkoutLog({
    required this.id,
    required this.workoutName,
    required this.startedAt,
    required this.finishedAt,
    required this.exercises,
    this.programId,
    this.programWeek,
    this.programDay,
    this.notes,
  });

  final String id;
  final String workoutName;
  final DateTime startedAt;
  final DateTime finishedAt;
  final List<LoggedExercise> exercises;
  final String? programId;
  final int? programWeek;
  final int? programDay;
  final String? notes;

  Duration get duration => finishedAt.difference(startedAt);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.length);

  double get totalVolume =>
      exercises.fold(0, (sum, e) => sum + e.totalVolume);

  String get formattedVolume {
    if (totalVolume >= 1000) {
      return '${(totalVolume / 1000).toStringAsFixed(1)}t';
    }
    return '${totalVolume.toStringAsFixed(0)}kg';
  }

  String get formattedDuration {
    final m = duration.inMinutes;
    if (m < 60) return '${m}min';
    final h = m ~/ 60;
    final rem = m % 60;
    return rem == 0 ? '${h}h' : '${h}h ${rem}m';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workoutName': workoutName,
        'startedAt': startedAt.toIso8601String(),
        'finishedAt': finishedAt.toIso8601String(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        if (programId != null) 'programId': programId,
        if (programWeek != null) 'programWeek': programWeek,
        if (programDay != null) 'programDay': programDay,
        if (notes != null) 'notes': notes,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> j) => WorkoutLog(
        id: j['id'] as String,
        workoutName: j['workoutName'] as String,
        startedAt: DateTime.parse(j['startedAt'] as String),
        finishedAt: DateTime.parse(j['finishedAt'] as String),
        exercises: (j['exercises'] as List)
            .map((e) => LoggedExercise.fromJson(e as Map<String, dynamic>))
            .toList(),
        programId: j['programId'] as String?,
        programWeek: j['programWeek'] as int?,
        programDay: j['programDay'] as int?,
        notes: j['notes'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutLog.fromJsonString(String s) =>
      WorkoutLog.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
