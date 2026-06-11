import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../exercises/data/exercise_database.dart';
import '../../exercises/domain/exercise_model.dart';
import '../../workout/domain/models.dart';
import '../data/programs_data.dart';
import '../domain/program_model.dart';
import '../domain/program_session.dart';
import 'enrollment_provider.dart';

// The program the user is currently enrolled in.
final activeProgramProvider = Provider<Program?>((ref) {
  final enrollment = ref.watch(enrollmentProvider).valueOrNull;
  if (enrollment == null) return null;
  return kAllPrograms.where((p) => p.id == enrollment.programId).firstOrNull;
});

// Today's scheduled session based on current day index.
final todaysSessionProvider = Provider<ProgramSession?>((ref) {
  final program = ref.watch(activeProgramProvider);
  if (program == null || program.sessions.isEmpty) return null;
  final enrollment = ref.watch(enrollmentProvider).valueOrNull;
  if (enrollment == null) return null;
  final idx = enrollment.currentDay % program.sessions.length;
  return program.sessions[idx];
});

// Converts today's session into an ActiveWorkout ready to start.
final todaysActiveWorkoutProvider = Provider<ActiveWorkout?>((ref) {
  final session = ref.watch(todaysSessionProvider);
  final program = ref.watch(activeProgramProvider);
  final enrollment = ref.watch(enrollmentProvider).valueOrNull;
  if (session == null || program == null || enrollment == null) return null;

  final exercises = session.exercises
      .map((se) {
        final model =
            kExerciseDatabase.where((e) => e.id == se.exerciseId).firstOrNull;
        if (model == null) return null;
        return WorkoutExercise(
          exercise: Exercise(
            id: model.id,
            name: model.name,
            primaryMuscle: model.primaryMuscle.label,
            secondaryMuscles:
                model.secondaryMuscles.map<String>((g) => g.label).toList(),
            equipment: model.equipment.label,
            cues: model.tips != null ? [model.tips!] : [],
          ),
          restSeconds: se.restSeconds,
          sets: List.generate(
            se.sets,
            (i) => WorkoutSet(
              index: i,
              targetReps: se.targetReps,
              rpe: se.rpe,
            ),
          ),
        );
      })
      .whereType<WorkoutExercise>()
      .toList();

  return ActiveWorkout(
    title: session.name,
    subtitle: '${program.title}  ·  ${enrollment.weekLabel}',
    exercises: exercises,
    startedAt: DateTime.now(),
  );
});
