// ── Workout domain models ─────────────────────────────────

enum SetStatus { pending, active, completed, skipped }
enum TechniqueType { normal, dropSet, superset, restPause, myo }

class WorkoutSet {
  WorkoutSet({
    required this.index,
    this.targetReps,
    this.targetWeight,
    this.rpe,
    this.technique = TechniqueType.normal,
    this.status = SetStatus.pending,
    this.loggedReps,
    this.loggedWeight,
    this.loggedRpe,
    this.tempo,
    this.notes,
  });

  final int index;
  final int?     targetReps;
  final double?  targetWeight;
  final double?  rpe;
  final TechniqueType technique;

  SetStatus status;
  int?    loggedReps;
  double? loggedWeight;
  double? loggedRpe;
  String? tempo;
  String? notes;

  bool get isDone => status == SetStatus.completed;
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    this.secondaryMuscles = const [],
    this.equipment,
    this.videoUrl,
    this.cues = const [],
  });

  final String id;
  final String name;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String? equipment;
  final String? videoUrl;
  final List<String> cues;

  String get muscleDisplay {
    if (secondaryMuscles.isEmpty) return primaryMuscle;
    return '$primaryMuscle · ${secondaryMuscles.take(2).join(' · ')}';
  }
}

class WorkoutExercise {
  WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.restSeconds = 120,
    this.notes,
    this.orderIndex = 0,
  });

  final Exercise exercise;
  final List<WorkoutSet> sets;
  final int restSeconds;
  final String? notes;
  final int orderIndex;

  int get completedSets => sets.where((s) => s.isDone).length;
  bool get isComplete    => completedSets == sets.length;
  double get progress    => sets.isEmpty ? 0 : completedSets / sets.length;
}

class ActiveWorkout {
  ActiveWorkout({
    required this.title,
    required this.subtitle,
    required this.exercises,
    required this.startedAt,
  });

  final String title;
  final String subtitle;
  final List<WorkoutExercise> exercises;
  final DateTime startedAt;

  int get currentExerciseIndex =>
      exercises.indexWhere((e) => !e.isComplete).clamp(0, exercises.length - 1);

  int get completedExercises =>
      exercises.where((e) => e.isComplete).length;

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.sets.length);

  int get completedSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSets);

  Duration get elapsed => DateTime.now().difference(startedAt);

  bool get isComplete => exercises.every((e) => e.isComplete);
}

// ── Sample workout data ───────────────────────────────────
ActiveWorkout sampleWorkout() => ActiveWorkout(
  title: 'Upper Body — Push A',
  subtitle: 'PPL Hypertrophy · Week 3',
  startedAt: DateTime.now(),
  exercises: [
    WorkoutExercise(
      exercise: const Exercise(
        id: 'barbell_bench',
        name: 'Barbell Bench Press',
        primaryMuscle: 'Chest',
        secondaryMuscles: ['Anterior Deltoid', 'Triceps'],
        equipment: 'Barbell',
        cues: [
          'Retract and depress scapulae',
          'Drive feet into floor',
          'Touch lower chest, flare elbows ~75°',
        ],
      ),
      restSeconds: 150,
      sets: List.generate(4, (i) => WorkoutSet(
        index: i,
        targetReps: i == 0 ? 12 : 10,
        targetWeight: 80,
        rpe: i < 2 ? 7.0 : 8.5,
        status: i < 2 ? SetStatus.completed : SetStatus.pending,
        loggedReps: i < 2 ? [12, 10][i] : null,
        loggedWeight: i < 2 ? 80 : null,
      )),
    ),
    WorkoutExercise(
      exercise: const Exercise(
        id: 'incline_db_press',
        name: 'Incline DB Press',
        primaryMuscle: 'Upper Chest',
        secondaryMuscles: ['Anterior Deltoid'],
        equipment: 'Dumbbell',
      ),
      restSeconds: 120,
      sets: List.generate(3, (i) => WorkoutSet(
        index: i, targetReps: 12, targetWeight: 30, rpe: 8,
      )),
    ),
    WorkoutExercise(
      exercise: const Exercise(
        id: 'cable_fly',
        name: 'Cable Chest Fly',
        primaryMuscle: 'Chest',
        secondaryMuscles: [],
        equipment: 'Cable',
      ),
      restSeconds: 90,
      sets: List.generate(4, (i) => WorkoutSet(
        index: i, targetReps: 15, targetWeight: 15, rpe: 8.5,
      )),
    ),
    WorkoutExercise(
      exercise: const Exercise(
        id: 'ohp',
        name: 'Overhead Press',
        primaryMuscle: 'Anterior Deltoid',
        secondaryMuscles: ['Medial Deltoid', 'Triceps'],
        equipment: 'Barbell',
      ),
      restSeconds: 150,
      sets: List.generate(4, (i) => WorkoutSet(
        index: i, targetReps: 10, targetWeight: 50, rpe: 8,
      )),
    ),
  ],
);
