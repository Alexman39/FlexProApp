class SessionExercise {
  const SessionExercise({
    required this.exerciseId,
    required this.sets,
    required this.targetReps,
    this.maxReps,
    this.rpe,
    this.restSeconds = 120,
  });

  final String exerciseId;
  final int sets;
  final int targetReps;
  final int? maxReps;
  final double? rpe;
  final int restSeconds;

  String get repsLabel =>
      maxReps != null ? '$targetReps–$maxReps' : '$targetReps';
}

class ProgramSession {
  const ProgramSession({
    required this.id,
    required this.name,
    required this.exercises,
  });

  final String id;
  final String name;
  final List<SessionExercise> exercises;

  int get totalSets => exercises.fold(0, (s, e) => s + e.sets);

  int get estimatedMinutes =>
      exercises.fold(0, (s, e) => s + (e.sets * (e.restSeconds + 55)) ~/ 60);
}
