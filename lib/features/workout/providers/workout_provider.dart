import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/firestore_workout_repository.dart';
import '../data/workout_repository.dart';
import '../domain/models.dart';
import '../domain/workout_log_model.dart';

// ── Elapsed timer ─────────────────────────────────────────
final workoutElapsedProvider = StreamProvider.autoDispose<Duration>((ref) async* {
  final start = DateTime.now();
  yield Duration.zero;
  await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
    yield DateTime.now().difference(start);
  }
});

// ── Active workout state ──────────────────────────────────
class WorkoutNotifier extends Notifier<ActiveWorkout?> {
  @override
  ActiveWorkout? build() => null;

  void start({ActiveWorkout? workout}) {
    state = workout ?? sampleWorkout();
  }

  void completeSet(int exerciseIdx, int setIdx) {
    final w = state;
    if (w == null) return;
    final set = w.exercises[exerciseIdx].sets[setIdx];
    set.status = SetStatus.completed;
    state = w; // trigger rebuild via identical-check bypass trick
    // Actually, since these are mutable, we need to force update:
    state = null;
    state = w;
  }

  void logSet({
    required int exerciseIdx,
    required int setIdx,
    required int reps,
    required double weight,
    double? rpe,
  }) {
    final w = state;
    if (w == null) return;
    final set = w.exercises[exerciseIdx].sets[setIdx];
    set.loggedReps   = reps;
    set.loggedWeight = weight;
    set.loggedRpe    = rpe;
    set.status       = SetStatus.completed;
    // Force rebuild
    state = null;
    state = w;
  }

  Future<String?> finish({String? programId, int? programWeek, int? programDay}) async {
    final w = state;
    if (w == null) return null;

    final completedExercises = w.exercises
        .map((we) {
          final loggedSets = we.sets
              .where((s) => s.isDone)
              .map((s) => LoggedSet(
                    reps: s.loggedReps ?? s.targetReps ?? 0,
                    weight: s.loggedWeight ?? s.targetWeight ?? 0,
                    rpe: s.loggedRpe ?? s.rpe,
                  ))
              .toList();
          if (loggedSets.isEmpty) return null;
          return LoggedExercise(
            exerciseId: we.exercise.id,
            exerciseName: we.exercise.name,
            sets: loggedSets,
          );
        })
        .whereType<LoggedExercise>()
        .toList();

    String? logId;
    if (completedExercises.isNotEmpty) {
      logId = const Uuid().v4();
      final log = WorkoutLog(
        id: logId,
        workoutName: w.title,
        startedAt: w.startedAt,
        finishedAt: DateTime.now(),
        exercises: completedExercises,
        programId: programId,
        programWeek: programWeek,
        programDay: programDay,
      );
      final firestoreRepo = ref.read(firestoreWorkoutRepoProvider);
      if (firestoreRepo != null) {
        await firestoreRepo.save(log);
      } else {
        await ref.read(workoutRepositoryProvider).save(log);
        ref.read(workoutHistoryProvider.notifier).refresh();
      }
    }

    state = null;
    return logId;
  }
}

final workoutProvider =
    NotifierProvider<WorkoutNotifier, ActiveWorkout?>(WorkoutNotifier.new);

// ── Rest timer state ──────────────────────────────────────
class RestTimerNotifier extends Notifier<RestTimerState> {
  Timer? _timer;

  @override
  RestTimerState build() => const RestTimerState();

  void start(int seconds) {
    _timer?.cancel();
    state = RestTimerState(
      isActive: true,
      totalSeconds: seconds,
      remainingSeconds: seconds,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        state = state.copyWith(isActive: false, remainingSeconds: 0);
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void skip() {
    _timer?.cancel();
    state = const RestTimerState();
  }

}

class RestTimerState {
  const RestTimerState({
    this.isActive = false,
    this.totalSeconds = 0,
    this.remainingSeconds = 0,
  });

  final bool isActive;
  final int totalSeconds;
  final int remainingSeconds;

  double get progress =>
      totalSeconds == 0 ? 0 : remainingSeconds / totalSeconds;

  String get formattedTime {
    final m = remainingSeconds ~/ 60;
    final s = remainingSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  RestTimerState copyWith({bool? isActive, int? totalSeconds, int? remainingSeconds}) =>
      RestTimerState(
        isActive: isActive ?? this.isActive,
        totalSeconds: totalSeconds ?? this.totalSeconds,
        remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      );
}

final restTimerProvider =
    NotifierProvider<RestTimerNotifier, RestTimerState>(RestTimerNotifier.new);
